# Claude Code Expert Toolkit

> Plugin premium pour Claude Code avec barre de statut avancee, limites de compte en temps reel, skills puissantes et auto-permissions.

[![Version](https://img.shields.io/badge/version-4.0.0-blue.svg)](https://github.com/Tim0219800/claudecode_expert_toolkit)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20|%20Linux%20|%20macOS-lightgrey.svg)]()

---

## Apercu

```
~/my-project (main*)  Opus  45m
5H 35% [===-----] 2h15m  7J 12% [=-------] 5j
CTX 28% [===-------] 56k  $2.45  +150/-23
```

### Ce que la barre affiche en temps reel :

| Ligne | Contenu |
|-------|---------|
| **1** | Projet, branche Git, modele Claude, duree session |
| **2** | **Limites compte REELLES** : session 5h (%) + reset, hebdo 7j (%) + reset |
| **3** | Contexte (%), tokens utilises, cout session, lignes modifiees |

### Nouveaute v4.0 : Vraies donnees du compte

La barre de statut recupere maintenant vos **vraies limites d'utilisation** directement depuis l'API Anthropic :
- **5H** : Pourcentage de votre session de 5 heures + temps avant reset
- **7J** : Pourcentage de votre limite hebdomadaire + jours avant reset

Ces donnees correspondent exactement a ce que vous voyez sur [claude.ai/settings/usage](https://claude.ai/settings/usage).

---

## 16 Skills Integrees

| Skill | Description |
|-------|-------------|
| `/stats` | Dashboard detaille de la session |
| `/history` | Historique de toutes les sessions |
| `/quick-commit` | Commit rapide avec message auto-genere |
| `/review` | Review de code professionnelle |
| `/explain` | Explication detaillee du code |
| `/fix` | Correction auto des erreurs lint/type |
| `/test` | Lancer les tests et corriger les echecs |
| `/refactor` | Suggestions de refactoring |
| `/docs` | Generation de documentation |
| `/perf` | Analyse de performance |
| `/deploy` | Deploiement automatise |
| `/budget` | Suivi des couts et alertes |
| `/project-init` | Setup CLAUDE.md et config |
| `/todo` | Liste de taches persistante |
| `/notes` | Notes rapides par projet |
| `/update` | Verification des mises a jour |

---

## Auto-Permissions

Plus de confirmations pour les operations courantes :

- **Fichiers** : lecture, ecriture, edition
- **Git** : status, add, commit, push, pull, branch
- **Package managers** : npm, yarn, pnpm, pip, cargo, go
- **Outils dev** : TypeScript, ESLint, Prettier, Jest, Pytest

---

## Installation

### Windows (PowerShell)

```powershell
git clone https://github.com/Tim0219800/claudecode_expert_toolkit.git
cd claudecode_expert_toolkit
.\install.ps1
```

### Linux / macOS

```bash
git clone https://github.com/Tim0219800/claudecode_expert_toolkit.git
cd claudecode_expert_toolkit
chmod +x install.sh
./install.sh
```

### Installation rapide (une ligne)

**Windows :**
```powershell
iwr -useb https://raw.githubusercontent.com/Tim0219800/claudecode_expert_toolkit/main/install-remote.ps1 | iex
```

**Linux/macOS :**
```bash
curl -fsSL https://raw.githubusercontent.com/Tim0219800/claudecode_expert_toolkit/main/install-remote.sh | bash
```

---

## Utilisation

Apres installation, **redemarrez Claude Code** :

```bash
claude
```

La barre de statut apparait automatiquement. Utilisez les skills en tapant leur nom :

```
/stats            # Dashboard de session
/quick-commit     # Commit avec message auto
/fix              # Corriger les erreurs
/review           # Review du code
```

---

## Configuration

Les parametres sont dans `~/.claude/settings.json`.

### Personnaliser les permissions

```json
{
  "permissions": {
    "allow": [
      "Bash(docker *)",
      "Bash(kubectl *)"
    ]
  }
}
```

### Desactiver la barre de statut

```json
{
  "statusLine": null
}
```

---

## Mise a jour

### Windows

```powershell
cd claudecode_expert_toolkit
git pull
.\install.ps1 -Update
```

### Linux/macOS

```bash
cd claudecode_expert_toolkit
git pull
./install.sh --update
```

---

## Desinstallation

### Windows

```powershell
.\install.ps1 -Uninstall
```

### Linux/macOS

```bash
./install.sh --uninstall
```

---

## Structure des fichiers

```
~/.claude/
├── settings.json          # Configuration principale
├── statusline.ps1         # Script barre de statut (Windows)
├── statusline.sh          # Script barre de statut (Linux/macOS)
├── .credentials.json      # Token OAuth (utilise pour les stats)
├── commands/              # Skills
│   ├── stats.md
│   ├── quick-commit.md
│   ├── review.md
│   └── ...
├── hooks/                 # Hooks automatiques
│   └── save-session.ps1   # Sauvegarde auto des sessions
└── history/               # Donnees de session
    └── sessions-index.json
```

---

## Changelog

### v4.0.0 (2024-12-28)
- **Vraies limites de compte** : Recuperation des % d'utilisation session/hebdo via l'API Anthropic
- **Temps avant reset** : Affichage du temps restant avant reset de la session et de la semaine
- **Correction emojis Windows** : Remplacement des emojis par des alternatives ASCII compatibles

### v3.0.0
- Statistiques hebdomadaires avec budget configurable
- Estimation du temps avant reset du contexte

### v2.0.0
- Statistiques hebdomadaires persistantes
- 16 skills integrees
- Auto-permissions

---

## Comment ca marche

Le script statusline utilise l'endpoint API `https://api.anthropic.com/api/oauth/usage` avec votre token OAuth (stocke dans `~/.claude/.credentials.json`) pour recuperer vos vraies limites d'utilisation.

**Important** : Cet appel API ne consomme PAS de credits - c'est simplement une lecture de vos statistiques.

---

## Contribuer

Les contributions sont les bienvenues !

1. Fork le repository
2. Creez une branche feature
3. Faites vos modifications
4. Soumettez une pull request

### Ajouter une nouvelle skill

1. Creer `src/commands/votre-skill.md`
2. Ajouter le frontmatter YAML avec description
3. Ecrire les instructions
4. Lancer l'installateur

---

## License

MIT License - voir [LICENSE](LICENSE)

---

## Support

- [Signaler un probleme](https://github.com/Tim0219800/claudecode_expert_toolkit/issues)
- [Discussions](https://github.com/Tim0219800/claudecode_expert_toolkit/discussions)

---

## Credits

- Endpoint API decouvert grace a [codelynx.dev](https://codelynx.dev/posts/claude-code-usage-limits-statusline)
- Inspiration de [Claude-Usage-Tracker](https://github.com/hamed-elfayome/Claude-Usage-Tracker)
