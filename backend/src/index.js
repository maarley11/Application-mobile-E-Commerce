const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const sequelize = require('./config/database');
require('./models/User'); // Importation du modèle pour s'assurer qu'il est chargé
const authRoutes = require('./routes/auth.routes');

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

// Routes API
app.use('/api/auth', authRoutes);

// Connexion DB et démarrage serveur
const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Connecté à SQLite avec succès.');
    
    // Synchronisation automatique des tables pour le développement
    await sequelize.sync({ alter: true });
    console.log('✅ Tables synchronisées');
    
    app.listen(PORT, () => {
      console.log(`🚀 Serveur Baana démarré sur le port ${PORT}`);
    });
  } catch (error) {
    console.error('❌ Erreur de connexion à la base de données :', error);
  }
};

startServer();
