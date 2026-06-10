# French Treasury Documentation Skill

Skill pour générer une documentation technique complète en français pour le Système de Gestion de Trésorerie.

## 📁 Structure

```
french-treasury-docs/
├── SKILL.md                    # Instructions complètes du skill
├── README.md                   # Ce fichier
├── glossary.md                 # Glossaire FR/EN complet
├── templates/                  # Modèles de documentation
│   ├── architecture.md         # Template architecture système
│   ├── api.md                  # Template documentation API
│   └── deployment.md           # Template guide déploiement
└── examples/                   # Exemples de documentation
    └── api_reconciliation.md   # Ex: API Rapprochement
```

## 🎯 Utilisation

Pour utiliser ce skill, référencez-le dans votre prompt:

```
@french-treasury-docs Generate API documentation for the Treasury payments module
```

L'agent:
1. Lira `SKILL.md` pour comprendre les instructions
2. Choisira le template approprié (`templates/api.md`)
3. Analysera le code du module
4. Générera la documentation en français
5. Utilisera la terminologie du `glossary.md`

## 📚 Templates Disponibles

| Template | Usage | Description |
|----------|-------|-------------|
| `architecture.md` | Architecture système | Diagrammes C4, stack technique, patterns |
| `api.md` | Documentation API | Endpoints REST, DTOs, codes erreur |
| `deployment.md` | Guide déploiement | Docker, Kubernetes, production |

## 🌍 Composants Couverts

- ✅ **Backend** (`i-sib-tresorerie-service`) - Spring Boot API
- ✅ **ETL** (Treasury Data Hub) - Pipelines Python
- ✅ **Back-office** (`sib-back-office`) - Interface Next.js
- 🔜 **Front-office** - À venir
- 🔜 **AI Agents** - À venir

## 📖 Exemples

Voir `examples/api_reconciliation.md` pour un exemple complet de documentation API du module Rapprochement Bancaire.

## 🔧 Maintenance

Pour ajouter de nouveaux termes:
1. Éditer `glossary.md`
2. Ajouter le mapping FR ↔ EN
3. Inclure une définition claire

Pour créer un nouveau template:
1. Créer `templates/nouveau_template.md`
2. Suivre la structure YAML frontmatter
3. Documenter dans `SKILL.md`

## 📝 Conventions

- **Langue**: Français formel
- **Format**: Markdown avec support Mermaid
- **Terminologie**: Voir `glossary.md`
- **Code**: Commentaires en français

## 🚀 Quick Start

```bash
# Lire les instructions du skill
cat .agent/skills/french-treasury-docs/SKILL.md

# Voir la terminologie
cat .agent/skills/french-treasury-docs/glossary.md

# Explorer les exemples
cat .agent/skills/french-treasury-docs/examples/api_reconciliation.md
```

## 📞 Support

Pour questions ou améliorations, contacter l'équipe de documentation.
