---
name: Adding a New Data Source to the Treasury Data Hub
description: Step-by-step workflow for integrating any new data source (API, database, file, webhook, etc.) into the Treasury Data Hub ingestion layer. Ensures consistency with existing connectors and compliance with all three Kafka production pillars.
---

# Adding a New Data Source

This skill governs how every new data source is integrated into the Treasury Data Hub ingestion layer. Follow every step in order. Do not skip steps for "simple" sources — a bad ingestion layer is always the result of shortcuts taken early.

## When to Activate

- You are asked to write a new Python ingestion script.
- You are connecting to a new API, downloading a new file type, or listening to a new Webhook.
- A user wants to bring a new upstream system (e.g. Core Banking DB) into the Apache Kafka layer.

> **Read first**: The `Kafka for Treasury ETL` skill defines the non-negotiable rules (Pillar 1: Schema, Pillar 2: Partitioning, Pillar 3: Delivery). This skill tells you *how to apply them* for a specific new source.

---

## Step 0 — Classify the Source

Before writing a single line of code, answer these three questions:

| Question | Answer options |
|----------|----------------|
| **Delivery mode** | `PUSH` (source sends to us) or `PULL` (we poll the source) |
| **Trigger** | `FILE` · `SCHEDULE` · `WEBHOOK` · `CDC` · `STREAM` |
| **Latency requirement** | `BATCH` (hours/days acceptable) or `REAL-TIME` (seconds) |

This determines which connector template to use (see Step 2).

**Examples:**
- GL daily export → PULL / FILE / BATCH
- BRVM API → PULL / SCHEDULE / REAL-TIME
- Bank webhook → PUSH / WEBHOOK / REAL-TIME
- Core Banking DB → PULL / CDC / REAL-TIME

---

## Step 1 — Register the Topic

Before any code, register the new raw topic in `treasury data hub/schemas/topics.md` and in the `Kafka for Treasury ETL` skill's topic registry table.

**Topic naming**: `<domain>-<data-type>-raw` (all raw topics use the `-raw` suffix).

**Entry to add:**

```markdown
### <your-topic-name>
- **Description**: What this source provides
- **Format**: JSON
- **Retention**: X days
- **Partitions**: N (see Step 3 for how to choose N)
- **Partition Key**: <field name and rationale>
- **Sample Message**:
{
  "source": "<source-id>",
  "timestamp": "<ISO 8601 UTC>",
  ...source-specific fields
}
```

**Rules:**
- Use the exact same `source` identifier string everywhere (in code, in the topic doc, in monitoring).
- Put `source` and `timestamp` first in the sample — they are mandatory envelope fields.
- `timestamp` must be named exactly `timestamp` (not `created_at`, `ingestion_time`, etc.).

---

## Step 2 — Create the Connector Directory

```
treasury data hub/connectors/<source-name>/
├── <source>-connector.py    ← Main connector
├── requirements.txt          ← kafka-python + source-specific deps
└── README.md                 ← Usage instructions
```

**Naming rule**: Use the same `<source-name>` as the topic minus the `-raw` suffix.
- Topic `bank-statements-raw` → directory `connectors/bank-statements/`
- Topic `swift-messages-raw` → directory `connectors/swift-messages/`

---

## Step 3 — Choose Partitions and Partition Key

Set both **before creating the topic** — changing partitions later breaks key-based ordering.

**Partitions formula:**
- Low volume (< 1,000 msg/day): 2–3 partitions
- Medium volume (1,000–100,000 msg/day): 3–6 partitions
- High volume (> 100,000 msg/day): discuss before proceeding

**Partition key rule**: Choose a key that represents **the entity for which ordering matters**.

| Source type | Suggested partition key |
|-------------|------------------------|
| GL / accounting entries | `account_code` |
| FX rates / market data | `currency_pair` or `symbol` |
| Bank statements | `iban` or `account_number` |
| Payment messages | `payment_id` or `sender_account` |
| Client data | `client_id` |
| API no natural key | Use a stable hash of the primary identifier |

