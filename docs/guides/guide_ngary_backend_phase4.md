# 🟢 GUIDE AVANCÉ : NGARY — Développeur Backend Node.js (PHASE 4)

Salut Ngary, super travail sur la **Phase 3** ! 
Puisque tu as déjà implémenté avec succès les webhooks Mobile Money, la logique d'abonnement "Membre Pro", le cron job de remise à zéro des livraisons, et les endpoints analytiques du Dashboard, notre API est maintenant très solide.

Nous entrons dans la **Phase 4 : Notifications, Facturation & Mises en production**. 
L'objectif est d'ajouter les couches de communication avec l'utilisateur et de finaliser les flux transactionnels.

---

## 🚀 PROMPTS NODE.JS OPTIMISÉS (Phase 4)

### 📅 J11 : Système de Notifications Push & In-App
L'application Flutter a maintenant un écran "Notifications". Il faut que l'API génère ces alertes.

```text
Développe le système de Notifications pour l'API Baana (Push & In-App).

⚠️ INSTRUCTION CRITIQUE : Les notifications doivent être stockées en base (In-App) ET envoyées via Firebase Admin SDK (Push).

Exigences :
1. Modèle `Notification` : `userId`, `title`, `body`, `type` (ORDER, PROMO, SYSTEM), `isRead` (boolean, default false).
2. Firebase Admin SDK : Configure l'envoi de push notifications vers les tokens des devices utilisateurs (ajoute un champ `fcmToken` au modèle User).
3. Route `GET /api/notifications` : Liste les notifications de l'utilisateur connecté (triées par date décroissante).
4. Route `PUT /api/notifications/read-all` : Marque toutes les notifications de l'utilisateur comme lues.
5. Déclencheurs automatiques : Lorsqu'une commande passe à 'DELIVERED', crée une notification. Lorsqu'un utilisateur gagne des points de fidélité, crée une notification.
```

### 📅 J12 : Génération de Factures PDF & Envoi d'Emails
Les PME (Membres Pro) ont besoin de factures pour leur comptabilité.

```text
Développe un générateur de Factures PDF et un service d'envoi d'emails pour Baana.

⚠️ INSTRUCTION CRITIQUE : Utilise `pdfkit` ou `puppeteer` pour la génération, et `nodemailer` pour l'envoi.

Exigences :
1. Route `GET /api/orders/:id/invoice` : Génère et renvoie un fichier PDF contenant les détails de la commande, la TVA (si applicable), et le montant total (avec ou sans frais de livraison).
2. Service Email : Lorsqu'une commande est 'PAID' via le webhook de la Phase 3, envoie automatiquement un email récapitulatif de la commande au client (ajoute un champ `email` au User si ce n'est pas déjà fait).
```

### 📅 J13 : Points de Fidélité & Intégration SMS (OTP Réel)
Passage du mode "Mock" au mode réel pour l'inscription.

```text
Finalise l'authentification OTP et implémente la mécanique des points de fidélité.

Exigences :
1. Service SMS : Intègre un vrai fournisseur de SMS (ex: Twilio, InfoBip, ou un agrégateur local comme Orange SMS API) dans la route de demande d'OTP.
2. Points de fidélité : Modifie le contrôleur de Webhook (Phase 3). Lorsqu'une commande est validée (PAID), ajoute `Math.floor(totalAmount / 1000)` points de fidélité au User (ex: 1 point tous les 1000 FCFA dépensés).
```

---

## 🔍 Ta Checklist Quotidienne
1. **Clés d'API :** Mets à jour le fichier `.env.example` avec les nouvelles clés (Firebase, SMTP, SMS).
2. **Postman :** Ajoute ces nouvelles routes à la collection partagée de l'équipe.
3. **Revue :** Prépare ta Pull Request `feat/back-phase4` pour la validation.
