// src/controllers/subscription.controller.js
const { Subscription, User } = require('../models');
const { Op } = require('sequelize');

/**
 * Create a new subscription for a user.
 * Expected body: { userId, plan, expiresAt }
 */
exports.createSubscription = async (req, res) => {
  try {
    const { userId, plan, expiresAt } = req.body;
    // Simple validation
    if (!userId || !plan || !expiresAt) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    const subscription = await Subscription.create({
      userId,
      plan,
      expiresAt,
    });
    return res.status(201).json({ subscription });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Failed to create subscription' });
  }
};

/**
 * List subscriptions for a given user (query param ?userId=...)
 */
exports.listSubscriptions = async (req, res) => {
  try {
    const { userId } = req.query;
    const where = {};
    if (userId) where.userId = userId;
    const subscriptions = await Subscription.findAll({ where });
    return res.status(200).json({ subscriptions });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Failed to list subscriptions' });
  }
};

/**
 * Cancel a subscription (set status to 'canceled')
 */
exports.cancelSubscription = async (req, res) => {
  try {
    const { id } = req.params;
    const subscription = await Subscription.findByPk(id);
    if (!subscription) {
      return res.status(404).json({ error: 'Subscription not found' });
    }
    subscription.status = 'canceled';
    await subscription.save();
    return res.status(200).json({ subscription });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Failed to cancel subscription' });
  }
};
