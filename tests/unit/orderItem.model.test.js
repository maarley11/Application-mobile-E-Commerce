require('dotenv').config({ path: '.env.test' });

const { sequelize, OrderItem } = require('../../src/models');

beforeAll(async () => {
  // Re‑crée toutes les tables en mémoire avant chaque suite de tests
  await sequelize.sync({ force: true });
});

afterAll(async () => {
  // Ferme la connexion SQLite en mémoire
  await sequelize.close();
});

test('création d’un OrderItem valide', async () => {
  const item = await OrderItem.create({
    quantity:  3,      // 3 articles
    unitPrice: 1200    // prix unitaire en centimes (12.00 €)
  });

  // Vérifications
  expect(item.quantity).toBe(3);
  expect(item.unitPrice).toBe(1200);
});
