# 🟢 GUIDE AVANCÉ : MOUHAMED — Architecte & Lead Frontend Flutter 

Bienvenue dans ton guide d'exécution optimisé pour la **Phase 2 (Développement)**.
En tant qu'**Architecte du projet** et **Lead Frontend**, tu as un double rôle : coder l'application Flutter (avec un focus sur le visuel, le routing, la connexion API, l'ergonomie et la performance) et superviser Ngary sur le backend Node.js.

L'outil **Antigravity avec Gemini 3.1 Pro** va générer le code pour toi, mais un bon code nécessite un excellent prompt. Ce guide applique les standards de la compétence `prompt-optimizer`.

---

## 🏗️ Standards d'Architecture Frontend
Avant de lancer un prompt, assure-toi que l'IA respecte ces piliers :
- **Routing :** `GoRouter` obligatoire pour la navigation déclarative et le deep linking.
- **State Management :** `Provider` pour la gestion d'état locale/globale.
- **Réseau :** `Dio` avec des intercepteurs pour injecter le JWT Token et gérer les erreurs globalement (401 -> Logout).
- **Ergonomie & UX :** Shimmer effects pendant les chargements, SnackBar pour les erreurs réseau, animations de transition fluides.
- **Performance :** `CachedNetworkImage` pour les images, `ListView.builder` et `SliverList` pour les listes infinies, optimisation des re-builds.

## 🌿 Workflow Git & GitHub (Avec l'aide d'Antigravity)

L'équipe utilise GitHub pour la collaboration. **Règle d'or : On ne code jamais directement sur la branche `main` !** Voici les prompts à donner à Antigravity pour t'assister à chaque étape :

1. **Créer ta branche :**
   > *Prompt Antigravity :* "Crée et bascule sur une nouvelle branche Git nommée `feat/front-[nom-de-la-feature]` à partir de la branche `main`."
2. **Coder & Commiter :**
   Une fois que l'IA a généré le code de la fonctionnalité, demande-lui de commiter :
   > *Prompt Antigravity :* "Analyse mes fichiers modifiés avec `git status` et `git diff`, ajoute-les au staging, et crée un commit avec un message conventionnel (ex: `feat(front): ajout du splash screen`)."
3. **Pousser ton code :**
   > *Prompt Antigravity :* "Pousse ma branche courante sur le dépôt distant (origin)."
4. **Créer la Pull Request (PR) :**
   > *Prompt Antigravity :* "Génère un template de description de Pull Request pour GitHub basé sur mes derniers commits, expliquant ce qui a été fait et ce qu'il faut tester."
   (Tu ouvres ensuite la PR sur GitHub avec ce texte).
5. **Validation et Fusion (MERGE) :**
   Demande à Ngary de valider. **C'est Ngary qui a les droits pour faire le Merge de ta PR sur GitHub**, car il est le créateur du dépôt.

---

## 🚀 PROMPTS FLUTTER OPTIMISÉS (Phase 2)

Utilise ces prompts en les copiant dans Antigravity. Ils sont structurés pour garantir zéro erreur de contexte.

### 📅 J2 : Splash Screen & Onboarding
```text
Développe le Splash Screen et l'Onboarding de l'application Flutter "baana_app".

⚠️ INSTRUCTION CRITIQUE : Le design doit FORCÉMENT être basé sur les maquettes UI déjà réalisées. Avant d'écrire la moindre ligne de code, tu DOIS :
1. Analyser et reproduire fidèlement les images suivantes (situées dans le dossier des maquettes) :
   - `01_splash.png`
   - `02_onboarding_1.png`
   - `03_onboarding_2.png`
   - `04_onboarding_3.png`
2. Analyser impérativement le code existant (ex: `lib/config/colors.dart`, `typography.dart`) pour réutiliser les composants au lieu de les réinventer.

Contexte Technique :
- Flutter 3.x, GoRouter pour la navigation.
- Design System existant dans `lib/config/colors.dart` et `typography.dart`.

Exigences :
1. Splash Screen (`splash_screen.dart`) : Dégradé émeraude, logo centré, timer de 2.5s puis redirection vers l'onboarding via GoRouter.
2. Onboarding (`onboarding_screen.dart`) : PageView de 3 slides. Utilise un AnimatedContainer pour les indicateurs (dots) et le composant `BaanaButton` pour le CTA final.

Workflow :
1. Implémente le UI avec les animations fluides.
2. Configure les routes dans un fichier `router.dart`.
3. Vérifie que la navigation entre Splash -> Onboarding fonctionne sans accroc.

Critères d'acceptation :
- Le SplashScreen ne doit pas être popable (impossible de faire retour).
- Transitions à 60fps, pas de jank.
- Polices Comfortaa et Nunito appliquées.

Ne pas faire :
- Ne pas utiliser le Material Design de base, force les couleurs du BaanaTheme.
```

### 📅 J3 & J4 : Authentification (OTP) & Connexion API
```text
Implémente le tunnel d'authentification (Inscription et Vérification OTP) et le service API.

⚠️ INSTRUCTION CRITIQUE : Le design doit FORCÉMENT être basé sur les maquettes UI déjà réalisées. Avant d'écrire la moindre ligne de code, tu DOIS :
1. Analyser et reproduire fidèlement les images suivantes :
   - `05_inscription.png`
   - `06_otp.png`
2. Analyser impérativement le code existant pour réutiliser la structure des `BaanaInput` et autres composants du Design System.

Contexte Technique :
- Flutter, package `pinput` pour l'OTP, `Dio` pour le réseau.
- Les données sensibles doivent être gérées via Provider (`AuthProvider`).

Exigences :
1. `RegisterScreen` : Champ téléphone avec `BaanaInput`, préfixe fixe "+221". Clavier en mode `phone`.
2. `OtpScreen` : 4 cases avec `pinput`, auto-focus au caractère suivant.
3. `AuthService` : Service Dio qui appelle le backend Ngary (`POST /api/auth/verify-otp`). Stocke le JWT retourné dans le `FlutterSecureStorage`.
4. Ajoute un intercepteur Dio pour injecter le token "Bearer" dans toutes les requêtes futures.

UX / Ergonomie :
- Boutons en état "loading" (CircularProgressIndicator 24x24) pendant l'appel API.
- SnackBar d'erreur si code OTP incorrect ou réseau indisponible.

Critères d'acceptation :
- Le token JWT est stocké de manière sécurisée.
- Si le token expire (401), l'utilisateur est redirigé vers RegisterScreen.
- Le clavier virtuel se ferme quand on tape à côté des champs.
```

### 📅 J5 & J6 : Accueil, Catalogue & Performance
```text
Développe la HomeScreen et la ProductDetailScreen avec une logique de gestion d'état et d'optimisation.

⚠️ INSTRUCTION CRITIQUE : Le design doit FORCÉMENT être basé sur les maquettes UI déjà réalisées. Avant d'écrire la moindre ligne de code, tu DOIS :
1. Analyser et reproduire fidèlement les images suivantes :
   - `07_accueil.png`
   - `08_catalogue.png`
   - `09_fiche_produit.png`
2. Analyser impérativement le code existant pour garantir une cohérence parfaite de la navigation (`bottomNavigationBar`) et du style (espacements, couleurs, typographies).

Contexte Technique :
- Flutter, CustomScrollView, SliverAppBar, Provider (`ProductProvider`).

Exigences :
1. `HomeScreen` : 
   - Barre de recherche en haut.
   - Catégories en `ActionChip` scrollables horizontalement.
   - Grille (`SliverGrid`) de produits vedettes. Les cartes produits n'ont pas de fond, juste l'image et le texte sur `BaanaColors.background`.
2. `ProductDetailScreen` : Image produit en haut avec `SliverAppBar` qui rétrécit au scroll. Le bouton `BaanaButton` d'ajout au panier doit être "sticky" en bas de l'écran (dans un `bottomNavigationBar` ou un `Positioned`).

Performance & Ergonomie :
- Utilise des images mockées pour l'instant, mais prépare le terrain avec `CachedNetworkImage` pour la Phase 3 (Intégration).
- Ajoute un effet "Shimmer" (chargement fantôme) au lancement de la page d'accueil avant l'affichage des produits.

Critères d'acceptation :
- Le scroll de la grille doit être fluide à 60fps.
- Le bouton "Ajouter au panier" reste visible même quand on scroll.

Ne pas faire :
- Ne pas mettre de Scaffold dans un Scaffold.
- Ne pas faire d'appels API synchrones bloquants l'UI.
```

---

## 🔍 Ta Checklist Quotidienne (Supervision Backend & Git)
L'après-midi, tu fais la revue du code de Ngary via sa Pull Request (PR) sur GitHub.

1. **Vérifie la PR de Ngary :** Demande à Antigravity de faire la review si besoin :
> *"Agis comme un Code Reviewer. Analyse cette Pull Request du backend Node.js. Vérifie : 1/ L'injection SQL, 2/ Les validations express-validator, 3/ La gestion des prix en INTEGER, 4/ La présence du middleware JWT."*
2. **Approuve la PR :** Si tout est bon, valide sa PR sur GitHub.
3. **Autorisation de Merge :** Dis à Ngary "C'est validé, tu peux merge !" (Rappel : C'est Ngary qui exécute le Merge car il gère le repo).
