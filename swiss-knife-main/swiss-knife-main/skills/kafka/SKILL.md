---
name: Kafka for Treasury ETL
description: Comprehensive guide for using Apache Kafka as the ingestion and messaging backbone of the Treasury Data Hub ETL pipelines. Covers the three production-critical pillars: Schema Evolution, Partitioning Strategy, and Delivery Guarantees.
---

# Kafka for Treasury ETL

This skill provides rules, patterns, and operational procedures for working with Apache Kafka within the Treasury Data Hub. Kafka serves as the **central nervous system** between data sources and the Flink transformation layer.

## When to Activate

- Designing a new integration or pipeline around Apache Kafka
- Writing a new Kafka producer or consumer (Python or Java)
- Auditing existing data ingestion layers for reliability
- Troubleshooting lost messages, duplicates, or out-of-order events

## 1. Project Context

- **Infrastructure**: Defined in `treasury data hub/docker-compose.yml`
- **Kafka**: Confluent `cp-kafka:7.5.0` on ports `9092` (internal) / `9094` (host)
- **Zookeeper**: Confluent `cp-zookeeper:7.5.0` on port `2181`
- **Kafka UI**: `provectuslabs/kafka-ui` on port `8080`
- **Topics Schema**: Documented in `treasury data hub/schemas/topics.md`

## 2. Topic Naming Convention

All topics **MUST** follow this naming pattern:

```
<domain>-<data-type>-<stage>
```

**Stages**:
| Stage       | Meaning                                 | Example                    |
|-------------|------------------------------------------|----------------------------|
| `raw`       | Original schema from source, untouched   | `gl-entries-raw`           |
| `normalized`| Canonical schema, cleaned                | `transactions-normalized`  |
| `enriched`  | Business metadata added                  | `transactions-enriched`    |
| `validated` | Quality-checked, ready for consumption   | `transactions-validated`   |

**Special Topics**:
- `dlq-*`: Dead letter queues for failed messages (e.g., `dlq-parse-errors`)

### Current Topics Registry

| Topic                      | Source             | Partitions | Retention | Status    |
|----------------------------|--------------------|------------|-----------|-----------|
| `gl-entries-raw`           | GL Connector       | 3          | 30 days   | Active    |
| `market-data-raw`          | BRVM/FX Simulators | 2          | 90 days   | Active    |
| `bank-statements-raw`      | SWIFT/CAMT         | 3          | 90 days   | Planned   |
| `payments-raw`             | Payment Systems    | 3          | 30 days   | Planned   |
| `transactions-normalized`  | Flink              | 4          | 90 days   | Planned   |
| `transactions-enriched`    | Flink              | 4          | 90 days   | Planned   |
| `transactions-validated`   | Flink              | 4          | 365 days  | Planned   |
| `dlq-parse-errors`         | Flink              | 1          | 30 days   | Planned   |

### Adding a New Topic

When adding a source or pipeline stage:
1. Add the topic definition to `treasury data hub/schemas/topics.md` with description, format, retention, partitions, and a sample JSON message.
2. Update the registry table above.

## 3. The Three Critical Production Pillars

These are the three aspects that separate a *"works in dev"* pipeline from one that *runs reliably for years*. Every design decision in this skill is anchored to them.

---

### Pillar 1 — Schema Evolution & Contracts

The #1 cause of broken pipelines is **schema changes**. A source adds a field, renames one, or changes a type — and the downstream breaks silently.

**Rules:**
- Fields can be **added** freely to any message. Flink/consumers must tolerate unknown fields.
- Fields must **never** be removed or renamed without a versioned migration plan.
- **Current state**: We use raw JSON (flexible, but unenforceable). This is acceptable for dev.
- **Production target**: Introduce a **Confluent Schema Registry** with Avro or Protobuf to enforce contracts.
  - Set compatibility mode to `BACKWARD` (new consumers can read old messages) as the default.
  - Version bump every time a field type changes or a field is removed.

**Compatibility modes reference:**

| Mode | Who benefits | When to use |
|------|-------------|-------------|
| `BACKWARD` | Consumers can read old + new schema | Most common; safe default |
| `FORWARD` | Producers can write old + new schema | When upgrading producers before consumers |
| `FULL` | Both directions | Strict contracts, regulated environments |

---

### Pillar 2 — Partitioning Strategy & Ordering

Kafka guarantees ordering **only within a partition**. Wrong partition key = silent out-of-order data.

**Rules:**
- Always choose a partition key that represents **the entity you need ordering for**.
- Set partition count **at topic creation time** — increasing partitions later reshuffles key assignments and breaks ordering.
- Monitor for **partition skew** (one partition gets 90% of traffic). Use composite keys if one key dominates.

**Project partition key decisions:**

