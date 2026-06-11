require('dotenv').config();
const { Sequelize } = require('sequelize');

const sequelize = process.env.NODE_ENV === 'production' || process.env.DB_DIALECT === 'postgres' 
  ? new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASSWORD, {
      host: process.env.DB_HOST,
      dialect: 'postgres',
      logging: false,
    })
  : new Sequelize({
      dialect: 'sqlite',
      storage: './database.sqlite',
      logging: false,
    });

module.exports = sequelize;
