const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/authController');

const router = express.Router();

router.post(
  '/register',
  [
    body('phone')
      .isString()
      .custom((value) => {
        if (!value.startsWith('+221') || value.length !== 13) {
          throw new Error('Le numéro doit commencer par +221 et faire 13 caractères');
        }
        return true;
      }),
    body('name').notEmpty().withMessage('Name is required'),
  ],
  authController.register
);

router.post(
  '/verify-otp',
  [
    body('phone').notEmpty().withMessage('Phone is required'),
    body('otpCode').notEmpty().withMessage('OTP Code is required'),
  ],
  authController.verifyOtp
);

module.exports = router;