| Topic | Partition Key | Rationale |
|-------|-------------|----------|
| `gl-entries-raw` | `account_code` | All entries for an account arrive in order |
| `market-data-raw` | `currency_pair` or `symbol` | Group rates/prices per instrument |
| `transactions-normalized` | `transaction_id` | Even distribution, idempotent |
| `transactions-enriched` | `transaction_id` | Even distribution |
| `transactions-validated` | `transaction_id` | Even distribution |
| `dlq-*` | `null` (none) | Ordering irrelevant for DLQs |

**Python producer with key:**
```python
producer.send(
    'gl-entries-raw',
    key=row['account_code'].encode('utf-8'),  # partition key
    value=message
)
```

---

### Pillar 3 — Delivery Guarantees & Failure Isolation

In financial systems: a lost message = a lost transaction. A silently dropped message = an audit failure.

**Three failure modes to guard against:**

| Failure | Consequence | Defense |
|---------|------------|--------|
| Producer retry sends duplicate | Double-counted transaction | Enable idempotent producer |
| Consumer crashes mid-processing | Message re-processed on restart | Commit offset **after** processing |
| Unparseable message | Silent data loss | Route to DLQ, never drop |

**Idempotent producer (Python):**
```python
producer = KafkaProducer(
    bootstrap_servers='localhost:9094',
    enable_idempotence=True,   # deduplicates retries at broker level
    acks='all',                # wait for all replicas to acknowledge
    retries=5,
    value_serializer=lambda v: json.dumps(v).encode('utf-8'),
)
```

**Manual offset commit (commit AFTER processing):**
```python
consumer = KafkaConsumer(
    'gl-entries-raw',
    bootstrap_servers='localhost:9094',
    group_id='gl-processor',
    enable_auto_commit=False,   # NEVER auto-commit for financial data
    auto_offset_reset='earliest',
)
for message in consumer:
    try:
        process(message.value)     # process first
        consumer.commit()           # commit only on success
    except Exception as e:
        send_to_dlq(message, e)    # never drop — always route to DLQ
```

**DLQ message format:**
```json
{
  "original_topic": "gl-entries-raw",
  "original_offset": 12345,
  "original_partition": 2,
  "error_type": "JSONDecodeError",
  "error_message": "Unexpected token at position 42",
  "failed_at": "2026-03-17T14:00:00Z",
  "raw_value": "...original bytes..."
}
```

**Retention safety net**: Set `retention.ms` high enough to survive a weekend outage without data loss. If consumers are down for 48h, raw topics must still have the messages.

---

## 4. Message Format Rules

All messages published to Kafka **MUST** be JSON and include these envelope fields:

```json
{
  "source": "string (system ID, e.g. 'core-banking-gl', 'brvm-simulator')",
  "timestamp": "string (ISO 8601 UTC, e.g. '2026-02-11T10:30:00Z')",
  ...payload fields
}
```

### Serialization Rules
- **Format**: JSON (dev), Avro with Schema Registry (production target).
- **Timestamps**: Always UTC, ISO 8601 format (`2026-03-17T14:00:00Z`).
- **Currencies**: Always ISO 4217 codes (`XOF`, not `CFA`).
- **Null fields**: Omit rather than send `null` to keep messages compact.

## 5. Producer & Consumer Patterns

> See Pillar 2 for partitioning key decisions, Pillar 3 for idempotence and offset commit patterns.

### Python Producer (canonical template)

```python
from kafka import KafkaProducer
import json

producer = KafkaProducer(
    bootstrap_servers='localhost:9094',
    enable_idempotence=True,          # Pillar 3: dedup retries
    acks='all',                       # Pillar 3: full durability
    retries=5,
    value_serializer=lambda v: json.dumps(v).encode('utf-8'),
    key_serializer=lambda k: k.encode('utf-8') if k else None,
)
try:
    producer.send('gl-entries-raw', key=account_code, value=message)
    producer.flush()
finally:
    producer.close()
```

### Python Consumer (canonical template)

```python
from kafka import KafkaConsumer
import json

consumer = KafkaConsumer(
    'gl-entries-raw',
    bootstrap_servers='localhost:9094',
    group_id='gl-processor-v1',
    value_deserializer=lambda v: json.loads(v.decode('utf-8')),
    auto_offset_reset='earliest',
    enable_auto_commit=False,         # Pillar 3: manual commit
)
for message in consumer:
    try:
        process(message.value)
        consumer.commit()             # Commit AFTER success
    except Exception as e:
        send_to_dlq(message, e)       # Never drop
```

### Flink Consumer

Flink reads from Kafka via `KafkaSource`. The ETL skill handles Flink job patterns.

## 6. Connector Development Pattern

When building a new data source connector:

1. **Create directory**: `treasury data hub/connectors/<source-name>/`
2. **Files needed**:
   - `<source>-connector.py`: Main connector logic
   - `requirements.txt`: Dependencies (must include `kafka-python`)
   - `README.md`: Usage instructions
3. **Rules**:
   - Publish to the appropriate `*-raw` topic only.
   - **Never** transform data in the connector — preserve original schema.
   - Add `source` and `timestamp` envelope fields.
   - Implement duplicate detection (file hash, message ID, etc.).
   - Handle connection failures gracefully with retries.

