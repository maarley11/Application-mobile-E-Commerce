require('dotenv').config({ path: '.env.test' });

const request  = require('supertest');
const jwt      = require('jsonwebtoken');
const app      = require('../../src/app');
const { sequelize, User, Product, Order, OrderItem } = require('../../src/models');

const JWT_SECRET = process.env.JWT_SECRET || 'secret_dev_key';

// ---------- helpers ----------
function makeToken(userId, isPro = false) {
  return jwt.sign({ userId, isPro }, JWT_SECRET, { expiresIn: '1h' });
}

// ---------- setup / teardown ----------
beforeAll(async () => {
  await sequelize.sync({ force: true });
});

afterAll(async () => {
  await sequelize.close();
});

// ---------- tests ----------
describe('POST /api/orders', () => {

  test('crée une commande et décrémente le stock (utilisateur normal)', async () => {
    const user    = await User.create({ name: 'Test User', phone: '+221700000001' });
    const product = await Product.create({ name: 'Thiéboudienne', publicPrice: 3000, proPrice: 2500, stock: 10 });

    const token   = makeToken(user.id, false);

    const res = await request(app)
      .post('/api/orders')
      .set('Authorization', `Bearer ${token}`)
      .send({
        paymentMethod: 'WAVE',
        items: [{ productId: product.id, quantity: 2 }],
      });

    expect(res.status).toBe(201);
    expect(res.body.order.totalAmount).toBe(product.publicPrice * 2); // 6000

    // vérifie que le stock a bien été décrémenté
    await product.reload();
    expect(product.stock).toBe(8);
  });

  test('utilise le proPrice si l\'utilisateur est PRO', async () => {
    const user    = await User.create({ name: 'Pro User', phone: '+221700000002', isPro: true });
    const product = await Product.create({ name: 'Yassa', publicPrice: 2000, proPrice: 1500, stock: 5 });

    const token = makeToken(user.id, true);

    const res = await request(app)
      .post('/api/orders')
      .set('Authorization', `Bearer ${token}`)
      .send({
        paymentMethod: 'ORANGE_MONEY',
        items: [{ productId: product.id, quantity: 1 }],
      });

    expect(res.status).toBe(201);
    expect(res.body.order.totalAmount).toBe(product.proPrice); // 1500
  });

  test('retourne 400 si le stock est insuffisant', async () => {
    const user    = await User.create({ name: 'User Stock', phone: '+221700000003' });
    const product = await Product.create({ name: 'Mafé', publicPrice: 1500, proPrice: 1200, stock: 1 });

    const token = makeToken(user.id, false);

    const res = await request(app)
      .post('/api/orders')
      .set('Authorization', `Bearer ${token}`)
      .send({
        paymentMethod: 'WAVE',
        items: [{ productId: product.id, quantity: 5 }], // stock = 1
      });

    expect(res.status).toBe(400);
    expect(res.body.message).toMatch(/stock insuffisant/i);
  });

  test('retourne 401 sans token JWT', async () => {
    const res = await request(app)
      .post('/api/orders')
      .send({ paymentMethod: 'WAVE', items: [] });

    expect(res.status).toBe(401);
  });

  test('retourne 400 si paymentMethod est invalide', async () => {
    const user  = await User.create({ name: 'User Invalid', phone: '+221700000004' });
    const token = makeToken(user.id);

    const res = await request(app)
      .post('/api/orders')
      .set('Authorization', `Bearer ${token}`)
      .send({ paymentMethod: 'PAYPAL', items: [{ productId: 1, quantity: 1 }] });

    expect(res.status).toBe(400);
  });

});