---

## Step 4 — Implement the Connector

Use the canonical template below. Choose the section for your trigger type.

### Canonical Producer Setup (ALL sources must use this)

```python
from kafka import KafkaProducer
import json
from datetime import datetime, timezone

def build_producer(bootstrap_servers: str = 'localhost:9094') -> KafkaProducer:
    return KafkaProducer(
        bootstrap_servers=bootstrap_servers,
        enable_idempotence=True,        # Pillar 3: dedup retries at broker
        acks='all',                     # Pillar 3: wait for all replicas
        retries=5,
        retry_backoff_ms=300,
        value_serializer=lambda v: json.dumps(v).encode('utf-8'),
        key_serializer=lambda k: k.encode('utf-8') if k else None,
    )

def now_utc() -> str:
    """Always use this for the mandatory 'timestamp' field."""
    return datetime.now(timezone.utc).isoformat(timespec='seconds').replace('+00:00', 'Z')

def build_envelope(source_id: str, payload: dict) -> dict:
    """Wrap any payload with the mandatory envelope fields."""
    return {
        'source': source_id,
        'timestamp': now_utc(),
        **payload,           # source fields follow envelope — never before
    }
```

---

### Template A — FILE (Batch / file drop)

*Use for: GL daily exports, any CSV/JSON file landing in a directory.*

```python
import os, csv, json, time, hashlib
from pathlib import Path
from kafka import KafkaProducer
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

TOPIC = '<your-topic>-raw'
SOURCE_ID = '<your-source-id>'
PARTITION_KEY_FIELD = '<field_name>'   # e.g. 'account_code'

class FileConnector(FileSystemEventHandler):
    def __init__(self, watch_dir: str, bootstrap_servers: str = 'localhost:9094'):
        self.watch_dir = Path(watch_dir)
        self.watch_dir.mkdir(parents=True, exist_ok=True)
        self.producer = build_producer(bootstrap_servers)
        self._processed = set()
        self._log = self.watch_dir / '.processed.log'
        if self._log.exists():
            self._processed = set(self._log.read_text().splitlines())

    def _hash(self, path: str) -> str:
        with open(path, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()

    def process(self, file_path: str):
        h = self._hash(file_path)
        if h in self._processed:
            return
        try:
            with open(file_path, encoding='utf-8') as f:
                for row in csv.DictReader(f):
                    msg = build_envelope(SOURCE_ID, dict(row))
                    key = row.get(PARTITION_KEY_FIELD)
                    self.producer.send(TOPIC, key=key, value=msg)
            self.producer.flush()
            with open(self._log, 'a') as f:
                f.write(h + '\n')
            self._processed.add(h)
        except Exception as e:
            self._send_to_dlq(file_path, e)

    def _send_to_dlq(self, file_path: str, e: Exception):
        self.producer.send('dlq-parse-errors', value={
            'source': SOURCE_ID, 'timestamp': now_utc(),
            'original_topic': TOPIC, 'source_file': os.path.basename(file_path),
            'error_type': type(e).__name__, 'error_message': str(e),
        })
        self.producer.flush()

    def on_created(self, event):
        if not event.is_directory and event.src_path.endswith('.csv'):
            time.sleep(0.5)
            self.process(event.src_path)

    def run(self):
        # Process backlog first
        for f in sorted(self.watch_dir.glob('*.csv')):
            self.process(str(f))
        obs = Observer()
        obs.schedule(self, str(self.watch_dir), recursive=False)
        obs.start()
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            obs.stop()
        finally:
            obs.join()
            self.producer.close()
```

---

### Template B — SCHEDULE (API polling)

*Use for: BRVM, FX rate APIs, any REST API polled on a timer.*

