# 🧪 Plan de Test E2E — Application Baana

Ce document décrit les scénarios de test End-to-End (E2E) pour valider le parcours
utilisateur complet de l'application Baana, de l'inscription jusqu'au checkout.

---

## Prérequis

- [ ] Backend Node.js démarré (`node src/server.js` ou `npm start`)
- [ ] Base de données (SQLite/PostgreSQL) initialisée avec les seeds
- [ ] Serveur accessible sur `http://localhost:3000`
- [ ] Application Flutter lancée (`flutter run`)

---

## Parcours 1 : Inscription Client Standard (Visiteur)

| Étape | Action | Résultat Attendu |
|-------|--------|------------------|
| 1.1 | Lancer l'app | Splash Screen s'affiche 2-3 sec, puis redirige vers Onboarding |
| 1.2 | Swiper les 3 slides d'Onboarding | Bouton "Commencer" apparaît sur le dernier slide |
| 1.3 | Appuyer sur "Commencer" | Redirection vers `/register` |
| 1.4 | Saisir : Nom, Téléphone (format Sénégal: 77XXXXXXX) | Formulaire validé localement |
| 1.5 | Laisser NINEA et Boutique vides | Mode "visiteur" (pas Pro) |
| 1.6 | Appuyer sur "S'inscrire" | Appel API `POST /api/auth/register` → Redirection vers `/otp` |
| 1.7 | Saisir le code OTP (4 ou 6 chiffres) | Appel API `POST /api/auth/verify-otp` → Token JWT stocké → Redirection `/home` |

**Vérifications :**
- ✅ Le token JWT est bien stocké dans `flutter_secure_storage`
- ✅ Le header `Authorization: Bearer <token>` est envoyé sur les requêtes suivantes
- ✅ Le nom de l'utilisateur s'affiche dans le profil

---

## Parcours 2 : Inscription Professionnel (Pro)

| Étape | Action | Résultat Attendu |
|-------|--------|------------------|
| 2.1 | Sur `/register`, remplir tous les champs | Nom + Téléphone + NINEA + Nom Boutique + Adresse |
| 2.2 | Appuyer sur "S'inscrire" | Appel API `register` → OTP → Vérification → `updateBusinessProfile` |
| 2.3 | Vérifier sur `/profile` | Le badge "PRO" est visible |

**Vérifications :**
- ✅ `AuthProvider.isPro` est `true`
- ✅ Les prix Pro (`proPrice`) sont affichés dans le catalogue au lieu des `publicPrice`
- ✅ Le Dashboard Pro est accessible

---

## Parcours 3 : Connexion (Utilisateur Existant)

| Étape | Action | Résultat Attendu |
|-------|--------|------------------|
| 3.1 | Depuis `/register`, appuyer sur "J'ai déjà un compte" | Redirection vers `/login` |
| 3.2 | Saisir le téléphone existant | Appel API `POST /api/auth/login` |
| 3.3 | Saisir le code OTP | Token JWT reçu → Redirection `/home` |

---

## Parcours 4 : Navigation Catalogue & Détail Produit

| Étape | Action | Résultat Attendu |
|-------|--------|------------------|
| 4.1 | Sur `/home`, scroller le catalogue | Produits chargés via `ProductProvider.fetchProducts()` |
| 4.2 | Vérifier les `ProductCard` | Image, nom, prix, badge (si applicable) affichés |
| 4.3 | Taper sur une carte produit | Navigation vers `/product/:id` |
| 4.4 | Vérifier l'écran détail | Description complète, prix Pro/Public selon le rôle, stock |
| 4.5 | Appuyer sur "Ajouter au panier" | SnackBar confirmation + Badge compteur sur l'icône panier |

**Vérifications (Pro vs Visiteur) :**
- ✅ Un utilisateur Pro voit `proPrice` (prix barré + prix réduit)
- ✅ Un visiteur voit `publicPrice`

---

## Parcours 5 : Panier & Modification Quantité

| Étape | Action | Résultat Attendu |
|-------|--------|------------------|
| 5.1 | Naviguer vers `/cart` | Liste des produits ajoutés |
| 5.2 | Augmenter la quantité (+) | Total recalculé dynamiquement |
| 5.3 | Diminuer la quantité (→ 0) | Produit retiré du panier |
| 5.4 | Vérifier le sous-total | `CartProvider.subtotalAmount(isPro)` correct |
| 5.5 | Vérifier les frais de livraison | 0 CFA si Pro avec livraisons gratuites, 1500 CFA sinon |
| 5.6 | Appuyer sur "Commander" | Redirection vers `/checkout` |

---

## Parcours 6 : Checkout & Paiement Mobile Money

| Étape | Action | Résultat Attendu |
|-------|--------|------------------|
| 6.1 | Sur `/checkout`, vérifier le récapitulatif | Articles, quantités, prix unitaires, total |
| 6.2 | Sélectionner "Mobile Money" | Navigation vers `/payment_mobile_money` |
| 6.3 | Confirmer le paiement | Appel API `POST /api/orders` avec `paymentMethod: 'MOBILE_MONEY'` |
| 6.4 | Réponse `201 Created` | SnackBar "Commande créée avec succès" + Redirection `/confirmation` |
| 6.5 | Vérifier le stock (côté backend) | Le stock du produit a été décrémenté |

**Tests d'erreur :**
- ❌ Commander un produit hors stock → SnackBar "Stock insuffisant pour le produit: X"
- ❌ Envoyer `paymentMethod: 'BITCOIN'` → Rejet 400 "Méthode de paiement invalide"

---

## Parcours 7 : Dashboard Pro

| Étape | Action | Résultat Attendu |
|-------|--------|------------------|
| 7.1 | Naviguer vers `/dashboard_pro` | Appel API `GET /api/dashboard/pro` |
| 7.2 | Vérifier `totalOrders` | Nombre exact de commandes passées |
| 7.3 | Vérifier `totalSpent` | Somme des montants (en `parseFloat`, pas `parseInt`) |
| 7.4 | Vérifier `savings` | Économie = Σ (publicPrice - proPrice) × quantité |
| 7.5 | Vérifier `freeDeliveriesLeft` | 3 - commandes de la semaine (min 0) |
| 7.6 | Vérifier `loyaltyPoints` | Égal au nombre de commandes complétées |

**Test d'erreur :**
- ❌ Accéder en tant que visiteur → 403 "Accès interdit. Réservé aux abonnés Pro."

---

## 🔴 Cas Limites Critiques

| Scénario | Test | Résultat Attendu |
|----------|------|------------------|
| Panier vide | POST /api/orders avec `items: []` | 400 "Le panier est vide" |
| Token expiré | Requête avec JWT invalide | 401 → Token supprimé → Redirection login |
| Réseau coupé | Couper le backend | SnackBar d'erreur, pas de crash |
| Double commande | Deux clics rapides sur "Commander" | Une seule commande créée (lock SQL) |
