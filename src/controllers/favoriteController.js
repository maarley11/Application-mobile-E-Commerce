const { Favorite, Product, Category } = require('../models');

// GET /api/favorites — Liste des favoris de l'utilisateur
exports.getFavorites = async (req, res) => {
  try {
    const favorites = await Favorite.findAll({
      where: { userId: req.user.userId },
      include: [{
        model: Product,
        include: [{ model: Category, attributes: ['id', 'name'] }],
      }],
      order: [['createdAt', 'DESC']],
    });

    const products = favorites.map(fav => fav.Product).filter(Boolean);
    return res.status(200).json(products);
  } catch (error) {
    console.error('Erreur getFavorites:', error);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
};

// POST /api/favorites — Ajouter un favori
exports.addFavorite = async (req, res) => {
  const { productId } = req.body;
  if (!productId) {
    return res.status(400).json({ message: 'productId est obligatoire.' });
  }

  try {
    const product = await Product.findByPk(productId);
    if (!product) {
      return res.status(404).json({ message: 'Produit introuvable.' });
    }

    const [favorite, created] = await Favorite.findOrCreate({
      where: { userId: req.user.userId, productId },
    });

    if (!created) {
      return res.status(200).json({ message: 'Déjà dans les favoris.', favorite });
    }

    return res.status(201).json({ message: 'Ajouté aux favoris.', favorite });
  } catch (error) {
    console.error('Erreur addFavorite:', error);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
};

// DELETE /api/favorites/:productId — Retirer un favori
exports.removeFavorite = async (req, res) => {
  const { productId } = req.params;

  try {
    const deleted = await Favorite.destroy({
      where: { userId: req.user.userId, productId },
    });

    if (deleted === 0) {
      return res.status(404).json({ message: 'Favori introuvable.' });
    }

    return res.status(200).json({ message: 'Retiré des favoris.' });
  } catch (error) {
    console.error('Erreur removeFavorite:', error);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
};
