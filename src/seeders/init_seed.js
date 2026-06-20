const { Sequelize } = require('sequelize');
const sequelize = require('../config/database');
const { Category, Product, User, Order, OrderItem, Notification, Subscription } = require('../models');
const bcrypt = require('bcryptjs');

async function seedDatabase() {
  try {
    console.log('🔄 Synchronisation de la base de données PostgreSQL...');
    await sequelize.sync({ force: true });
    console.log('✅ Base de données réinitialisée.');

    console.log('🌱 Création des catégories...');
    const catAlimentaire = await Category.create({ name: 'Alimentaire' });
    const catMenager = await Category.create({ name: 'Ménager' });
    const catCosmetique = await Category.create({ name: 'Cosmétique' });

    console.log('📦 Création des produits locaux...');
    const products = [
      {
        name: 'Huile d\'Arachide (Bidon 5L)',
        description: 'Huile végétale raffinée, idéale pour la friture et la cuisson.',
        publicPrice: 6500,
        proPrice: 5800,
        stock: 100,
        categoryId: catAlimentaire.id,
        imageUrl: 'https://via.placeholder.com/300?text=Huile',
        badge: 'PROMO'
      },
      {
        name: 'Riz Brisé Parfumé (Sac 50kg)',
        description: 'Riz très parfumé, spécialité pour le Thiéboudienne.',
        publicPrice: 22000,
        proPrice: 19500,
        stock: 50,
        categoryId: catAlimentaire.id,
        imageUrl: 'https://via.placeholder.com/300?text=Riz',
        badge: 'POPULAIRE'
      },
      {
        name: 'Sucre en Poudre (Sac 25kg)',
        description: 'Sucre blanc en poudre, haute qualité.',
        publicPrice: 15000,
        proPrice: 13500,
        stock: 80,
        categoryId: catAlimentaire.id,
        imageUrl: 'https://via.placeholder.com/300?text=Sucre',
        badge: null
      },
      {
        name: 'Lait en Poudre (Sachet 1kg)',
        description: 'Lait entier en poudre, riche en calcium.',
        publicPrice: 3500,
        proPrice: 3000,
        stock: 200,
        categoryId: catAlimentaire.id,
        imageUrl: 'https://via.placeholder.com/300?text=Lait',
        badge: null
      },
      {
        name: 'Bouillon Cube (Boîte 60 unités)',
        description: 'Assaisonnement pour tous vos plats locaux.',
        publicPrice: 1500,
        proPrice: 1200,
        stock: 500,
        categoryId: catAlimentaire.id,
        imageUrl: 'https://via.placeholder.com/300?text=Bouillon',
        badge: null
      },
      {
        name: 'Savon de Marseille (Carton 24 pcs)',
        description: 'Savon multi-usages pour le linge et le corps.',
        publicPrice: 4800,
        proPrice: 4000,
        stock: 120,
        categoryId: catMenager.id,
        imageUrl: 'https://via.placeholder.com/300?text=Savon',
        badge: 'PROMO'
      },
      {
        name: 'Eau de Javel (Bidon 5L)',
        description: 'Désinfectant puissant pour l\'entretien de la maison.',
        publicPrice: 2500,
        proPrice: 2000,
        stock: 150,
        categoryId: catMenager.id,
        imageUrl: 'https://via.placeholder.com/300?text=Javel',
        badge: null
      },
      {
        name: 'Détergent en Poudre (Sachet 1kg)',
        description: 'Lessive efficace contre les taches tenaces.',
        publicPrice: 1200,
        proPrice: 1000,
        stock: 300,
        categoryId: catMenager.id,
        imageUrl: 'https://via.placeholder.com/300?text=Detergent',
        badge: null
      },
      {
        name: 'Beurre de Karité (Pot 500g)',
        description: 'Beurre de karité pur, hydratant naturel.',
        publicPrice: 3000,
        proPrice: 2500,
        stock: 80,
        categoryId: catCosmetique.id,
        imageUrl: 'https://via.placeholder.com/300?text=Karite',
        badge: 'LOCAL'
      },
      {
        name: 'Lait de Corps Éclaircissant (Flacon 400ml)',
        description: 'Lait de beauté hydratant pour une peau douce.',
        publicPrice: 4500,
        proPrice: 3800,
        stock: 60,
        categoryId: catCosmetique.id,
        imageUrl: 'https://via.placeholder.com/300?text=LaitCorps',
        badge: null
      }
    ];

    await Product.bulkCreate(products);
    console.log('✅ 10 produits insérés avec succès.');

    console.log('👤 Création d\'un compte utilisateur de test...');
    const hashedOtp = await bcrypt.hash('1234', 10);
    const user = await User.create({
      phone: '+221770000000',
      name: 'Boutique Mame Diarra',
      otpCode: hashedOtp,
      otpExpiresAt: new Date(Date.now() + 10 * 60000), // valide 10 min
      isVerified: true,
      isPro: true, // Pro par défaut pour tester les prix Pro
    });

    console.log(`✅ Utilisateur test créé: ${user.phone} (Code OTP: 1234)`);

    console.log('🎉 Seed terminé ! Base de données prête.');
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur lors du seed :', error);
    process.exit(1);
  }
}

seedDatabase();
