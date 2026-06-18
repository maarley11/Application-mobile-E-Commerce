// src/middlewares/errorHandler.js
// Middleware global de gestion d'erreurs centralisé.
// Ne jamais exposer les stack traces en production.

const errorHandler = (err, req, res, next) => {
  const isProduction = process.env.NODE_ENV === 'production';

  // Log complet uniquement en développement
  if (!isProduction) {
    console.error('[ERROR]', err);
  } else {
    // En production, on log juste le message, sans la stack
    console.error(`[ERROR] ${err.message}`);
  }

  // Erreurs de validation Sequelize (ex: contrainte UNIQUE violée)
  if (err.name === 'SequelizeUniqueConstraintError') {
    return res.status(409).json({ message: 'Cette ressource existe déjà.' });
  }

  if (err.name === 'SequelizeValidationError') {
    const messages = err.errors.map((e) => e.message);
    return res.status(400).json({ message: 'Erreur de validation.', details: messages });
  }

  // Erreur JWT
  if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
    return res.status(401).json({ message: 'Token invalide ou expiré.' });
  }

  // Erreur générique
  const statusCode = err.status || err.statusCode || 500;
  return res.status(statusCode).json({
    message: isProduction ? 'Une erreur interne est survenue.' : err.message,
  });
};

module.exports = errorHandler;
