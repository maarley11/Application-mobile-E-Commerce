const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { validateRegister, validateLogin, validateVerifyOtp } = require('../middlewares/validators');
const { verifyToken } = require('../middlewares/auth');

// POST /api/auth/register
router.post('/register', validateRegister, authController.register);

// POST /api/auth/login
router.post('/login', validateLogin, authController.login);

// POST /api/auth/verify-otp
router.post('/verify-otp', validateVerifyOtp, authController.verifyOtp);

// POST /api/auth/business-profile
router.post('/business-profile', verifyToken, authController.updateBusinessProfile);

module.exports = router;
