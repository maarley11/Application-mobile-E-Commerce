require('dotenv').config({ path: '.env.test' });

const { sequelize, Product } = require('../../src/models');

beforeAll(async () => {
  // Re‑crée toutes les tables en mémoire avant chaque suite de tests
  await sequelize.sync({ force: true });
});

afterAll(async () => {
  // Ferme la connexion SQLite en mémoire
  await sequelize.close();
});

test('création d’un produit valide avec tous les champs obligatoires', async () => {
  const product = await Product.create({
    name:        'Test Product',
    description: 'Produit de test pour la phase 2',
    publicPrice: 1999,   // prix public en centimes (ex. 19.99 €)
    proPrice:    1499,   // prix pour les membres PRO
    stock:       100
  });

  // Vérifications simples
  expect(product.name).toBe('Test Product');
  expect(product.publicPrice).toBe(1999);
  expect(product.proPrice).toBe(1499);
  expect(product.stock).toBe(100);
});
