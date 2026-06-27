/**
 * Contrôleur de génération de factures PDF
 * GET /api/orders/:id/invoice
 *
 * Génère un PDF professionnel pour une commande avec :
 * - En-tête BAANA
 * - Informations client (+ NINEA si utilisateur Pro)
 * - Tableau des articles
 * - Total et méthode de paiement
 * - Pied de page avec numéro de commande
 *
 * Note : Nécessite "npm install pdfkit"
 */

const { Order, OrderItem, Product, User } = require('../models');

// Tentative de chargement de pdfkit
let PDFDocument;
try {
  PDFDocument = require('pdfkit');
} catch (e) {
  PDFDocument = null;
}

exports.generateInvoice = async (req, res) => {
  // Vérifier si pdfkit est installé
  if (!PDFDocument) {
    return res.status(501).json({
      message: 'La génération de PDF nécessite "npm install pdfkit". Dépendance non installée.',
    });
  }

  try {
    // Récupérer la commande avec ses articles et le client
    const order = await Order.findOne({
      where: { id: req.params.id, userId: req.user.userId },
      include: [
        {
          model: OrderItem,
          include: [{ model: Product, attributes: ['name', 'publicPrice', 'proPrice'] }],
        },
      ],
    });

    if (!order) {
      return res.status(404).json({ message: 'Commande introuvable ou accès refusé.' });
    }

    const user = await User.findByPk(req.user.userId);

    // ── Créer le document PDF ────────────────────────────────────────
    const doc = new PDFDocument({ margin: 50, size: 'A4' });

    // En-têtes HTTP pour téléchargement du fichier
    const filename = `Facture_Baana_${order.orderNumber || order.id}.pdf`;
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);

    // Pipe le PDF directement vers la réponse HTTP
    doc.pipe(res);

    // ── COULEURS & STYLES ─────────────────────────────────────────────
    const PRIMARY  = '#1A7F5E'; // Vert Baana
    const DARK     = '#1A1A2E';
    const GRAY     = '#6B7280';
    const LIGHT_BG = '#F3F4F6';

    // ── EN-TÊTE : Logo et titre ───────────────────────────────────────
    doc
      .fillColor(PRIMARY)
      .fontSize(28)
      .font('Helvetica-Bold')
      .text('BAANA', 50, 50);

    doc
      .fillColor(GRAY)
      .fontSize(10)
      .font('Helvetica')
      .text('Marketplace de gros — Dakar, Sénégal', 50, 82)
      .text('contact@baana.sn  |  +221 33 XXX XX XX', 50, 95);

    // Titre FACTURE à droite
    doc
      .fillColor(DARK)
      .fontSize(22)
      .font('Helvetica-Bold')
      .text('FACTURE', 400, 50, { align: 'right' });

    doc
      .fillColor(GRAY)
      .fontSize(10)
      .font('Helvetica')
      .text(`N° ${order.orderNumber || order.id}`, 400, 78, { align: 'right' })
      .text(`Date : ${new Date(order.createdAt).toLocaleDateString('fr-FR')}`, 400, 91, { align: 'right' });

    // Ligne de séparation
    doc.moveTo(50, 130).lineTo(545, 130).strokeColor(PRIMARY).lineWidth(2).stroke();

    // ── INFORMATIONS CLIENT ───────────────────────────────────────────
    doc
      .fillColor(DARK)
      .fontSize(12)
      .font('Helvetica-Bold')
      .text('Facturé à :', 50, 150);

    doc
      .fillColor(DARK)
      .fontSize(11)
      .font('Helvetica')
      .text(user.name || 'Client Baana', 50, 168)
      .text(`Tél : ${user.phone}`, 50, 183);

    if (user.isPro) {
      doc.fillColor(PRIMARY).font('Helvetica-Bold').text('[CLIENT PRO]', 50, 198);
      if (user.businessName) doc.fillColor(DARK).font('Helvetica').text(`Entreprise : ${user.businessName}`, 50, 213);
      if (user.ninea)        doc.fillColor(DARK).font('Helvetica').text(`NINEA : ${user.ninea}`, 50, 228);
    }

    // Informations commande à droite
    doc
      .fillColor(DARK)
      .fontSize(12)
      .font('Helvetica-Bold')
      .text('Détails de la commande :', 350, 150);

    doc
      .fillColor(DARK)
      .fontSize(11)
      .font('Helvetica')
      .text(`Statut : ${order.status}`, 350, 168)
      .text(`Paiement : ${order.paymentMethod}`, 350, 183);

    // ── TABLEAU DES ARTICLES ──────────────────────────────────────────
    const tableTop = user.isPro ? 270 : 240;

    // En-tête du tableau
    doc.fillColor(PRIMARY).rect(50, tableTop, 495, 24).fill();
    doc
      .fillColor('#FFFFFF')
      .fontSize(10)
      .font('Helvetica-Bold')
      .text('ARTICLE',    60,  tableTop + 7)
      .text('QTÉ',       330,  tableTop + 7, { width: 50, align: 'center' })
      .text('PRIX UNIT.', 390, tableTop + 7, { width: 80, align: 'right' })
      .text('SOUS-TOTAL', 475, tableTop + 7, { width: 70, align: 'right' });

    // Lignes des articles
    let y = tableTop + 30;
    const items = order.OrderItems || order.orderItems || [];

    items.forEach((item, index) => {
      const bg = index % 2 === 0 ? '#FFFFFF' : LIGHT_BG;
      doc.fillColor(bg).rect(50, y - 4, 495, 22).fill();

      const productName = item.Product?.name || `Produit #${item.productId}`;
      const unitPrice   = item.unitPrice;
      const subtotal    = unitPrice * item.quantity;

      doc
        .fillColor(DARK)
        .fontSize(10)
        .font('Helvetica')
        .text(productName,               60,  y, { width: 260 })
        .text(String(item.quantity),     330,  y, { width: 50, align: 'center' })
        .text(`${unitPrice.toLocaleString('fr-FR')} FCFA`, 390, y, { width: 80, align: 'right' })
        .text(`${subtotal.toLocaleString('fr-FR')} FCFA`,  475, y, { width: 70, align: 'right' });

      y += 24;
    });

    // Ligne de séparation après le tableau
    doc.moveTo(50, y + 5).lineTo(545, y + 5).strokeColor(GRAY).lineWidth(0.5).stroke();
    y += 15;

    // ── TOTAL ─────────────────────────────────────────────────────────
    // Livraison
    const deliveryFee = user.isPro ? 0 : 1500;
    doc
      .fillColor(GRAY).fontSize(10).font('Helvetica')
      .text('Frais de livraison :', 350, y)
      .text(deliveryFee === 0 ? 'OFFERTS (Pro)' : `${deliveryFee.toLocaleString('fr-FR')} FCFA`, 475, y, { width: 70, align: 'right' });
    y += 18;

    // Total final
    const grandTotal = order.totalAmount + deliveryFee;
    doc.fillColor(PRIMARY).rect(350, y - 4, 195, 26).fill();
    doc
      .fillColor('#FFFFFF')
      .fontSize(12)
      .font('Helvetica-Bold')
      .text('TOTAL TTC :', 360, y + 2)
      .text(`${grandTotal.toLocaleString('fr-FR')} FCFA`, 475, y + 2, { width: 60, align: 'right' });

    // ── PIED DE PAGE ──────────────────────────────────────────────────
    doc
      .moveTo(50, 760).lineTo(545, 760).strokeColor(GRAY).lineWidth(0.5).stroke()
      .fillColor(GRAY)
      .fontSize(9)
      .font('Helvetica')
      .text(
        `Baana — Facture N° ${order.orderNumber || order.id} — Générée le ${new Date().toLocaleDateString('fr-FR')} — Merci pour votre confiance !`,
        50, 768, { align: 'center' }
      );

    // Finaliser le PDF
    doc.end();

  } catch (error) {
    console.error('Erreur génération facture :', error);
    // Si le PDF a déjà commencé à s'écrire, on ne peut plus envoyer un JSON
    if (!res.headersSent) {
      res.status(500).json({ message: 'Erreur lors de la génération de la facture.' });
    }
  }
};
