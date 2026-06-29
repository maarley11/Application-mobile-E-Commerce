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
        imageUrl: 'https://images.pexels.com/photos/1028599/pexels-photo-1028599.jpeg?auto=compress&cs=tinysrgb&w=500',
        badge: 'PROMO'
      },
      {
        name: 'Riz Brisé Parfumé (Sac 50kg)',
        description: 'Riz très parfumé, spécialité pour le Thiéboudienne.',
        publicPrice: 22000,
        proPrice: 19500,
        stock: 50,
        categoryId: catAlimentaire.id,
        imageUrl: 'https://images.pexels.com/photos/2647338/pexels-photo-2647338.jpeg?auto=compress&cs=tinysrgb&w=500',
        badge: 'POPULAIRE'
      },
      {
        name: 'Sucre en Poudre (Sac 25kg)',
        description: 'Sucre blanc en poudre, haute qualité.',
        publicPrice: 15000,
        proPrice: 13500,
        stock: 80,
        categoryId: catAlimentaire.id,
        imageUrl: 'https://images.pexels.com/photos/461382/pexels-photo-461382.jpeg?auto=compress&cs=tinysrgb&w=500',
        badge: null
      },
      {
        name: 'Lait en Poudre (Sachet 1kg)',
        description: 'Lait entier en poudre, riche en calcium.',
        publicPrice: 3500,
        proPrice: 3000,
        stock: 200,
        categoryId: catAlimentaire.id,
        imageUrl: 'https://images.pexels.com/photos/3735218/pexels-photo-3735218.jpeg?auto=compress&cs=tinysrgb&w=500',
        badge: null
      },
      {
        name: 'Bouillon Cube (Boîte 60 unités)',
        description: 'Assaisonnement pour tous vos plats locaux.',
        publicPrice: 1500,
        proPrice: 1200,
        stock: 500,
        categoryId: catAlimentaire.id,
        imageUrl: 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=500',
        badge: null
      },
      {
        name: 'Savon de Marseille (Carton 24 pcs)',
        description: 'Savon multi-usages pour le linge et le corps.',
        publicPrice: 4800,
        proPrice: 4000,
        stock: 120,
        categoryId: catMenager.id,
        imageUrl: 'https://images.pexels.com/photos/2735970/pexels-photo-2735970.jpeg?auto=compress&cs=tinysrgb&w=500',
        badge: 'PROMO'
      },
      {
        name: 'Eau de Javel (Bidon 5L)',
        description: 'Produit désinfectant et blanchissant pour la maison.',
        publicPrice: 3000,
        proPrice: 2500,
        stock: 80,
        categoryId: catMenager.id,
        imageUrl: 'https://images.pexels.com/photos/4239130/pexels-photo-4239130.jpeg?auto=compress&cs=tinysrgb&w=500',
        badge: null
      },
      {
        name: 'Lait de Corps Karité (500ml)',
        description: 'Lait hydratant au beurre de karité pur pour peaux sèches.',
        publicPrice: 2500,
        proPrice: 2000,
        stock: 150,
        categoryId: catCosmetique.id,
        imageUrl: 'https://images.pexels.com/photos/3765170/pexels-photo-3765170.jpeg?auto=compress&cs=tinysrgb&w=500',
        badge: 'POPULAIRE'
      },
      {
        name: 'Savon Noir (Pot 500g)',
        description: 'Savon noir traditionnel, excellent gommage naturel.',
        publicPrice: 1500,
        proPrice: 1200,
        stock: 60,
        categoryId: catCosmetique.id,
        imageUrl: 'https://images.pexels.com/photos/4041392/pexels-photo-4041392.jpeg?auto=compress&cs=tinysrgb&w=500',
        badge: 'PROMO'
      },
      {
        name: 'Déodorant Spray Homme (200ml)',
        description: 'Protection longue durée 48h.',
        publicPrice: 1800,
        proPrice: 1500,
        stock: 90,
        categoryId: catCosmetique.id,
        imageUrl: 'https://images.pexels.com/photos/3997993/pexels-photo-3997993.jpeg?auto=compress&cs=tinysrgb&w=500',
        badge: null
      }
    ];

    await Product.bulkCreate(products);
    console.log('✅ 10 produits insérés avec succès.');

    console.log('👤 Création d\'un compte utilisateur de test...');
    const user = await User.create({
      phone: '+221770000000',
      name: 'Boutique Mame Diarra',
      otpCode: '1234',
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
