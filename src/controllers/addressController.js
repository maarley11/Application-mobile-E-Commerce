const { Address } = require('../models');

// GET /api/addresses — Liste des adresses de l'utilisateur
exports.getAddresses = async (req, res) => {
  try {
    const addresses = await Address.findAll({
      where: { userId: req.user.userId },
      order: [['isDefault', 'DESC'], ['createdAt', 'DESC']],
    });
    return res.status(200).json(addresses);
  } catch (error) {
    console.error('Erreur getAddresses:', error);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
};

// POST /api/addresses — Créer une adresse
exports.createAddress = async (req, res) => {
  const { label, fullAddress, phone, isDefault } = req.body;

  if (!fullAddress) {
    return res.status(400).json({ message: 'fullAddress est obligatoire.' });
  }

  try {
    // Si isDefault = true, mettre les autres à false
    if (isDefault) {
      await Address.update(
        { isDefault: false },
        { where: { userId: req.user.userId } }
      );
    }

    const address = await Address.create({
      userId: req.user.userId,
      label: label || 'Maison',
      fullAddress,
      phone: phone || null,
      isDefault: isDefault || false,
    });

    return res.status(201).json({ message: 'Adresse créée.', address });
  } catch (error) {
    console.error('Erreur createAddress:', error);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
};

// PUT /api/addresses/:id — Modifier une adresse
exports.updateAddress = async (req, res) => {
  const { id } = req.params;
  const { label, fullAddress, phone, isDefault } = req.body;

  try {
    const address = await Address.findOne({
      where: { id, userId: req.user.userId },
    });

    if (!address) {
      return res.status(404).json({ message: 'Adresse introuvable.' });
    }

    if (isDefault) {
      await Address.update(
        { isDefault: false },
        { where: { userId: req.user.userId } }
      );
    }

    address.label = label !== undefined ? label : address.label;
    address.fullAddress = fullAddress !== undefined ? fullAddress : address.fullAddress;
    address.phone = phone !== undefined ? phone : address.phone;
    address.isDefault = isDefault !== undefined ? isDefault : address.isDefault;

    await address.save();
    return res.status(200).json({ message: 'Adresse mise à jour.', address });
  } catch (error) {
    console.error('Erreur updateAddress:', error);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
};

// DELETE /api/addresses/:id — Supprimer une adresse
exports.deleteAddress = async (req, res) => {
  const { id } = req.params;

  try {
    const deleted = await Address.destroy({
      where: { id, userId: req.user.userId },
    });

    if (deleted === 0) {
      return res.status(404).json({ message: 'Adresse introuvable.' });
    }

    return res.status(200).json({ message: 'Adresse supprimée.' });
  } catch (error) {
    console.error('Erreur deleteAddress:', error);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
};
