# 📋 Rapport V2 : Fonctionnalités non implémentées (UI Placholders)

Salut Ngary et Youssouf,

Suite aux tests effectués sur l'application mobile déployée, voici le rapport concernant les fonctionnalités que vous avez remontées. 
**Aucune de ces fonctionnalités n'est buggée.** Elles ont simplement été développées sous forme de **maquettes d'interface (UI placeholders)** côté Flutter, sans la logique sous-jacente ni les routes API correspondantes. 

Elles sont donc officiellement reportées pour la **Version 2 (V2)** de l'application.

Voici la liste des fonctionnalités à développer en V2 :

## 1. 🔍 Filtre de l'accueil
- **État actuel :** L'icône de filtre sur l'accueil est cliquable mais ne déclenche aucune action.
- **À faire en V2 :** 
  - *Backend :* Ajouter des query parameters sur `GET /api/products` (ex: `?priceMin=X&priceMax=Y&sortBy=price_desc`).
  - *Flutter :* Créer un écran/modal de filtres avancés et intégrer la logique de rafraîchissement du catalogue.

## 2. ❤️ Bouton Favoris
- **État actuel :** Le bouton coeur est présent sur les cartes produits mais l'état n'est pas sauvegardé.
- **À faire en V2 :** 
  - *Backend :* Créer un modèle `Favorite` et des routes `POST /api/favorites` / `DELETE /api/favorites/:productId`.
  - *Flutter :* Ajouter un `FavoritesProvider` pour gérer l'état local et faire les appels API.

## 3. 🔄 Bouton "Recommander" (Historique des commandes)
- **État actuel :** Le bouton dans l'historique des commandes ne fait rien.
- **À faire en V2 :** 
  - *Flutter :* Récupérer les items de la commande passée et faire un appel boucle (ou un endpoint spécial) pour les ajouter directement au panier existant via `CartProvider`.

## 4. 📍 Section "Adresse" dans le profil
- **État actuel :** L'option est listée mais l'écran n'existe pas.
- **À faire en V2 :** 
  - *Backend :* Route CRUD pour les adresses multiples (`GET/POST/PUT/DELETE /api/users/addresses`).
  - *Flutter :* Créer l'écran `AddressesScreen` pour gérer la liste des adresses sauvegardées (Maison, Bureau, etc.).

## 5. 🧾 Section "Factures" dans le profil
- **État actuel :** L'option ne s'ouvre pas.
- **À faire en V2 :** 
  - *Backend :* Comme prévu dans la Phase 7, terminer l'endpoint de génération PDF `GET /api/orders/:id/invoice`.
  - *Flutter :* Créer un écran listant toutes les commandes facturées avec un bouton pour télécharger/visualiser le PDF.

## 6. 🎧 Support technique / "Besoin d'aide" (Chat)
- **État actuel :** Le bouton ne mène pas à un chat en temps réel.
- **À faire en V2 :** 
  - *Backend :* Intégrer WhatsApp API ou un système de WebSockets pour un vrai chat de support.
  - *Flutter :* Rediriger via `url_launcher` vers un numéro WhatsApp ou créer un écran de chat in-app.

## 7. 🎓 Guide "Apprendre à vendre"
- **État actuel :** Lien inactif.
- **À faire en V2 :** 
  - *Flutter/CMS :* Créer une section éducative (articles, vidéos YouTube embarquées) pour les commerçants Pros.

## 8. 🚚 Suivi des livraisons (depuis le menu)
- **État actuel :** Le bouton du menu ne s'ouvre pas.
- **À faire en V2 :** 
  - *Flutter :* Créer un écran centralisé `DeliveryTrackingScreen` qui liste les commandes "En cours" avec une carte temps réel (ou accès direct à leur statut sans passer par l'historique complet).

## 9. 🌓 Paramètres : Mode sombre & Langue
- **État actuel :** Les paramètres UI existent mais le thème et la langue ne changent pas.
- **À faire en V2 :** 
  - *Flutter :* Utiliser `provider` ou `shared_preferences` pour sauvegarder la `ThemeMode` et la `Locale` (ex: `flutter_localizations`), puis reconstruire l'app globale.

---

> **Conclusion :** Ces éléments ne bloquent pas le flux critique de la V1 (S'inscrire -> Ajouter au panier -> Payer -> Suivre la commande). Le dossier "Images" a bien été rajouté sur GitHub, ce qui corrigera les problèmes d'images manquantes. 

L'équipe peut valider le déploiement actuel pour la V1 ! 🎉
