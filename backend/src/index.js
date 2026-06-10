const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const sequelize = require('./config/database');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// Route de base (Healthcheck)
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'Baana API is running' });
});

// Connexion DB et démarrage serveur
const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Connecté à PostgreSQL avec succès.');
    
    // Pour J1/J2 on peut forcer la synchronisation des tables
    // await sequelize.sync({ alter: true });
    
    app.listen(PORT, () => {
      console.log(`🚀 Serveur Baana démarré sur le port ${PORT}`);
    });
  } catch (error) {
    console.error('❌ Erreur de connexion à la base de données :', error);
  }
};

startServer();
