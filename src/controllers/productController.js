const { Product, Category } = require('../models');
const { Op } = require('sequelize');
const crypto = require('crypto');
const multer = require('multer');
const sharp = require('sharp');
const path = require('path');
const fs = require('fs');

// Configuration de multer (stockage en mémoire temporaire)
const storage = multer.memoryStorage();
exports.upload = multer({ storage });

// GET /api/products?search=...&category=...&minPrice=...&maxPrice=...&page=1&limit=20
exports.getProducts = async (req, res) => {
  try {
    const { search, category, minPrice, maxPrice, page = 1, limit = 20 } = req.query;

    const where = {};
    const includeOptions = [{ model: Category, attributes: ['id', 'name'] }];

    // 1. Recherche Full-Text (dans name ou description)
    if (search) {
      const likeOp = Op.iLike; // iLike = insensible à la casse dans PostgreSQL
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

    const responseData = {
      totalProducts: count,
      totalPages: Math.ceil(count / limitNum),
      currentPage: pageNum,
      products: rows,
    };

    const etag = crypto.createHash('md5').update(JSON.stringify(responseData)).digest('hex');
    res.setHeader('Cache-Control', 'public, max-age=300');
    res.setHeader('ETag', `"${etag}"`);

    if (req.headers['if-none-match'] === `"${etag}"`) {
      return res.status(304).send();
    }

    return res.status(200).json(responseData);
  } catch (error) {
    console.error('Erreur getProducts:', error);
    return res.status(500).json({ message: 'Erreur lors de la recherche des produits' });
  }
};

// GET /api/products/:id
exports.getProductById = async (req, res) => {
  try {
    const { id } = req.params;
    const product = await Product.findByPk(id, {
      include: [{ model: Category, attributes: ['id', 'name'] }]
    });

    if (!product) {
      return res.status(404).json({ message: 'Produit introuvable' });
    }

    res.setHeader('Cache-Control', 'public, max-age=600');
    return res.status(200).json(product);
  } catch (error) {
    console.error('Erreur getProductById:', error);
    return res.status(500).json({ message: 'Erreur lors de la récupération du produit' });
  }
};

// POST /api/products/:id/images
exports.uploadProductImage = async (req, res) => {
  try {
    // Vérification du rôle Admin
    if (!req.user || !req.user.isAdmin) {
      return res.status(403).json({ message: 'Accès interdit. Réservé aux administrateurs.' });
    }

    const { id } = req.params;
    const product = await Product.findByPk(id);

    if (!product) {
      return res.status(404).json({ message: 'Produit introuvable' });
    }

    if (!req.file) {
      return res.status(400).json({ message: 'Aucun fichier fourni' });
    }

    const { v4: uuidv4 } = require('uuid');
    const uniqueId = uuidv4();
    
    // S'assurer que le dossier uploads existe
    const uploadDir = path.join(__dirname, '../../uploads');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }

    const originalFilename = `${uniqueId}-original.webp`;
    const thumbFilename = `${uniqueId}-thumb.webp`;

    const originalPath = path.join(uploadDir, originalFilename);
    const thumbPath = path.join(uploadDir, thumbFilename);

    // Image compressée originale (max 800x800)
    await sharp(req.file.buffer)
      .resize(800, 800, { fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 80 })
      .toFile(originalPath);

    // Miniature (200x200)
    await sharp(req.file.buffer)
      .resize(200, 200, { fit: 'cover' })
      .webp({ quality: 80 })
      .toFile(thumbPath);

    // Créer des URLs
    const originalUrl = `/uploads/${originalFilename}`;
    const thumbUrl = `/uploads/${thumbFilename}`;

    product.imageUrl = originalUrl;
    await product.save();

    return res.status(200).json({
      message: 'Image uploadée et compressée avec succès',
      urls: {
        original: originalUrl,
        thumbnail: thumbUrl,
      }
    });
  } catch (error) {
    console.error('Erreur uploadProductImage:', error);
    return res.status(500).json({ message: 'Erreur lors de l\'upload de l\'image' });
  }
};