```python
import time, requests
from kafka import KafkaProducer

TOPIC = '<your-topic>-raw'
SOURCE_ID = '<your-source-id>'
PARTITION_KEY_FIELD = '<field_name>'   # e.g. 'currency_pair'
POLL_INTERVAL_SECONDS = 60

class ApiConnector:
    def __init__(self, api_url: str, bootstrap_servers: str = 'localhost:9094'):
        self.api_url = api_url
        self.producer = build_producer(bootstrap_servers)

    def fetch(self) -> list[dict]:
        """Fetch raw data from the API. Return list of records."""
        resp = requests.get(self.api_url, timeout=10)
        resp.raise_for_status()
        return resp.json()  # adapt to actual API response shape

    def publish(self, records: list[dict]):
        for record in records:
            msg = build_envelope(SOURCE_ID, record)
            key = record.get(PARTITION_KEY_FIELD)
            self.producer.send(TOPIC, key=key, value=msg)
        self.producer.flush()

    def _send_to_dlq(self, e: Exception, context: str = ''):
        self.producer.send('dlq-parse-errors', value={
            'source': SOURCE_ID, 'timestamp': now_utc(),
            'original_topic': TOPIC,
            'error_type': type(e).__name__, 'error_message': str(e),
            'context': context,
        })
        self.producer.flush()

    def run(self):
        print(f"🔌 {SOURCE_ID} connector started (interval: {POLL_INTERVAL_SECONDS}s)")
        try:
            while True:
                try:
                    records = self.fetch()
                    self.publish(records)
                    print(f"✅ {len(records)} records published")
                except Exception as e:
                    print(f"❌ Fetch/publish error: {e}")
                    self._send_to_dlq(e, context='poll-cycle')
                time.sleep(POLL_INTERVAL_SECONDS)
        except KeyboardInterrupt:
            print("🛑 Stopped")
        finally:
            self.producer.close()
```

---

### Template C — WEBHOOK (push from external system)

*Use for: Bank notifications, payment system callbacks, any HTTP webhook.*

```python
from flask import Flask, request, jsonify
from kafka import KafkaProducer

TOPIC = '<your-topic>-raw'
SOURCE_ID = '<your-source-id>'
PARTITION_KEY_FIELD = '<field_name>'

app = Flask(__name__)
producer = build_producer()

@app.route('/webhook/<source_name>', methods=['POST'])
def receive(source_name: str):
    try:
        payload = request.get_json(force=True)
        if payload is None:
            return jsonify({'error': 'invalid JSON'}), 400
        msg = build_envelope(SOURCE_ID, payload)
        key = payload.get(PARTITION_KEY_FIELD)
        producer.send(TOPIC, key=key, value=msg)
        producer.flush()
        return jsonify({'status': 'accepted'}), 202
    except Exception as e:
        producer.send('dlq-parse-errors', value={
            'source': SOURCE_ID, 'timestamp': now_utc(),
            'original_topic': TOPIC,
            'error_type': type(e).__name__, 'error_message': str(e),
        })
        producer.flush()
        return jsonify({'error': 'internal error'}), 500
```

---

### Template D — DATABASE / CDC

*Use for: Reading directly from a Postgres/MySQL table on a schedule.*

