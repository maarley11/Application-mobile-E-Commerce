const express = require('express');
const { paymentWebhook } = require('../controllers/webhookController');

const router = express.Router();

/**
 * POST /api/payments/webhook
 * Endpoint pour recevoir les confirmations de paiement Mobile Money.
 * Sécurisé par l'en-tête x-webhook-secret.
 * Compatible : PayDunya, Wave, Orange Money, et tout agrégateur de paiement.
 *
 * Body attendu :
 * {
 *   "event_type": "payment.success" | "payment.failed",
 *   "order_id": "uuid_de_la_commande",
 *   "transaction_id": "id_transaction_operateur",
 *   "amount": 15000,
 *   "operator": "Wave"
 * }
 */
router.post('/webhook', paymentWebhook);

module.exports = router;
