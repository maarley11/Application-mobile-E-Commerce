const { Category } = require('../models');

// GET /api/categories
exports.getCategories = async (req, res) => {
  try {
    const categories = await Category.findAll({
      order: [['name', 'ASC']]
    });
    return res.status(200).json(categories);
  } catch (error) {
    console.error('Erreur getCategories:', error);
    return res.status(500).json({ message: 'Erreur lors de la récupération des catégories' });
  }
};
