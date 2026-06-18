require('dotenv').config({ path: '.env.test' });

const { sequelize, User } = require('../../src/models');

beforeAll(async () => {
  await sequelize.sync({ force: true });
});

afterAll(async () => {
  await sequelize.close();
});

test('création d’un utilisateur avec isPro = false par défaut', async () => {
  const user = await User.create({
    email:    'test@example.com',
    password: 'hashed_password',
    name:     'Test User',
    phone:    '+1234567890'
  });
  // Le champ isPro doit être false (valeur par défaut du modèle)
  expect(user.isPro).toBe(false);
});
