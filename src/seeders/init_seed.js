const { sequelize, Category, Product, User } = require('../models');

async function seed() {
  try {
    await sequelize.sync({ force: true });
    console.log('Database synced and emptied.');

    // Seed Categories
    const categories = await Category.bulkCreate([
      { name: 'Alimentaire' },
      { name: 'Cosmétique' },
      { name: 'Textile' },
    ]);

    // Seed Products (10 local Senegalese products)
    await Product.bulkCreate([
      { name: 'Riz Parfumé', description: 'Sac de 50kg de riz brisé parfumé.', publicPrice: 22000, proPrice: 20000, stock: 100, categoryId: categories[0].id },
      { name: 'Huile d\'Arachide', description: 'Bidon de 20 litres d\'huile locale.', publicPrice: 25000, proPrice: 23000, stock: 50, categoryId: categories[0].id },
      { name: 'Sucre en poudre', description: 'Sac de 50kg de sucre de la CSS.', publicPrice: 28000, proPrice: 26500, stock: 80, categoryId: categories[0].id },
      { name: 'Bouillon Cube', description: 'Carton de bouillons culinaires.', publicPrice: 15000, proPrice: 13500, stock: 150, categoryId: categories[0].id },
      { name: 'Lait en poudre', description: 'Sac de 25kg de lait.', publicPrice: 40000, proPrice: 38000, stock: 40, categoryId: categories[0].id },
      { name: 'Savon de Marseille', description: 'Carton de 50 morceaux de savon.', publicPrice: 12000, proPrice: 11000, stock: 200, categoryId: categories[1].id },
      { name: 'Beurre de Karité', description: 'Pot de 1kg pur beurre de karité.', publicPrice: 3500, proPrice: 3000, stock: 120, categoryId: categories[1].id },
      { name: 'Lait corporel', description: 'Lait hydratant format familial.', publicPrice: 5000, proPrice: 4000, stock: 90, categoryId: categories[1].id },
      { name: 'Tissu Wax', description: 'Pièce de 6 yards de Wax.', publicPrice: 15000, proPrice: 13500, stock: 60, categoryId: categories[2].id },
      { name: 'Bazin riche', description: 'Coupon de basin de haute qualité.', publicPrice: 30000, proPrice: 27000, stock: 30, categoryId: categories[2].id },
    ]);

    console.log('Database seeded successfully.');
    process.exit(0);
  } catch (error) {
    console.error('Failed to seed database:', error);
    process.exit(1);
  }
}

seed();
