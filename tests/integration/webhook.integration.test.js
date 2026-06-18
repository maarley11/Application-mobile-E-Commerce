const request = require('supertest');
const app = require('../../src/app.js');
const dotenv = require('dotenv');

dotenv.config({ path: '.env.test' });

describe('Webhook endpoint', () => {
  it('rejects request without secret', async () => {
    const res = await request(app)
      .post('/api/webhooks/payment')
      .send({ amount: 100 });
    expect(res.status).toBe(401);
    expect(res.body.error).toBe('Invalid webhook secret');
  });

  it('accepts request with correct secret', async () => {
    const res = await request(app)
      .post('/api/webhooks/payment')
      .set('x-webhook-secret', process.env.WEBHOOK_SECRET)
      .send({ amount: 100 });
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });
});