### Existing Connectors

| Connector         | Directory                         | Target Topic        |
|-------------------|-----------------------------------|---------------------|
| GL File Watcher   | `connectors/gl-connector/`        | `gl-entries-raw`    |

### Existing Simulators

| Simulator          | File                              | Target Topic        |
|--------------------|-----------------------------------|---------------------|
| BRVM Market Data   | `simulators/brvm-simulator.py`    | `market-data-raw`   |
| GL Entries         | `simulators/gl-simulator.py`      | Writes CSV files    |
| FX Rates           | `simulators/fx-simulator.py`      | `market-data-raw`   |

## 7. Operations & Debugging

### Starting the Infrastructure

```bash
cd "treasury data hub"
docker-compose up -d
```

### Useful Commands

```bash
# List all topics
docker exec treasury-kafka kafka-topics --bootstrap-server localhost:9092 --list

# Create a topic manually
docker exec treasury-kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic my-new-topic --partitions 3 --replication-factor 1

# Describe a topic
docker exec treasury-kafka kafka-topics --bootstrap-server localhost:9092 \
  --describe --topic gl-entries-raw

# Consume from a topic (CLI debug)
docker exec treasury-kafka kafka-console-consumer --bootstrap-server localhost:9092 \
  --topic gl-entries-raw --from-beginning --max-messages 5

# Check consumer group lag
docker exec treasury-kafka kafka-consumer-groups --bootstrap-server localhost:9092 \
  --group my-group --describe
```

### Kafka UI

Access at **http://localhost:8080** to:
- Browse topics and partitions
- Inspect message contents
- Monitor consumer group offsets and lag
- View broker metrics

### Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| Connection refused on `9094` | Kafka not running | `docker-compose up -d kafka` |
| Messages not appearing | Wrong bootstrap server | Use `localhost:9094` from host, `kafka:9092` from Docker |
| Consumer not reading | Wrong `group_id` or offset | Reset offset: `--to-earliest` or change `group_id` |
| Duplicate messages | Producer retry without idempotence | Enable `enable.idempotence=true` or deduplicate in consumer |
| Topic auto-creation unexpected | `KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'true'` | Disable for production, keep for dev |

## 8. Anti-Patterns & Pitfalls (From Audits)

These are specific mistakes found in code audits that violate the three production pillars. **Never** reproduce them.

### Pitfall 1: Silent Ordering Loss (Missing Partition Key)
If you omit the `key=` argument, Kafka round-robins the messages. Related events (e.g., updates for the same account) will land in different partitions and arrive out of order.

```python
# BAD: Round-robin routing, ordering is lost
producer.send('gl-entries-raw', value=message)

# GOOD: Key by the natural ordering entity
producer.send('gl-entries-raw', key=row['account_code'].encode('utf-8'), value=message)
```

### Pitfall 2: Silent Data Loss on Error (Swallowing Exceptions)
Printing an error and moving to the next message permanently destroys financial data without a trace.

```python
# BAD: Message is dropped forever
try:
    process(msg)
except Exception as e:
    print(f"Error: {e}") 

# GOOD: Route to DLQ
try:
    process_and_produce(msg)
except Exception as e:
    producer.send('dlq-parse-errors', value={'error': str(e), 'raw': msg})
```

### Pitfall 3: Not Using Idempotence
Without idempotence, network retries will result in duplicated financial transactions.

```python
# BAD: Vulnerable to duplicates on retry
producer = KafkaProducer(
    bootstrap_servers='localhost:9094',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

# GOOD: Guaranteed exactly-once writing
producer = KafkaProducer(
    bootstrap_servers='localhost:9094',
    enable_idempotence=True,
    acks='all',
    retries=5,
    value_serializer=lambda v: json.dumps(v).encode('utf-8'),
    key_serializer=lambda k: k.encode('utf-8') if k else None,
)
```

### Pitfall 4: Leaking Connections on Crash
If the script crashes, un-flushed messages might be lost and the connection remains open.

```python
# BAD: Close won't run on exception
run_connector()
producer.close()

# GOOD: Guaranteed flush and close
try:
    run_connector()
finally:
    producer.close()
```

## 9. Quick Reference: Production Readiness Checklist

Before declaring any connector or pipeline stage production-ready:

- [ ] **Pillar 1 – Schema**: New fields are additive only. No field removed/renamed without a migration plan. Schema documented in `schemas/topics.md`.
- [ ] **Pillar 2 – Partitioning**: Partition key chosen and justified in the topics registry. Partition count set at creation and not changed without impact analysis.
- [ ] **Pillar 3 – Delivery**: Producer has `enable_idempotence=True` and `acks='all'`. Consumer uses manual offset commit. All failures route to `dlq-parse-errors`, nothing is silently dropped.
- [ ] **Retention**: Topic retention is long enough to survive a 72h outage scenario.
- [ ] **Monitoring**: Consumer group lag is visible in Kafka UI and alerted on.
