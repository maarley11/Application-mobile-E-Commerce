const dotenv = require('dotenv');

// Load env variables
dotenv.config();

/**
 * Receives a webhook POST request.
 * Validates the secret passed via the `x-webhook-secret` header.
 * Responds with 401 if the secret is missing or incorrect.
 * Otherwise returns 200 with a success payload.
 */
function receiveWebhook(req, res) {
  const secretHeader = req.headers['x-webhook-secret'];
  const expectedSecret = process.env.WEBHOOK_SECRET;

  if (!secretHeader || secretHeader !== expectedSecret) {
    return res.status(401).json({ error: 'Invalid webhook secret' });
  }

  // TODO: add payload processing logic here (e.g., verify signature, store event)
  console.log('Webhook received:', req.body);
  return res.status(200).json({ success: true });
}

module.exports = { receiveWebhook };
