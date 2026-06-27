const { Sequelize } = require('sequelize');
require('dotenv').config();

// On utilise SQLite par défaut car PostgreSQL n'est pas installé sur la machine
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: './database.sqlite', // Le fichier sera créé à la racine du dossier backend
  logging: false,
});

module.exports = sequelize;
