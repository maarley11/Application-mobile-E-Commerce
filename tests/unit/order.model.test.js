require('dotenv').config({ path: '.env.test' });

const { sequelize, Order } = require('../../src/models');

beforeAll(async () => {
  // Re‑crée toutes les tables en mémoire avant chaque suite de tests
  await sequelize.sync({ force: true });
});

afterAll(async () => {
  // Ferme la connexion SQLite en mémoire
  await sequelize.close();
});

test('création d’une commande valide avec tous les champs obligatoires', async () => {
  const order = await Order.create({
    totalAmount:   4500,                 // 45.00 € (centimes)
    paymentMethod: 'WAVE',               // valeur ENUM valide
    // `status` n’est pas fourni → il doit prendre la valeur par défaut 'PENDING'
  });

  // Vérifications
  expect(order.totalAmount).toBe(4500);
  expect(order.paymentMethod).toBe('WAVE');
  expect(order.status).toBe('PENDING'); // valeur par défaut
});
