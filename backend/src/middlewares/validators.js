const { body, validationResult } = require('express-validator');

// Validation pour l'inscription
const validateRegister = [
  body('phone')
    .notEmpty()
    .withMessage('Le numéro de téléphone est requis')
    .matches(/^\+221\d{9}$/)
    .withMessage('Le format du téléphone doit être +221 suivi de 9 chiffres'),
  body('name').notEmpty().withMessage('Le nom est requis'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
];

// Validation pour la connexion
const validateLogin = [
  body('phone')
    .notEmpty()
    .withMessage('Le numéro de téléphone est requis')
    .matches(/^\+221\d{9}$/)
    .withMessage('Le format du téléphone doit être +221 suivi de 9 chiffres'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
];

// Validation pour la vérification OTP
const validateVerifyOtp = [
  body('phone').notEmpty(),
  body('otpCode').isLength({ min: 4, max: 4 }).withMessage('Le code OTP doit faire 4 caractères'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
];

module.exports = {
  validateRegister,
  validateLogin,
  validateVerifyOtp,
};
