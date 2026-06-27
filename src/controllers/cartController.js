const { Cart, CartItem, Product, User } = require('../models');

// GET /api/cart
// Retourne le panier de l'utilisateur connecté
exports.getCart = async (req, res) => {
  try {
    const userId = req.user.userId;
    let cart = await Cart.findOne({
      where: { userId },
      include: [
        {
          model: CartItem,
          include: [{ model: Product, attributes: ['id', 'name', 'imageUrl', 'publicPrice', 'proPrice', 'stock'] }]
        }
      ]
    });

    if (!cart) {
      cart = await Cart.create({ userId });
      // Reload for correct structure
      cart = await Cart.findOne({
        where: { userId },
        include: [
          {
            model: CartItem,
            include: [{ model: Product, attributes: ['id', 'name', 'imageUrl', 'publicPrice', 'proPrice', 'stock'] }]
          }
        ]
      });
    }

    const dbUser = await User.findByPk(userId);
    let subtotal = 0;
    const items = cart.CartItems || [];
    
    const formattedItems = items.map(item => {
      const price = dbUser.isPro ? item.Product.proPrice : item.Product.publicPrice;
      subtotal += price * item.quantity;
      return {
        id: item.id,
        productId: item.productId,
        quantity: item.quantity,
        Product: item.Product,
        appliedPrice: price
      };
    });

    // Calcul de la livraison
    let deliveryFee = 1500;
    if (dbUser.isPro) {
      const freeDeliveriesLeft = Math.max(0, 3 - (dbUser.freeDeliveriesUsedThisWeek || 0)); // On suppose 3 max par semaine
      if (freeDeliveriesLeft > 0) {
        deliveryFee = 0;
      }
    }

    return res.status(200).json({
      id: cart.id,
      userId: cart.userId,
      items: formattedItems,
      subtotal,
      deliveryFee,
      total: subtotal + deliveryFee
    });
  } catch (error) {
    console.error('Erreur getCart:', error);
    return res.status(500).json({ message: 'Erreur lors de la récupération du panier' });
  }
};

// POST /api/cart
// Ajoute un produit au panier
exports.addToCart = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { productId, quantity } = req.body;

    if (!productId || !quantity || quantity < 1) {
      return res.status(400).json({ message: 'Produit ou quantité invalide' });
    }

    const product = await Product.findByPk(productId);
    if (!product) {
      return res.status(404).json({ message: 'Produit introuvable' });
    }

    let cart = await Cart.findOne({ where: { userId } });
    if (!cart) {
      cart = await Cart.create({ userId });
    }

    let cartItem = await CartItem.findOne({
      where: { cartId: cart.id, productId }
    });

    const newQuantity = cartItem ? cartItem.quantity + quantity : quantity;
    if (product.stock < newQuantity) {
      return res.status(400).json({ message: `Stock insuffisant, max disponible: ${product.stock}` });
    }

    if (cartItem) {
      cartItem.quantity = newQuantity;
      await cartItem.save();
    } else {
      await CartItem.create({
        cartId: cart.id,
        productId,
        quantity
      });
    }

    // Retourne le panier mis à jour
    return this.getCart(req, res);
  } catch (error) {
    console.error('Erreur addToCart:', error);
    return res.status(500).json({ message: 'Erreur lors de l\'ajout au panier' });
  }
};

// PUT /api/cart/:itemId
// Met à jour la quantité
exports.updateCartItem = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { itemId } = req.params;
    const { quantity } = req.body;

    if (!quantity || quantity < 1) {
      return res.status(400).json({ message: 'Quantité invalide' });
    }

    const cart = await Cart.findOne({ where: { userId } });
    if (!cart) {
      return res.status(404).json({ message: 'Panier introuvable' });
    }

    const cartItem = await CartItem.findOne({
      where: { id: itemId, cartId: cart.id },
      include: [Product]
    });

    if (!cartItem) {
      return res.status(404).json({ message: 'Item introuvable dans le panier' });
    }

    if (cartItem.Product.stock < quantity) {
      return res.status(400).json({ message: `Stock insuffisant, max disponible: ${cartItem.Product.stock}` });
    }

    cartItem.quantity = quantity;
    await cartItem.save();

    return this.getCart(req, res);
  } catch (error) {
    console.error('Erreur updateCartItem:', error);
    return res.status(500).json({ message: 'Erreur lors de la mise à jour de la quantité' });
  }
};

// DELETE /api/cart/:itemId
// Supprime un item du panier
exports.removeFromCart = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { itemId } = req.params;

    const cart = await Cart.findOne({ where: { userId } });
    if (!cart) {
      return res.status(404).json({ message: 'Panier introuvable' });
    }

    const cartItem = await CartItem.findOne({
      where: { id: itemId, cartId: cart.id }
    });

    if (!cartItem) {
      return res.status(404).json({ message: 'Item introuvable dans le panier' });
    }

    await cartItem.destroy();

    return this.getCart(req, res);
  } catch (error) {
    console.error('Erreur removeFromCart:', error);
    return res.status(500).json({ message: 'Erreur lors de la suppression de l\'item' });
  }
};
