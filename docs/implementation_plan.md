# 🚀 Plan Phase 2→5 — Développement Complet de Baana

> **Projet :** SEN DIGITAL PULSE — Application Baana
> **Phases :** 2 (Backend API) + 3 (Frontend Flutter) + 4 (Tests QA) + 5 (Lancement)
> **Deadline :** 28 juin 2026 (18 jours restants)
> **Stratégie :** Tout en parallèle — intégration continue

---

## 👥 Équipe Phase 2→5

| Rôle | Nom | Responsabilité |
|---|---|---|
| **Architecte / Chef de projet + Frontend Flutter** | **Mouhamed Youssouf Dioum** (toi) | Architecture globale, design des API, Frontend Flutter, supervision et assistance Backend de Ngary, revues de code, décisions techniques |
| **Développeur Backend** | **Ngary Diop** | Exécution Backend Node.js + Express + PostgreSQL sous la supervision de Mouhamed |
| Superviseur | Ababacar Koundoul | Coordinateur de stage |
| Commanditaire | Boubacar A. Traoré | DG SEN DIGITAL PULSE |

> [!NOTE]
> **Mouhamed est l'architecte du projet.** Il conçoit l'architecture, définit le contrat d'API, fait les revues de code de Ngary, et l'assiste sur les parties backend complexes (auth JWT, logique d'abonnement, intégration paiement). Il est responsable du Frontend ET garant de la qualité du Backend.

---

## 📋 Rappel du Cahier des Charges

Source : [CahierDesCharges SDP.docx](file:///c:/Users/ASUS/Application-mobile-E-Commerce/CahierDesCharges%20SDP.docx)

| Composant | Choix technique (CDC) |
|---|---|
| Frontend mobile | **Flutter** — une seule base Android + iOS |
| Backend / API | **Node.js + PostgreSQL** — REST léger, performant sur 3G |
| Passerelle paiement | PayDunya / TouchPay / Intouch (Wave, OM, Free Money) |
| Hébergement | AWS / DigitalOcean / OVHcloud |
| Notifications | Firebase Cloud Messaging (Push) + SMS agrégateur local |
| Géolocalisation | Google Maps API / OpenStreetMap |

### Exigences non-fonctionnelles (CDC)
- Cache produits pour navigation fluide en 3G
- Compression images + chargement progressif
- Mode offline partiel (catalogue consultable sans connexion)
- HTTPS/TLS, OTP SMS (pas de mot de passe), sauvegardes quotidiennes
- Boutons larges, textes courts, français courant
- Scalable de 100 à 10 000 abonnés

---

## 📅 Planning Condensé (18 jours)

```
10 juin ──────────────────────────────────────────── 28 juin
│      PHASE 2+3 en parallèle (J1-J10)            │ INTEG │ QA  │ LAUNCH │
│  Mouhamed: Flutter + Architecture + Assist Back  │ J11-13│J14-16│ J17-18 │
│  Ngary:    Backend (sous supervision Mouhamed)   │       │      │        │
```

| Phase | Jours | Dates | Contenu |
|---|---|---|---|
| **Phase 2+3** | J1 → J10 | 11 → 22 juin | Backend + Frontend **en parallèle** |
| **Intégration** | J11 → J13 | 23 → 25 juin | Connexion API ↔ Flutter, données réelles |
| **Phase 4** | J14 → J16 | 25 → 27 juin | Tests terrain Dakar, Mobile Money, appareils |
| **Phase 5** | J17 → J18 | 27 → 28 juin | Build final, Play Store, lancement |

---

## User Review Required

> [!IMPORTANT]
> **Choix techniques validés :**
> - ✅ Flutter (fidèle au CDC)
> - ✅ PostgreSQL (fidèle au CDC)
> - ✅ Node.js + Express (fidèle au CDC)
> - ✅ Parallélisation totale dès J1

> [!WARNING]
> **Points critiques :**
> 1. Pendant J1-J10, Mouhamed travaille avec des **données mockées** dans Flutter. L'intégration API réelle se fait J11-J13.
> 2. Ngary doit avoir un environnement PostgreSQL fonctionnel **dès J1**.
> 3. **Mouhamed définit le contrat d'API J1** et le partage avec Ngary — c'est la référence commune.
> 4. **Mouhamed fait une revue de code quotidienne** (30 min) du travail de Ngary et l'assiste sur les parties complexes.
> 5. Pour les modules critiques (Auth JWT, paiement, abonnements), **Mouhamed peut pair-coder avec Ngary** ou lui fournir le squelette de code.

---

## Open Questions

> [!IMPORTANT]
> 1. **Ngary maîtrise-t-il Node.js et PostgreSQL ?** Sinon, le guide inclut tout le nécessaire pour démarrer.
> 2. **Hébergement backend :** Render (gratuit), Railway, ou DigitalOcean ? Le déploiement J17 en dépend.
> 3. **PayDunya vs CinetPay :** Avez-vous déjà un compte ? Il faut un merchant ID pour l'intégration paiement.
> 4. **Firebase :** Avez-vous un projet Firebase existant pour les notifications Push ?
> 5. **Compte Google Play :** Avez-vous un compte développeur Play Store (25$ one-time) ?

---

# 📐 CONTRAT D'API — Conçu par Mouhamed (Architecte), implémenté par Ngary

Ce contrat est la **référence commune** conçue par Mouhamed en tant qu'architecte du projet. Mouhamed code son Flutter avec ces structures JSON en mock, et Ngary implémente le backend pour les respecter. **Toute modification du contrat doit être validée par Mouhamed.**

## Auth
```
POST /api/auth/register       → { phone: "+221XXXXXXXXX" }
                              ← { message, userId }

POST /api/auth/verify-otp     → { phone, code: "1234" }
                              ← { token, user: { id, phone, name, role, subscription } }

POST /api/auth/login          → { phone }
                              ← { message: "OTP envoyé" }

GET  /api/auth/me             → [Header: Authorization: Bearer <token>]
                              ← { user }
```

## Produits
```
GET  /api/products             → ?category=&search=&page=&limit=&sort=
                               ← { products: [...], total, page, pages }

GET  /api/products/:id         ← { product: { id, name, description, publicPrice, 
                                    proPrice, images, category, stock, badge } }

GET  /api/categories           ← { categories: [{ id, name, icon }] }
```

## Panier
```
GET    /api/cart                ← { items: [{ product, quantity, price }], 
                                    subtotal, delivery, total }
POST   /api/cart                → { productId, quantity }
PUT    /api/cart/:itemId        → { quantity }
DELETE /api/cart/:itemId
```

## Commandes
```
POST   /api/orders              → { items, deliveryAddress, paymentMethod }
                                ← { order: { id, orderNumber, status, timeline } }

GET    /api/orders              ← { orders: [...] }
GET    /api/orders/:id          ← { order: { ..., timeline: [...], deliveryPerson } }
```

## Abonnements
```
GET    /api/subscriptions/plans  ← { plans: [{ id, name, price, duration, benefits }] }
POST   /api/subscriptions        → { planId, paymentMethod }
GET    /api/subscriptions/me     ← { subscription: { plan, status, expiresAt, 
                                      freeDeliveriesLeft } }
PUT    /api/subscriptions/renew  → { paymentMethod }
```

## Dashboard & Profil
```
GET    /api/dashboard            ← { savings, ordersThisMonth, freeDeliveriesLeft,
                                     loyaltyPoints, recentOrders }

GET    /api/users/me             ← { user }
PUT    /api/users/me             → { name, businessName, address }

GET    /api/notifications        ← { notifications: [...] }
PUT    /api/notifications/read-all
```

---

# 📘 PHASE 2+3 — DÉVELOPPEMENT PARALLÈLE (J1 → J10)

---

## 🟢 GUIDE MOUHAMED — Architecte : Frontend Flutter + Supervision Backend (J1 → J10)

### 🏗️ Ton double rôle au quotidien

En tant qu'architecte, ta journée type se découpe ainsi :

| Créneau | Activité | Durée |
|---|---|---|
| **Matin** | Frontend Flutter — coder tes écrans | ~3h |
| **Début d'après-midi** | 🔍 Revue du code backend de Ngary + assistance | 30-45 min |
| **Après-midi** | Frontend Flutter (suite) | ~2h |
| **Fin de journée** | 📋 Point rapide avec Ngary : blocages, prochaines étapes | 15 min |

### 🏗️ Tes responsabilités d'architecte sur le backend

| Tâche architecte | Quand | Comment |
|---|---|---|
| **Définir le contrat d'API** | J1 | Tu conçois TOUS les endpoints, formats JSON, codes d'erreur |
| **Fournir les prompts backend à Ngary** | Chaque jour | Tu lui donnes les prompts Gemini pré-rédigés de ce guide |
| **Revue de code quotidienne** | Chaque après-midi (30 min) | `git pull` la branche de Ngary, vérifier la logique, les validations, la sécurité |
| **Débloquer Ngary** | En continu | S'il est bloqué sur un bug, une config, ou un concept → tu l'assistes |
| **Pair-coding modules critiques** | J3-J4 (Auth), J7-J8 (Paiement) | Les modules sensibles (JWT, paiement) → tu codes avec lui ou tu lui fournis le squelette |
| **Valider chaque endpoint** | Avant intégration | Tester dans Postman que l'API respecte le contrat |

### 📋 Checklist architecte — À vérifier dans le code de Ngary

```
□ Validation des entrées (express-validator) sur CHAQUE endpoint
□ Middleware auth (JWT) sur les routes protégées
□ Gestion d'erreurs avec try/catch + messages en français
□ Pas de données sensibles dans les réponses (mot de passe, OTP)
□ Codes HTTP corrects (201 création, 401 non autorisé, 404 non trouvé)
□ Prix toujours en nombres entiers (FCFA, pas de décimales)
□ Numéros de commande au format #SDP-XXXXX
□ Double tarif (publicPrice / proPrice) correctement géré
□ Stock décrémenté à la commande
□ Livraisons gratuites décomptées (3/semaine max pour Pro)
```

### 🛠️ Tes Outils

| Outil | Usage | Lien |
|---|---|---|
| **Flutter SDK** | Framework mobile cross-platform | [flutter.dev](https://flutter.dev) |
| **Android Studio** | IDE + émulateur Android | [developer.android.com/studio](https://developer.android.com/studio) |
| **VS Code** | Éditeur de code principal | Installé |
| **Gemini** | IA pour générer du code Flutter, déboguer | [gemini.google.com](https://gemini.google.com) |
| **Dart DevTools** | Débogage Flutter | Intégré dans VS Code |
| **Postman** | Tester l'API de Ngary quand elle est prête | [postman.com](https://www.postman.com/) |
| **Git + GitHub** | Versionning + collaboration | repo existant |

### 📂 Structure du Projet Flutter

```
mobile/
├── lib/
│   ├── main.dart                      # Point d'entrée
│   ├── app.dart                       # MaterialApp + thème + routes
│   │
│   ├── config/
│   │   ├── theme.dart                 # Design system complet (charte graphique)
│   │   ├── colors.dart                # Palette OKLCH → couleurs Flutter
│   │   ├── typography.dart            # Comfortaa + Nunito, échelle brutale
│   │   ├── spacing.dart               # Marges asymétriques (20/28px)
│   │   └── api_config.dart            # URL backend, endpoints
│   │
│   ├── models/
│   │   ├── user.dart
│   │   ├── product.dart
│   │   ├── category.dart
│   │   ├── cart_item.dart
│   │   ├── order.dart
│   │   ├── subscription.dart
│   │   └── notification.dart
│   │
│   ├── services/
│   │   ├── api_service.dart           # HTTP client (Dio)
│   │   ├── auth_service.dart          # Register, OTP, login
│   │   ├── product_service.dart       # Catalogue, recherche
│   │   ├── cart_service.dart          # Gestion panier
│   │   ├── order_service.dart         # Commandes
│   │   └── mock_data.dart             # ⚡ Données mockées J1-J10
│   │
│   ├── providers/                     # État global (Riverpod ou Provider)
│   │   ├── auth_provider.dart
│   │   ├── cart_provider.dart
│   │   └── user_provider.dart
│   │
│   ├── widgets/                       # Composants réutilisables
│   │   ├── baana_button.dart          # Bouton 52px min, Comfortaa Bold
│   │   ├── baana_input.dart           # Champ 52px, fond teinté
│   │   ├── product_card.dart          # Carte produit (ANTI cards-dans-cards)
│   │   ├── badge_widget.dart          # Pro, Promo, statut
│   │   ├── bottom_nav.dart            # Navigation 4 items
│   │   ├── chip_filter.dart           # Filtres horizontaux
│   │   ├── notification_tile.dart     # Ligne de notification
│   │   └── order_timeline.dart        # Timeline suivi commande
│   │
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── auth/
│   │   │   ├── register_screen.dart
│   │   │   └── otp_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── catalog/
│   │   │   ├── catalog_screen.dart
│   │   │   ├── product_detail_screen.dart
│   │   │   └── search_screen.dart
│   │   ├── cart/
│   │   │   ├── cart_screen.dart
│   │   │   ├── recap_screen.dart
│   │   │   └── confirmation_screen.dart
│   │   ├── orders/
│   │   │   ├── order_history_screen.dart
│   │   │   └── order_tracking_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   └── dashboard_pro_screen.dart
│   │   ├── subscription/
│   │   │   ├── compare_screen.dart
│   │   │   └── payment_screen.dart
│   │   └── other/
│   │       ├── notifications_screen.dart
│   │       ├── payment_mobile_money_screen.dart
│   │       └── support_screen.dart
│   │
│   └── navigation/
│       ├── app_router.dart            # GoRouter ou Navigator 2.0
│       └── route_names.dart
│
├── assets/
│   ├── fonts/
│   │   ├── Comfortaa-Bold.ttf         # Déjà dans le repo !
│   │   └── Nunito-*.ttf               # À télécharger
│   ├── images/
│   │   ├── logo/                      # 3 versions du logo (déjà dans le repo)
│   │   └── onboarding/
│   └── icons/                         # Icônes Phosphor/Lucide exportées
│
├── pubspec.yaml
└── README.md
```

---

### 📅 Planning Mouhamed — Jour par Jour (Frontend + Architecture)

---

#### **J1 (11 juin) — Init Flutter + Design System + Lancement Backend Ngary**

**Matin : Initialisation du projet Flutter + Briefing Ngary**

**Workflow :**
1. Installe Flutter SDK si pas encore fait
2. Crée le projet Flutter
3. Configure les assets (fonts, images, logo)
4. Installe les dépendances
5. 🏗️ **ARCHITECTE :** Briefing de lancement avec Ngary (1h) :
   - Lui expliquer l'architecture globale du backend
   - Lui partager le contrat d'API (section ci-dessus)
   - Lui montrer la structure de dossiers backend à respecter
   - Vérifier ensemble que PostgreSQL est installé et `baana_db` créée
   - Lui donner les prompts Gemini de J1 backend (dans le guide Ngary ci-dessous)

**Prompt Gemini — Vérifier l'installation Flutter :**
```
Je suis sur Windows. Vérifie que Flutter est bien installé et configuré.
Donne-moi les commandes à exécuter dans PowerShell :
1. Vérifier flutter --version
2. Vérifier flutter doctor
3. Si des problèmes → comment les corriger
4. Comment créer un nouveau projet Flutter nommé "baana_app"

Langue : français.
```

**Commandes à exécuter :**
```bash
# Vérifier Flutter
flutter --version
flutter doctor

# Créer le projet
flutter create --org com.sendigitalpulse baana_app

# Installer les dépendances principales
cd baana_app
flutter pub add dio                    # Client HTTP
flutter pub add provider               # État global
flutter pub add go_router              # Navigation
flutter pub add flutter_svg            # SVG support
flutter pub add cached_network_image   # Cache images
flutter pub add shared_preferences     # Stockage local
flutter pub add flutter_secure_storage # Token JWT
flutter pub add intl                   # Formatage (prix FCFA, dates)
flutter pub add shimmer                # Loading skeletons
flutter pub add phosphor_flutter       # Icônes Phosphor (pas Material!)
```

**Après-midi : Design System en code**

C'est la tâche la PLUS IMPORTANTE de J1. Tout le design de l'app en dépend.

**Prompt Gemini — Générer le design system Flutter :**
```
Tu es un développeur Flutter senior spécialisé en design system.

Génère les fichiers Dart suivants pour l'application "Baana" (e-commerce Sénégal) 
en respectant STRICTEMENT cette charte graphique :

PALETTE DE COULEURS (tous les neutres sont TEINTÉS émeraude, ZÉRO gris pur) :
- Vert émeraude primaire : #10B981
- Orange Baana accent : #F0A050
- Orange CTA fort : #F97316
- Fond principal (blanc teinté) : #F7FAF8
- Fond input : #EDF2EF
- Bordure/séparateur : #D4DDD8
- Texte secondaire : #6B7D75
- Texte principal (quasi-noir) : #2C3E36
- Erreur (rouge teinté) : #E05252
- Info (bleu teinté) : #3B9EC4

TYPOGRAPHIE :
- Titres et navigation : Comfortaa Bold (28pt H1, 22pt H2, 16pt boutons)
- Corps de texte : Nunito Regular (14pt), SemiBold (14pt noms), Bold (11pt badges)
- Hiérarchie BRUTALE : écart ≥14pt entre H1 et corps
- INTERDIT : Inter, Roboto, Poppins, Open Sans

COMPOSANTS :
- Bouton principal : fond vert #10B981, texte blanc, hauteur 52px MIN, coins 12px
- Bouton CTA urgent : fond orange #F97316, hauteur 56px
- Bouton secondaire : outline vert, fond transparent, 52px
- Champ de saisie : hauteur 52px, fond #EDF2EF, coins 12px, bordure focus vert
- Marges asymétriques : gauche 20px, droite 28px

FICHIERS À GÉNÉRER :
1. lib/config/colors.dart — Toutes les couleurs comme constantes Color
2. lib/config/typography.dart — TextTheme avec Comfortaa + Nunito
3. lib/config/spacing.dart — Marges asymétriques, espacements
4. lib/config/theme.dart — ThemeData complet qui assemble tout
5. lib/widgets/baana_button.dart — Widget bouton réutilisable (primary, secondary, cta)
6. lib/widgets/baana_input.dart — Widget champ de saisie réutilisable

Le code doit être propre, commenté en français, et prêt à l'emploi.
Pas de Material Design par défaut visible — le thème override tout.
```

**Livrable J1 :** Projet Flutter initialisé + design system complet + Ngary débloqué sur le backend

**Checklist J1 :**
- [ ] `flutter doctor` sans erreurs critiques
- [ ] Projet `baana_app/` créé
- [ ] Fonts Comfortaa + Nunito ajoutées dans `assets/fonts/`
- [ ] Logo Baana copié dans `assets/images/logo/`
- [ ] `colors.dart` avec TOUTE la palette (zéro gris pur)
- [ ] `typography.dart` avec Comfortaa Bold + Nunito
- [ ] `theme.dart` avec ThemeData complet
- [ ] `baana_button.dart` fonctionnel (3 variantes)
- [ ] `baana_input.dart` fonctionnel
- [ ] App lance sans erreur sur émulateur
- [ ] 🏗️ Briefing Ngary fait — il a compris l'architecture et le contrat d'API
- [ ] 🏗️ Ngary a PostgreSQL fonctionnel + `npm run dev` qui tourne

---

#### **J2 (12 juin) — Splash + Onboarding + Navigation**

**Matin : Splash Screen + Navigation de base**

**Prompt Gemini — Splash Screen Flutter :**
```
Génère le code Flutter complet pour le Splash Screen de l'application "Baana".

DESIGN (issu de la maquette 01_splash.png) :
- Fond : dégradé vertical du vert émeraude #10B981 vers un vert profond #0D7A56
- Logo : trèfle Baana au premier tiers vertical (utiliser Image.asset)
- Sous le logo : "Baana" en Comfortaa Bold 32pt blanc
- Slogan : "Le confort par le digital" en Nunito Regular 14pt, blanc teinté #F0FAF5
- En bas : indicateur de chargement (LinearProgressIndicator fin, couleur #F0A050)
- AUCUNE card, aucune boîte, respiration maximale
- Transition automatique vers l'onboarding après 2.5 secondes

TECHNIQUE :
- Utiliser un StatefulWidget avec Timer
- Dégradé via BoxDecoration + LinearGradient
- Logo : Image.asset('assets/images/logo/baana_transparent_logo.png')
- Navigation : GoRouter ou Navigator.pushReplacement

Code commenté en français. Respect strict de la charte graphique.
```

**Après-midi : Onboarding (3 slides)**

**Prompt Gemini — Onboarding Flutter :**
```
Génère le code Flutter complet pour l'écran d'Onboarding de "Baana" — 3 slides avec PageView.

SLIDE 1 : "Achetez en gros, payez moins"
- Illustration : Image.asset (placeholder pour l'instant, zone 40% de l'écran)
- Titre : "Achetez en gros, payez moins" en Comfortaa Bold 26pt quasi-noir #2C3E36
- Sous-titre : "Accédez aux prix de gros réservés aux membres Pro" en Nunito Regular 14pt #6B7D75
- 3 dots indicateurs : premier actif en orange #F97316, les autres en #D4DDD8
- Bouton "Suivant" : vert #10B981, pleine largeur, 52px, Comfortaa Bold
- Lien "Passer" en haut à droite, couleur #6B7D75

SLIDE 2 : "Livraison gratuite à Dakar"
- Titre : "Livraison gratuite à Dakar"
- Sous-titre : "3 livraisons gratuites par semaine pour les membres Pro"
- Deuxième dot actif en orange
- Même bouton "Suivant"

SLIDE 3 : "Payez facilement avec Mobile Money"
- Titre : "Payez facilement avec Mobile Money"
- Sous-titre : "Wave, Orange Money, Free Money — en un seul clic"
- Troisième dot actif
- Bouton "Commencer" en ORANGE #F97316, 56px hauteur (plus grand!)
- PAS de lien "Passer"

TECHNIQUE :
- PageView.builder avec PageController
- AnimatedContainer pour les dots
- Marges asymétriques : gauche 20px, droite 28px
- Navigation vers RegisterScreen à la fin

Code commenté en français.
```

**Livrable J2 :** Splash → Onboarding (3 slides) → navigation vers auth

**Checklist J2 :**
- [ ] Splash screen avec dégradé + logo + timer 2.5s
- [ ] Onboarding 3 slides avec PageView
- [ ] Dots indicateurs animés (orange actif)
- [ ] Bouton "Commencer" orange sur slide 3
- [ ] Navigation Splash → Onboarding → Register
- [ ] GoRouter ou Navigator configuré
- [ ] 🏗️ Revue du code backend J1 de Ngary (modèles Sequelize OK ?)
- [ ] 🏗️ Point rapide avec Ngary : blocages éventuels sur le seed ?

---

#### **J3 (13 juin) — Inscription + OTP**

**Prompt Gemini — Inscription :**
```
Génère le code Flutter pour l'écran d'inscription par numéro de téléphone de "Baana".

DESIGN (maquette 05_inscription.png) :
- Fond : blanc teinté #F7FAF8
- Logo Baana petit (32px) en haut à gauche (icône trèfle seule)
- Titre : "Créez votre compte" en Comfortaa Bold 26pt, couleur #2C3E36
- Sous-titre : "Entrez votre numéro de téléphone pour commencer" en Nunito Regular 14pt, #6B7D75
- Champ téléphone : widget BaanaInput customisé
  - Hauteur 52px, fond #EDF2EF, coins 12px
  - À gauche dans le champ : drapeau 🇸🇳 + "+221"
  - Bordure focus = vert #10B981
  - Clavier numérique (keyboardType: TextInputType.phone)
- Bouton "Recevoir le code" : BaanaButton vert, pleine largeur, 52px
- Lien : "Vous avez déjà un compte ? Connectez-vous" — "Connectez-vous" en orange #F97316 Bold
- Texte légal discret en bas : Nunito Regular 10pt, #6B7D75
- Marges asymétriques : gauche 20px, droite 28px
- PAS de card autour du formulaire — directement sur le fond

TECHNIQUE :
- Utiliser les widgets BaanaButton et BaanaInput du design system
- Validation : numéro sénégalais = 9 chiffres après +221
- Sur submit → appel AuthService.register(phone) → navigation vers OTPScreen
- Pour l'instant, mock le service (pas d'API réelle avant J11)

Code commenté en français.
```

**Prompt Gemini — OTP :**
```
Génère le code Flutter pour l'écran de vérification OTP de "Baana".

DESIGN (maquette 06_otp.png) :
- Bouton retour (flèche) en haut à gauche
- Icône : téléphone stylisé avec check vert, taille 64px (utiliser Phosphor icon)
- Titre : "Entrez le code reçu" en Comfortaa Bold 24pt
- Instruction : "Code envoyé au +221 7X XXX XX XX" en Nunito Regular 14pt, #6B7D75
- 4 cases OTP : 
  - Taille 56×56px minimum
  - Fond #EDF2EF, coins 12px
  - Case active = bordure vert #10B981 2px
  - Cases inactives = bordure #D4DDD8
  - Auto-focus sur la case suivante après saisie
  - Espacement 16px entre cases
- Timer : "Renvoyer dans 00:45" en Nunito Regular 13pt #6B7D75
  - Quand timer = 0 → "Renvoyer le code" en orange Bold cliquable
- Bouton "Valider" : vert, pleine largeur, 52px
  - Actif seulement quand 4 chiffres saisis
  - Sur submit → AuthService.verifyOTP() → navigation vers HomeScreen

TECHNIQUE :
- 4 TextEditingController séparés ou un PinCodeTextField
- Timer avec CountdownTimer
- FocusNode pour auto-focus
- Mock : code "1234" accepté en dev

Code commenté en français.
```

**Livrable J3 :** Inscription (+221) → OTP (4 cases) → navigation vers Home

> [!TIP]
> 🏗️ **Tâche architecte J3 :** L'auth (JWT + OTP) est un module **critique**. Prends 1h pour **pair-coder avec Ngary** le `authController.js` et le middleware JWT. Vérifie que le code OTP "1234" fonctionne en dev, que le token JWT est bien signé, et que le middleware protège les routes.

---

#### **J4 (16 juin) — Page d'Accueil (Home)**

**Prompt Gemini — Home Screen :**
```
Génère le code Flutter complet pour la page d'accueil (Home) de "Baana".

DESIGN (maquette 07_accueil.png) :
- Header : "Bonjour, [Nom] 👋" aligné à gauche en Comfortaa Bold 28pt
  - Icône cloche (Phosphor bell) + icône panier avec badge compteur en haut à droite
- Barre de recherche : forme pill (StadiumBorder), pleine largeur
  - Fond #EDF2EF, placeholder "Rechercher un produit...", icône loupe
  - Cliquable → navigation vers SearchScreen
- Bannière promotionnelle : Container pleine largeur, coins 16px
  - Fond dégradé orange, texte blanc overlay en Bold
  - Hauteur ~150px
- Section "Catégories" : ListView horizontal scrollable
  - Chips avec icônes rondes : Alimentaire, Ménager, Cosmétique, Textile, Électronique
  - Chip sélectionné = fond vert #10B981, texte blanc
  - Chip inactif = fond #EDF2EF, texte #6B7D75
- Section "Produits vedettes" : GridView 2 colonnes
  - Chaque item = widget ProductCard :
    - Image produit (coins 12px, ratio 1:1)
    - Nom en Nunito SemiBold 14pt
    - Prix barré en #6B7D75 + TextDecoration.lineThrough
    - Prix Pro en Comfortaa Bold 18pt vert #10B981
    - Badge "Pro" orange si applicable
    - PAS de card container — juste image + texte sur le fond
  - Gouttière : 12px horizontal, 16px vertical (asymétrique!)
- Bottom Navigation : 4 items (Accueil actif vert, Catalogue, Commandes, Profil)
  - Icônes Phosphor (PAS Material Icons)
  - Item actif = vert #10B981, inactif = #6B7D75
  - Hauteur 56px, fond blanc teinté #F7FAF8

DONNÉES MOCK : 
- 5 catégories
- 6 produits vedettes avec images placeholder
- Prix en FCFA (formatage avec séparateur de milliers)

TECHNIQUE :
- Scaffold + BottomNavigationBar custom
- Utiliser les données mock de mock_data.dart
- Marges asymétriques dans tout l'écran

Code commenté en français.
```

**Livrable J4 :** Home screen complète avec catégories, produits, bottom nav

---

#### **J5 (17 juin) — Catalogue + Fiche Produit + Recherche**

**Prompt Gemini — Catalogue :**
```
Génère le code Flutter pour l'écran Catalogue produits de "Baana".

DESIGN (maquette 08_catalogue.png) :
- Header : "Catalogue" à gauche Bold + icône filtre (Phosphor funnel) + panier avec badge
- Barre de recherche pill
- Filtres chips horizontaux scrollables : "Tout" (actif = vert + blanc), 
  "Alimentaire", "Ménager", "Cosmétique", "Textile"
- Grille 2 colonnes (widget ProductCard réutilisable)
  - Badge "PROMO" orange sur certains produits, tourné -3° (Transform.rotate)
  - Bouton "+" cercle vert 32px en bas à droite de chaque produit
- Bottom nav : Catalogue actif en vert

TECHNIQUE :
- GridView.builder avec pagination (ListView si scroll vertical)
- Filtrage local des données mock par catégorie
- ProductCard widget réutilisable (déjà créé)

Code commenté en français.
```

**Prompt Gemini — Fiche Produit :**
```
Génère le code Flutter pour l'écran Fiche produit détaillée de "Baana".

DESIGN (maquette 09_fiche_produit.png) :
- Image produit grande (~40% écran), pleine largeur, coins 0 en haut, 24px en bas
  - Overlay : bouton retour (cercle semi-transparent) haut gauche
  - Overlay : icône cœur favori haut droite
- Nom produit : Comfortaa Bold 22pt
- Prix barré : Nunito Regular 13pt #6B7D75 + lineThrough
- Prix Pro : Comfortaa Bold 28pt vert #10B981
- Badge "Économisez X FCFA" : fond orange pâle, texte orange foncé, forme pilule
- Description : 2-3 lignes Nunito Regular 14pt
- Stock : "En stock ✓" vert OU "Stock limité ⚠️" orange
- Sélecteur quantité : boutons (-/+) ronds, chiffre au milieu 18pt Bold
- Bouton fixe en bas : "Ajouter au panier — X FCFA" vert, pleine largeur, 52px
  - Toujours visible (bottomSheet ou Positioned)

TECHNIQUE :
- CustomScrollView avec SliverAppBar pour l'image immersive
- Sélecteur quantité = StatefulWidget
- Bouton fixe = Positioned en bas du Stack
- Prix formaté en FCFA (ex: "12 500 FCFA")

Code commenté en français.
```

**Livrable J5 :** Catalogue avec filtres + Fiche produit complète + Recherche

---

#### **J6-J7 (18-19 juin) — Tunnel de Commande (Panier → Récap → Confirmation)**

**Prompt Gemini — Panier :**
```
Génère le code Flutter pour l'écran Mon Panier (étape 1/3) de "Baana".

DESIGN (maquette 10_panier.png) :
- Header : "Mon Panier" + indicateur d'étape "1 · 2 · 3" (le 1 actif vert, les autres #D4DDD8)
- Liste articles : pour chaque = miniature (coins 8px) + nom + prix vert + quantité (-/+) + supprimer
- Badge si Pro : "🎉 Livraison gratuite cette semaine" fond vert pâle
- Bloc résumé : Sous-total, Livraison (Gratuite si Pro), Total 20pt Bold
- Bouton fixe : "Commander — [Total] FCFA" vert, 52px
- "Continuer mes achats" en lien neutre

TECHNIQUE :
- CartProvider avec ChangeNotifier
- Dismissible pour swipe-to-delete
- Prix FCFA formatés

Code commenté en français.
```

*(Mêmes prompts détaillés pour Récapitulatif et Confirmation — J6 après-midi et J7 matin)*

**Livrable J6-J7 :** Tunnel complet : Panier → Récap → Paiement Mobile Money → Confirmation

---

#### **J8 (20 juin) — Profil + Dashboard Pro**

**Prompt Gemini — Profil + Dashboard :**
*(Prompts détaillés basés sur maquettes 15_profil.png et 16_dashboard_pro.png — même structure que ci-dessus)*

**Livrable J8 :** Profil avec menu + Dashboard Pro avec 4 KPIs

---

#### **J9-J10 (21-22 juin) — Abonnement + Notifications + Support + Historique**

**Livrable J9-J10 :**
- Comparatif abonnement (Hebdo vs Mensuel)
- Paiement abonnement
- Centre de notifications
- Support WhatsApp
- Historique commandes + Suivi commande (timeline)
- Paiement Mobile Money

---

## 🔵 GUIDE NGARY — Backend Node.js + PostgreSQL (J1 → J10)

> [!IMPORTANT]
> **Ngary, tu travailles sous la supervision de Mouhamed (architecte).** Il définit l'architecture, te fournit les prompts, et fait des revues de code quotidiennes. Si tu es bloqué sur quoi que ce soit → **contacte Mouhamed immédiatement**. Ne reste pas bloqué seul.
> 
> **Workflow quotidien :**
> 1. Le matin → tu codes avec les prompts de ce guide
> 2. L'après-midi → Mouhamed fait une revue de ton code et t'assiste si besoin
> 3. Fin de journée → point rapide avec Mouhamed (15 min)
> 4. Tu push ton code sur Git **chaque jour** pour que Mouhamed puisse le reviewer

### 🛠️ Tes Outils

| Outil | Usage | Lien |
|---|---|---|
| **Node.js** (LTS) | Runtime JavaScript côté serveur | [nodejs.org](https://nodejs.org) |
| **VS Code** | Éditeur de code | Installé |
| **PostgreSQL** | Base de données relationnelle | [postgresql.org](https://www.postgresql.org/) |
| **pgAdmin** ou **DBeaver** | Interface graphique pour PostgreSQL | [pgadmin.org](https://www.pgadmin.org/) |
| **Postman** | Tester tes endpoints API | [postman.com](https://www.postman.com/) |
| **Gemini** | IA pour générer du code Node.js, SQL, déboguer | [gemini.google.com](https://gemini.google.com) |
| **Git + GitHub** | Versionning | repo existant |
| **nodemon** | Redémarrage auto du serveur en dev | `npm install -D nodemon` |

### 📂 Structure du Projet Backend

```
backend/
├── src/
│   ├── index.js                # Point d'entrée Express
│   ├── config/
│   │   ├── database.js         # Connexion PostgreSQL (Sequelize)
│   │   └── env.js              # Variables d'environnement
│   ├── models/
│   │   ├── User.js             # Visiteur + Membre Pro
│   │   ├── Product.js          # Produits avec double tarif
│   │   ├── Category.js         # Catégories produits
│   │   ├── Cart.js             # Panier
│   │   ├── CartItem.js         # Items du panier
│   │   ├── Order.js            # Commandes
│   │   ├── OrderItem.js        # Items de commande
│   │   ├── Subscription.js     # Abonnements Pro
│   │   ├── SubscriptionPlan.js # Formules (Hebdo/Mensuel)
│   │   └── Notification.js     # Notifications
│   ├── routes/
│   │   ├── auth.js
│   │   ├── products.js
│   │   ├── categories.js
│   │   ├── cart.js
│   │   ├── orders.js
│   │   ├── subscriptions.js
│   │   ├── users.js
│   │   ├── dashboard.js
│   │   └── notifications.js
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── productController.js
│   │   ├── cartController.js
│   │   ├── orderController.js
│   │   ├── subscriptionController.js
│   │   ├── userController.js
│   │   ├── dashboardController.js
│   │   └── notificationController.js
│   ├── middleware/
│   │   ├── auth.js             # Vérification JWT
│   │   ├── isPro.js            # Vérifie abonnement Pro actif
│   │   └── validation.js
│   ├── utils/
│   │   ├── sms.js              # Envoi OTP par SMS
│   │   ├── jwt.js              # Génération/vérification token
│   │   └── helpers.js
│   └── seeders/
│       ├── categories.js       # 5 catégories
│       └── products.js         # 20+ produits réalistes
├── .env.example
├── package.json
└── README.md
```

---

### 📅 Planning Ngary — Jour par Jour

---

#### **J1 (11 juin) — Init Backend + PostgreSQL + Structure**

**Workflow :**
1. Installe PostgreSQL si pas encore fait
2. Crée la base de données `baana_db`
3. Initialise le projet Node.js avec les dépendances
4. Configure Express + Sequelize

**Prompt Gemini — Initialisation Backend :**
```
Tu es un développeur backend Node.js senior.

Je dois créer le backend API REST pour "Baana" — une application e-commerce 
par abonnement pour commerçants au Sénégal.

Stack technique :
- Node.js + Express.js
- PostgreSQL + Sequelize ORM
- JWT pour l'authentification
- bcryptjs pour le hachage

Génère-moi les fichiers suivants pour initialiser le projet :

1. package.json avec TOUTES les dépendances :
   - express, sequelize, pg, pg-hstore, jsonwebtoken, bcryptjs,
   - dotenv, cors, helmet, express-validator, multer, morgan
   - DevDeps : nodemon, sequelize-cli

2. src/index.js — Point d'entrée Express avec :
   - CORS configuré
   - Helmet pour la sécurité
   - Morgan pour les logs
   - express.json() + express.urlencoded()
   - Montage des routes sur /api/
   - Connexion à PostgreSQL au démarrage
   - Port configurable via .env

3. src/config/database.js — Connexion Sequelize à PostgreSQL

4. .env.example avec toutes les variables nécessaires :
   - DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
   - JWT_SECRET, JWT_EXPIRES_IN
   - SMS_API_KEY (placeholder)
   - PORT

5. Les scripts npm : "dev" (nodemon), "start" (node), "db:migrate", "db:seed"

Code commenté en français. Architecture REST propre.
```

**Commandes à exécuter :**
```bash
# Installer PostgreSQL (si pas fait)
# → Télécharger depuis postgresql.org ou winget install PostgreSQL.PostgreSQL

# Créer la base de données
psql -U postgres
CREATE DATABASE baana_db;
\q

# Initialiser le projet
cd backend
npm install

# Lancer en dev
npm run dev
```

**Checklist J1 Ngary :**
- [ ] PostgreSQL installé et fonctionnel
- [ ] Base de données `baana_db` créée
- [ ] `npm install` sans erreur
- [ ] `npm run dev` → serveur Express écoute sur port 3000
- [ ] Route GET /api/health → { status: "ok" }
- [ ] Sequelize connecté à PostgreSQL (log "Database connected")

---

#### **J2 (12 juin) — Modèles de données + Seed**

**Prompt Gemini — Modèles Sequelize :**
```
Génère TOUS les modèles Sequelize pour l'application Baana (e-commerce B2B, Sénégal).

MODÈLE User :
- id (UUID, primary key)
- phone (string, unique, NOT NULL) — format "+221XXXXXXXXX"
- name (string, nullable)
- businessName (string, nullable) — nom de l'entreprise
- ninea (string, nullable) — NINEA optionnel
- address (text, nullable)
- gpsLatitude (decimal, nullable)
- gpsLongitude (decimal, nullable)
- role (enum: 'visitor', 'pro', 'admin', default 'visitor')
- otpCode (string, nullable)
- otpExpiresAt (date, nullable)
- loyaltyPoints (integer, default 0)
- createdAt, updatedAt

MODÈLE Product :
- id (UUID)
- name (string, NOT NULL)
- description (text)
- publicPrice (decimal, NOT NULL) — prix visiteur (détail)
- proPrice (decimal, NOT NULL) — prix membre Pro (gros)
- images (array de strings / JSON)
- stock (integer, default 0)
- categoryId (FK → Category)
- badge (enum: null, 'promo', 'new', 'popular')
- isActive (boolean, default true)

MODÈLE Category :
- id (UUID)
- name (string, NOT NULL)
- icon (string) — nom de l'icône Phosphor

MODÈLE Order :
- id (UUID)
- orderNumber (string, unique) — format "#SDP-XXXXX" auto-généré
- userId (FK → User)
- status (enum: 'confirmed', 'preparing', 'delivering', 'delivered', 'cancelled')
- subtotal, deliveryFee, total (decimal)
- deliveryAddress (text)
- paymentMethod (enum: 'wave', 'orange_money', 'free_money', 'card')
- paymentStatus (enum: 'pending', 'paid', 'failed')
- timeline (JSON array: [{ status, date, description }])

MODÈLE OrderItem :
- orderId (FK), productId (FK), quantity, unitPrice

MODÈLE Subscription :
- id (UUID)
- userId (FK → User)
- planId (FK → SubscriptionPlan)
- status (enum: 'active', 'expired', 'pending')
- startDate, endDate
- freeDeliveriesUsed (integer, default 0)
- freeDeliveriesMax (integer, default 3)

MODÈLE SubscriptionPlan :
- id (UUID)
- name ('Hebdomadaire', 'Mensuel')
- price (decimal)
- durationDays (integer: 7 ou 30)
- benefits (JSON array)

MODÈLE Notification :
- id (UUID)
- userId (FK → User)
- type (enum: 'order', 'payment', 'subscription', 'promo')
- title, message (string)
- isRead (boolean, default false)

Inclus les associations (belongsTo, hasMany) et les hooks nécessaires.
Code commenté en français.
```

**Prompt Gemini — Seeder produits réalistes :**
```
Génère un fichier seeder Sequelize pour l'application Baana (e-commerce Sénégal).

Insère :
1. 5 catégories : Alimentaire, Ménager, Cosmétique, Textile, Électronique
   (avec icônes Phosphor)

2. 20 produits réalistes du marché sénégalais :

ALIMENTAIRE :
- Riz brisé Oncle Sam (25kg) — public: 15000, pro: 12000 FCFA
- Huile Niinal (20L) — public: 18000, pro: 14500
- Sucre en poudre (50kg) — public: 28000, pro: 23000
- Lait Nido (2.5kg) — public: 12000, pro: 9500
- Bouillon Jumbo (carton 100) — public: 8500, pro: 6800

MÉNAGER :
- Eau de Javel Lacroix (5L x6) — public: 9000, pro: 7200
- Détergent OMO (10kg) — public: 14000, pro: 11200
- Savon Le Chat (carton 48) — public: 22000, pro: 17600
- Sacs poubelle 100L (rouleau x3) — public: 4500, pro: 3600

COSMÉTIQUE :
- Crème Nivea (gros pot x12) — public: 18000, pro: 14400
- Parfum générique (carton 24) — public: 24000, pro: 19200
- Shampoing Head & Shoulders (x12) — public: 15000, pro: 12000

TEXTILE :
- T-shirts basiques (lot 20) — public: 35000, pro: 28000
- Chaussettes (carton 50 paires) — public: 25000, pro: 20000

ÉLECTRONIQUE :
- Chargeurs universels (lot 20) — public: 20000, pro: 16000
- Écouteurs filaires (lot 30) — public: 15000, pro: 12000

Tous les prix sont en FCFA. Stock initial : entre 50 et 200 unités.
Certains produits ont badge = 'promo' ou 'popular'.

Inclus aussi 2 plans d'abonnement :
- Hebdomadaire : 2500 FCFA / 7 jours
- Mensuel : 7500 FCFA / 30 jours (recommandé, économie de 2500)

Code commenté en français.
```

**Checklist J2 Ngary :**
- [ ] Tous les modèles Sequelize créés et synchronisés
- [ ] Relations (associations) configurées
- [ ] Seeder exécuté : 5 catégories + 20 produits + 2 plans
- [ ] Vérification dans pgAdmin/DBeaver que les tables existent

---

#### **J3-J4 (13-16 juin) — API Auth (Register, OTP, Login)**

**Prompt Gemini — Auth Controller :**
```
Génère le code complet pour l'authentification par OTP SMS de l'application Baana.

FICHIERS À GÉNÉRER :

1. src/controllers/authController.js :

   register(req, res) :
   - Reçoit { phone } (format +221XXXXXXXXX)
   - Valide le format du numéro sénégalais
   - Crée l'utilisateur s'il n'existe pas (findOrCreate)
   - Génère un code OTP à 4 chiffres aléatoire
   - Stocke le code dans user.otpCode + otpExpiresAt (5 minutes)
   - Envoie le SMS (pour l'instant, console.log le code en dev)
   - Retourne { message: "Code OTP envoyé", userId }

   verifyOTP(req, res) :
   - Reçoit { phone, code }
   - Vérifie que le code est correct ET non expiré
   - Si correct → génère un JWT token (expire 30 jours)
   - Retourne { token, user: { id, phone, name, role, subscription } }
   - Si incorrect → { error: "Code invalide" } (401)

   login(req, res) :
   - Même logique que register mais l'utilisateur doit exister

   getMe(req, res) :
   - Route protégée (middleware auth)
   - Retourne le profil complet de l'utilisateur connecté
   - Inclut l'abonnement actif s'il existe

2. src/middleware/auth.js :
   - Extrait le token du header "Authorization: Bearer xxx"
   - Vérifie le JWT avec jsonwebtoken
   - Attache req.user avec l'ID de l'utilisateur
   - Si token invalide → 401

3. src/routes/auth.js :
   - POST /register
   - POST /verify-otp
   - POST /login
   - GET /me (protégé)

4. src/utils/jwt.js :
   - generateToken(userId) → JWT signé
   - verifyToken(token) → payload décodé

IMPORTANT :
- En mode dev, le code OTP est toujours "1234" ET affiché dans la console
- En prod, on utilisera un vrai SMS provider
- Validation avec express-validator
- Gestion d'erreurs avec try/catch et messages en français

Code commenté en français.
```

**Checklist J3-J4 Ngary :**
- [ ] POST /api/auth/register → crée user + retourne "OTP envoyé"
- [ ] POST /api/auth/verify-otp → retourne JWT token
- [ ] GET /api/auth/me → retourne le profil (protégé)
- [ ] Test dans Postman : tout le flux register → OTP → me
- [ ] Code OTP "1234" en dev (console.log)

---

#### **J5-J6 (17-18 juin) — API Produits + Catégories + Panier**

**Prompt Gemini — Products API :**
```
Génère le code complet pour l'API Produits et Catégories de Baana.

ENDPOINTS :

GET /api/products
- Paramètres query : category, search, page (default 1), limit (default 20), sort (price_asc, price_desc, newest)
- Si l'utilisateur est Pro (JWT → user.role === 'pro') → retourne proPrice comme "price"
- Si visiteur → retourne publicPrice comme "price"
- Pagination : retourne { products, total, page, pages }
- Recherche full-text sur name et description (ILIKE PostgreSQL)
- Filtre par categoryId

GET /api/products/:id
- Retourne le produit complet avec catégorie
- Prix adapté selon le rôle de l'utilisateur

GET /api/categories
- Retourne toutes les catégories avec le nombre de produits par catégorie

IMPORTANT :
- Le middleware auth est OPTIONNEL sur les routes produits (le visiteur peut voir le catalogue)
- Si le token est présent → on adapte le prix, sinon → prix public
- Images : pour l'instant, utiliser des URLs placeholder (picsum.photos)

Code commenté en français.
```

**Prompt Gemini — Cart API :**
```
Génère le code complet pour l'API Panier de Baana.

ENDPOINTS (tous protégés par le middleware auth) :

GET /api/cart
- Retourne le panier de l'utilisateur connecté
- Inclut les produits (image, nom, prix adapté au rôle)
- Calcule : subtotal, deliveryFee (0 si Pro avec livraisons restantes, sinon 1500 FCFA), total
- Si Pro → vérifie freeDeliveriesUsed < freeDeliveriesMax

POST /api/cart
- Body : { productId, quantity }
- Si le produit est déjà dans le panier → incrémente la quantité
- Sinon → crée un nouveau CartItem
- Vérifie le stock disponible

PUT /api/cart/:itemId
- Body : { quantity }
- Met à jour la quantité (minimum 1)
- Vérifie le stock

DELETE /api/cart/:itemId
- Supprime l'item du panier

MODÈLE :
- Cart : userId (FK), créé automatiquement au premier ajout
- CartItem : cartId (FK), productId (FK), quantity

Code commenté en français.
```

---

#### **J7-J8 (19-20 juin) — API Commandes + Abonnements**

*(Mêmes prompts détaillés pour Orders et Subscriptions — format identique)*

**Endpoints Commandes :**
- POST /api/orders (créer commande depuis le panier, numéro auto #SDP-XXXXX)
- GET /api/orders (historique avec filtres statut)
- GET /api/orders/:id (détail + timeline)

**Endpoints Abonnements :**
- GET /api/subscriptions/plans
- POST /api/subscriptions (souscrire)
- GET /api/subscriptions/me
- PUT /api/subscriptions/renew

---

#### **J9-J10 (21-22 juin) — API Dashboard + Notifications + Profil + Seed final**

**Endpoints :**
- GET /api/dashboard (KPIs Pro : économies, commandes, livraisons, points)
- GET /api/notifications + PUT read/read-all
- GET/PUT /api/users/me (profil)
- Seed de données de test réalistes pour les démos

---

# 🔗 PHASE INTÉGRATION (J11 → J13 — 23 au 25 juin)

## Objectif
Connecter le Flutter de Mouhamed à l'API de Ngary. Remplacer les données mockées par les données réelles.

### Répartition

| Mouhamed (Frontend) | Ngary (Backend) |
|---|---|
| Remplacer `mock_data.dart` par appels API réels | Corriger les bugs API détectés par Mouhamed |
| Configurer Dio avec le token JWT | Ajouter des endpoints manquants |
| Tester chaque écran avec données réelles | Optimiser les requêtes SQL |
| Gérer les erreurs réseau (loading, erreur, retry) | CORS, validation, edge cases |
| Test du paiement Mobile Money (sandbox PayDunya) | Intégration PayDunya côté serveur |

### Workflow
1. Ngary déploie le backend sur un serveur accessible (Render ou localhost en réseau local)
2. Mouhamed configure l'URL API dans `api_config.dart`
3. Écran par écran : remplacer mock → API réelle → tester → corriger

---

# 🧪 PHASE 4 — Tests & QA (J14 → J16 — 25 au 27 juin)

### Checklist de tests

| Test | Responsable | Comment |
|---|---|---|
| Parcours complet Visiteur | Mouhamed | Splash → Inscription → OTP → Home → Catalogue → Panier → Commande |
| Parcours Membre Pro | Mouhamed | Abonnement → Prix Pro → Livraison gratuite → Dashboard |
| API sous charge | Ngary | Tester avec 50+ requêtes simultanées |
| Paiement Mobile Money | Les deux | Sandbox PayDunya/CinetPay |
| Appareils variés | Mouhamed | Tester sur 2-3 appareils Android différents |
| Design conforme | Mouhamed | Vérifier charte graphique sur chaque écran |
| Sécurité | Ngary | Tester sans token, token expiré, injections |
| Performance 3G | Les deux | Throttle réseau dans DevTools |

---

# 🚀 PHASE 5 — Lancement (J17 → J18 — 27 au 28 juin)

| Tâche | Responsable |
|---|---|
| Build APK release (`flutter build apk`) | Mouhamed |
| Déploiement backend sur serveur prod | Ngary |
| Création fiche Play Store (titre, description, captures) | Mouhamed |
| Upload APK sur Play Store | Mouhamed |
| Configuration domaine + SSL backend | Ngary |
| Test final en prod | Les deux |
| Présentation au DG Boubacar A. Traoré | Les deux |

---

## Verification Plan

### Tests automatisés
```bash
# Backend
npm run test                    # Jest

# Frontend
flutter test                    # Tests unitaires
flutter build apk --release     # Build prod
```

### Vérification manuelle
1. **Parcours Visiteur complet** sur appareil physique
2. **Parcours Pro complet** avec abonnement
3. **Conformité charte graphique** : Comfortaa/Nunito, couleurs OKLCH, marges asymétriques, anti-AI Slop
4. **Paiement sandbox** : Wave + Orange Money
5. **Performance 3G** : navigation fluide, images compressées
6. **Démo au superviseur** Ababacar Koundoul avant lancement
