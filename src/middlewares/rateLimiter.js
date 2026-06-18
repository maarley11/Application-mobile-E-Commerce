// src/middlewares/rateLimiter.js
// Protège les routes sensibles contre les attaques par force brute.
// Max 5 tentatives par minute sur les routes d'authentification.

const rateLimit = require('express-rate-limit');

const authRateLimiter = rateLimit({
  windowMs: 60 * 1000, // Fenêtre de 1 minute
  max: 5,              // Max 5 requêtes par IP dans cette fenêtre
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    message: 'Trop de tentatives depuis cette adresse IP. Veuillez réessayer dans 1 minute.',
  },
  // Ne pas compter les requêtes réussies dans la limite (optionnel)
  skipSuccessfulRequests: false,
});

module.exports = { authRateLimiter };
