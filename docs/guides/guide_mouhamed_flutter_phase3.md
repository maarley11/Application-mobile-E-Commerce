# 🟢 GUIDE FINAL : MOUHAMED — Architecte & Lead Frontend Flutter (PHASE 3)

Bienvenue dans l'ultime ligne droite ! Ton rôle d'Architecte est de superviser l'intégration des 6 dernières maquettes, de consolider le design system, et de connecter l'application au backend finalisé par Ngary.

Ce document fait suite à la Phase 2 (qui s'arrêtait à J6 avec l'Accueil et le Catalogue).

---

## 🏗️ Standards d'Architecture Frontend (Rappel Critique)
- **Design System :** Toutes les couleurs proviennent de `BaanaColors`. Interdiction absolue d'utiliser le Material par défaut.
- **Mockups :** Antigravity doit cibler les chemins précis dans `stitch/` pour garantir zéro hallucination.
- **Routing :** Utilise `GoRouter` pour toutes les navigations (`context.push`, `context.go`).
- **Gestion d'état :** Utilise `Provider` (ex: `AuthProvider`, `CartProvider`).

---

## 🚀 PROMPTS FLUTTER OPTIMISÉS (Phase 3)

Copie-colle ces blocs dans ton assistant Antigravity pour générer le code parfait.

### 📅 J7 & J8 : Tunnel d'achat & Profil Utilisateur (Validation)
*(Note : Ces travaux ont déjà été réalisés par Antigravity, ce prompt est à conserver pour la documentation des PR).*

```text
Finalise le Tunnel d'achat (Panier, Checkout, Confirmation) et les écrans de Profil (User + Dashboard Pro B2B).

⚠️ INSTRUCTION CRITIQUE : Analyse les maquettes suivantes dans `stitch/` :
- `stitch/mon_panier_tape_1_3_390x884/screen.png`
- `stitch/r_capitulatif_tape_2_3_390x884/screen.png`
- `stitch/confirmation_tape_3_3_390x884/screen.png`
- `stitch/paiement_mobile_money_390x884_1/screen.png`
- `stitch/profil_utilisateur_390x884/screen.png`
- `stitch/dashboard_abonn_pro_390x884/screen.png`

Exigences techniques :
- `CartScreen` & `CheckoutScreen` : Utiliser `CartProvider` pour le calcul dynamique des totaux.
- `PaymentMobileMoneyScreen` : Interface simple pour saisir le code OTP opérateur.
- `ProfileScreen` : Afficher dynamiquement le `currentName` et les initiales via `AuthProvider`.
- `DashboardProScreen` : Intégrer les cartes de statistiques (Économies, Commandes, Livraisons).
```

### 📅 J9 : Historique des Commandes & Suivi (Timeline)
```text
Développe les écrans "Historique des commandes" et "Suivi de commande (Timeline)".

⚠️ INSTRUCTION CRITIQUE : Le design doit FORCÉMENT être basé sur les maquettes UI déjà réalisées. Avant d'écrire la moindre ligne de code, tu DOIS :
1. Analyser et reproduire fidèlement les images suivantes :
   - `stitch/historique_des_commandes_clat_solaire_complet/screen.png`
   - `stitch/suivi_de_commande_h_ritage_signature_premium/screen.png`
2. Analyser impérativement le code de `BaanaColors` et `typography.dart`.

Exigences :
1. `OrderHistoryScreen` : Liste des commandes avec un chip coloré pour le statut (En attente, Expédié, Livré).
2. `OrderTrackingScreen` : 
   - Une timeline verticale UI affichant les 4 étapes : "Commande validée", "Préparation", "En cours de livraison", "Livré".
   - Utilise un CustomPaint ou des conteneurs basiques pour dessiner la ligne verticale liant les étapes.
3. Branche ces écrans sur un `OrderProvider` (avec des fausses données `mockOrders` pour l'instant).
```

### 📅 J10 : Abonnement Pro (Comparatif & Paiement)
```text
Développe les écrans de conversion B2B : Le comparatif d'abonnement et la page de paiement.

⚠️ INSTRUCTION CRITIQUE : Analyse et reproduis les maquettes suivantes :
- `stitch/abonnement_pro_nergie_abondance/screen.png` (Comparatif)
- `stitch/paiement_clat_solaire_premium/screen.png` (Paiement)

Exigences :
1. `SubscriptionCompareScreen` : 
   - Affiche les avantages "Membre Pro" avec des icônes de validation vertes.
   - Bouton d'action "Devenir Pro pour 10.000 FCFA/mois".
2. `SubscriptionPaymentScreen` :
   - Interface de choix de la méthode de paiement (Wave, Orange Money) semblable à l'achat classique, mais adaptée à la récurrence (Abonnement mensuel).
```

### 📅 J11 : Notifications & Support WhatsApp
```text
Développe les écrans de Notifications et le Support Client (WhatsApp).

⚠️ INSTRUCTION CRITIQUE : Analyse et reproduis les maquettes suivantes :
- `stitch/notifications_clat_solaire_premium/screen.png`
- `stitch/support_aide_l_artisanat_digital/screen.png`

Exigences :
1. `NotificationScreen` : 
   - Liste simple des notifications (Promotions, Suivi de commande).
   - Différencie visuellement les notifications non lues (fond légèrement teinté `BaanaColors.paleGreen`).
2. `SupportScreen` :
   - Présentation propre de la page d'aide.
   - Intègre le package `url_launcher` pour créer une action qui ouvre l'application WhatsApp (ou le mail) au clic sur le bouton de contact.
```

---

## 🚀 Déploiement & Revues Finales
1. N'oublie pas de continuer à ouvrir des **Pull Requests** (ex: `feat/front-timeline-commande`).
2. **Revue Finale :** Fais une passe sur toute l'application avec la commande `flutter analyze` pour t'assurer qu'aucun lint error ne passe en production.
3. Autorise Ngary à merger.
