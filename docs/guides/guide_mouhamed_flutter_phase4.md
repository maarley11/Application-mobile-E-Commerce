# 🔵 GUIDE AVANCÉ : MOUHAMED — Architecte Flutter (PHASE 4)

Salut Mouhamed ! Les fondations UI et la logique d'état (Providers) sont désormais 100% conformes au Cahier des Charges. Ton architecture est en place.

Nous passons à la **Phase 4 : Intégration API & Temps Réel**.
Ici, nous allons abandonner les données "mockées" et connecter l'application au vrai Backend Node.js que Ngary est en train de finaliser.

Nous allons travailler ensemble sur l'implémentation de ces tâches, étape par étape.

---

## 🚀 LES MISSIONS FLUTTER (Phase 4)

### 📅 J11 : Remplacement des Mocks par l'API Réelle (Dio / HTTP)
Tes `Providers` gèrent parfaitement l'état. Maintenant, il faut qu'ils parlent au serveur.

**Ce que nous allons implémenter :**
1. **Configuration d'un client HTTP (`Dio` ou `http`) :**
   - Création d'un `api_client.dart` avec gestion du Token JWT (Interceptors pour injecter le token dans le Header).
2. **`AuthProvider` :**
   - Connecter l'envoi de l'OTP et la vérification au vrai backend.
   - Stocker le JWT reçu via `flutter_secure_storage`.
3. **`ProductProvider` & `OrderProvider` :**
   - Remplacer les listes de test par des requêtes `GET /api/products` et `GET /api/orders`.

### 📅 J12 : Intégration des Paiements Mobile Money
La phase critique du e-commerce : le checkout final.

**Ce que nous allons implémenter :**
1. Lors du clic sur "Payer" dans `checkout_screen`, on fera un appel à `POST /api/orders` au backend.
2. Le backend va renvoyer une URL de paiement (agrégateur type Wave/PayDunya).
3. On ouvrira cette URL via un `WebView` interne ou `url_launcher`.
4. Une fois le paiement réussi (grâce au webhook géré par Ngary), on rafraîchira la page pour afficher "Commande Confirmée".

### 📅 J13 : Notifications Push (Firebase Cloud Messaging)
L'utilisateur doit être alerté quand sa commande est expédiée.

**Ce que nous allons implémenter :**
1. Configuration de **Firebase** dans le projet Flutter (Android & iOS).
2. Installation du package `firebase_messaging`.
3. Récupération du `FCM Token` au lancement de l'application et envoi au backend (via `AuthProvider`).
4. Écoute des notifications en arrière-plan et au premier plan (mise à jour de l'écran `notifications_screen.dart` en temps réel).

---

## 🛠️ Notre Plan d'Action pour l'Implémentation

Puisque nous collaborons avec l'agent IA, voici comment nous allons procéder pour implémenter tout ça ensemble :

1. **On commence par J11 (Client HTTP)** : Nous allons créer le service réseau sécurisé.
2. **On modifie les Providers un par un** : D'abord l'Auth, puis les Produits, puis les Commandes.
3. **Tests sur simulateur** : On vérifie que la connexion avec ton backend local (Node.js) fonctionne.

Es-tu prêt à démarrer la configuration du client API pour connecter notre application ?
