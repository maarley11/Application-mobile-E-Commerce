const express = require('express');
const { receiveWebhook } = require('../controllers/webhook.controller');

const router = express.Router();

router.post('/payment', receiveWebhook);

module.exports = router;
