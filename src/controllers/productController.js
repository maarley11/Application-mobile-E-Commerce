const { Product, Category } = require('../models');
const { Op } = require('sequelize');

// GET /api/products?search=...&category=...&minPrice=...&maxPrice=...&page=1&limit=20
exports.getProducts = async (req, res) => {
  try {
    const { search, category, minPrice, maxPrice, page = 1, limit = 20 } = req.query;

    const where = {};
    const includeOptions = [{ model: Category, attributes: ['id', 'name'] }];

    // 1. Recherche Full-Text (dans name ou description)
    if (search) {
      const likeOp = Op.iLike; // iLike = insensible à la casse (PostgreSQL)
      where[Op.or] = [
        { name: { [likeOp]: `%${search}%` } },
        { description: { [likeOp]: `%${search}%` } },
      ];
    }

    // 2. Filtre par Prix
    if (minPrice || maxPrice) {
      where.publicPrice = {};
      if (minPrice) where.publicPrice[Op.gte] = parseInt(minPrice, 10);
      if (maxPrice) where.publicPrice[Op.lte] = parseInt(maxPrice, 10);
    }

    // 3. Filtre par Catégorie (via le nom de la catégorie)
    if (category) {
      includeOptions[0].where = { name: { [Op.iLike]: `%${category}%` } };
      includeOptions[0].required = true; // INNER JOIN
    }

    // 4. Pagination
    const pageNum = Math.max(1, parseInt(page, 10));
    const limitNum = Math.min(50, parseInt(limit, 10)); // max 50 résultats par page
    const offset = (pageNum - 1) * limitNum;

    const { count, rows } = await Product.findAndCountAll({
      where,
      include: includeOptions,
      limit: limitNum,
      offset,
      order: [['createdAt', 'DESC']],
    });

    return res.status(200).json({
      totalProducts: count,
      totalPages: Math.ceil(count / limitNum),
      currentPage: pageNum,
      products: rows,
    });
  } catch (error) {
    console.error('Erreur getProducts:', error);
    return res.status(500).json({ message: 'Erreur lors de la recherche des produits' });
  }
};
