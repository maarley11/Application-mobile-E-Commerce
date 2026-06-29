const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

// Middlewares de sécurité
const errorHandler = require('./middlewares/errorHandler');
const { authRateLimiter } = require('./middlewares/rateLimiter');

// Routes
const authRoutes = require('./routes/authRoutes');
const orderRoutes = require('./routes/orderRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const webhookRoutes = require('./routes/webhookRoutes');
const paymentRoutes = require('./routes/paymentRoutes');
const subscriptionRoutes = require('./routes/subscriptionRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes');
const userRoutes = require('./routes/userRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const favoriteRoutes = require('./routes/favoriteRoutes');
const addressRoutes = require('./routes/addressRoutes');

const app = express();

// ─── Sécurité des en-têtes HTTP ───────────────────────────────────────────────
app.use(helmet());

// ─── CORS strict : n'accepte que le frontend Flutter Web ──────────────────────
const allowedOrigins = (process.env.ALLOWED_ORIGINS || 'http://localhost:3001,http://localhost:3000,https://maarley11.github.io').split(',');
app.use(cors({
  origin: (origin, callback) => {
    // Autoriser les requêtes sans origin (ex: Postman, scripts serveur)
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error(`Origine bloquée par CORS : ${origin}`));
    }
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// ─── Parsing JSON ─────────────────────────────────────────────────────────────
app.use(express.json());

// ─── Routes avec Rate Limiting sur l'authentification ─────────────────────────
app.use('/api/auth', authRateLimiter, authRoutes);

// ─── Routes protégées ─────────────────────────────────────────────────────────
app.use('/api/orders', orderRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/webhooks', webhookRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/users', userRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/favorites', favoriteRoutes);
app.use('/api/addresses', addressRoutes);

// ─── Middleware global de gestion d'erreurs (doit être en DERNIER) ────────────
app.use(errorHandler);

module.exports = app;