```python
import psycopg2, time
from kafka import KafkaProducer

TOPIC = '<your-topic>-raw'
SOURCE_ID = '<your-source-id>'
PARTITION_KEY_FIELD = '<field_name>'
WATERMARK_FILE = '.last_watermark'

class DbConnector:
    def __init__(self, dsn: str, query: str, bootstrap_servers: str = 'localhost:9094'):
        self.dsn = dsn
        self.query = query  # Must accept a %(watermark)s parameter
        self.producer = build_producer(bootstrap_servers)

    def _load_watermark(self) -> str:
        try:
            return open(WATERMARK_FILE).read().strip()
        except FileNotFoundError:
            return '1970-01-01T00:00:00Z'

    def _save_watermark(self, ts: str):
        open(WATERMARK_FILE, 'w').write(ts)

    def run(self, interval_seconds: int = 300):
        print(f"🔌 {SOURCE_ID} DB connector started")
        try:
            while True:
                watermark = self._load_watermark()
                conn = psycopg2.connect(self.dsn)
                try:
                    cur = conn.cursor()
                    cur.execute(self.query, {'watermark': watermark})
                    cols = [d[0] for d in cur.description]
                    rows = cur.fetchall()
                    new_watermark = watermark
                    for row in rows:
                        record = dict(zip(cols, row))
                        msg = build_envelope(SOURCE_ID, record)
                        key = str(record.get(PARTITION_KEY_FIELD, ''))
                        self.producer.send(TOPIC, key=key, value=msg)
                        # Track latest timestamp for next run
                        if 'updated_at' in record:
                            new_watermark = str(record['updated_at'])
                    self.producer.flush()
                    self._save_watermark(new_watermark)
                    print(f"✅ {len(rows)} rows published")
                except Exception as e:
                    print(f"❌ DB error: {e}")
                    self.producer.send('dlq-parse-errors', value={
                        'source': SOURCE_ID, 'timestamp': now_utc(),
                        'original_topic': TOPIC,
                        'error_type': type(e).__name__, 'error_message': str(e),
                    })
                    self.producer.flush()
                finally:
                    conn.close()
                time.sleep(interval_seconds)
        except KeyboardInterrupt:
            print("🛑 Stopped")
        finally:
            self.producer.close()
```

---

## Step 5 — Write `requirements.txt`

Always include `kafka-python`. Add source-specific deps:

```txt
kafka-python==2.0.2
# FILE sources:
watchdog==3.0.0
# API sources:
requests==2.31.0
# WEBHOOK sources:
flask==3.0.0
# DB sources:
psycopg2-binary==2.9.9
```

---

## Step 6 — Write `README.md`

Minimum content:

```markdown
# <Source Name> Connector

**Source**: Brief description of what this source provides
**Topic**: `<topic-name>-raw`
**Trigger**: FILE | SCHEDULE | WEBHOOK | DB
**Partition key**: `field_name` — rationale

## Setup
pip install -r requirements.txt

## Usage
python <source>-connector.py

## Environment variables (if any)
- `KAFKA_BOOTSTRAP`: Kafka bootstrap servers (default: localhost:9094)
- `<OTHER_VAR>`: Description
```

## Step 7 — Anti-Patterns & Pitfalls

When creating new sources, never take these shortcuts:

### Pitfall 1: Bypassing the Topic Standard
Never create a one-off topic name or use a plain string key.

```python
# BAD: Non-standard topic and missing envelope
producer.send('my_custom_gl_stuff', value={'debit': 100})

# GOOD: Conforming to naming and envelope standards
producer.send('gl-entries-raw', key=row['account_code'].encode(), value=build_envelope(SOURCE_ID, row))
```

### Pitfall 2: Logic in the Connector
The ingestion layer must be "dumb pipes". Never clean or transform data here.

```python
# BAD: Transforming data in the connector
row['date'] = datetime.strptime(row['raw_date'], "%Y-%m-%d").isoformat()
row['amount'] = float(row['val']) * 100

# GOOD: Pass the raw data pure, let Flink transform it
row['raw_date'] = row['raw_date']
row['val'] = row['val']
```

---

## Step 8 — Production Readiness Checklist

Do not consider the connector done until every item is checked:

- [ ] Topic registered in `schemas/topics.md` with sample message
- [ ] Topic added to Kafka skill's registry table
- [ ] `source` and `timestamp` are the first two envelope fields
- [ ] `timestamp` is named exactly `timestamp` (not `ingestion_timestamp`, etc.)
- [ ] Partition key is set on every `producer.send()` call
- [ ] Partition key choice is documented in `schemas/topics.md`
- [ ] Producer has `enable_idempotence=True`, `acks='all'`, `retries=5`
- [ ] All errors route to `dlq-parse-errors` — nothing is silently dropped
- [ ] `producer.close()` is inside a `finally` block
- [ ] `producer.flush()` is called after every logical batch
- [ ] Duplicate prevention is implemented (file hash, watermark, idempotent key)
- [ ] `requirements.txt` and `README.md` exist in the connector directory
- [ ] Connector was run against a local Kafka instance and messages inspected in Kafka UI
