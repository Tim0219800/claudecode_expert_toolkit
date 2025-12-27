# Claude Code Expert Toolkit

> Plugin premium pour Claude Code avec barre de statut avancée, skills puissantes et auto-permissions.

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/Tim0219800/claudecode_expert_toolkit)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20|%20Linux%20|%20macOS-lightgrey.svg)]()

---

## Apercu

```
📁 ~/my-project  🌿 main  🤖 Claude Opus 4  📟 v2.0.0
⏱️ Session: 45m 23s
🧠 Context: 35% used / 65% remaining [==========-----]  ⏳ Reset in: ~2h 15m
💰 $2.45 ($3.20/h)  📊 125,430 tok (2,845 tpm)
📅 This week: 5 sessions  💵 $12.50  🕐 3h45m  📈 450,000 tok
```

La barre de statut affiche en temps reel :
- **Repertoire** et **branche Git** actuelle
- **Modele** Claude utilise + version Claude Code
- **Duree** de la session (heures, minutes, secondes)
- **Contexte** avec barre de progression et temps estime avant reset
- **Cout** de la session avec taux horaire
- **Tokens** utilises avec vitesse (tokens/minute)
- **Statistiques hebdomadaires** : sessions, cout total, duree, tokens

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
├── statusline.sh          # Script barre de statut (Linux/macOS)
├── statusline.ps1         # Script barre de statut (Windows)
├── weekly_stats.json      # Statistiques hebdomadaires persistantes
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

### Nouveautes v2.0.0

- **Statistiques hebdomadaires** : Suivi automatique du nombre de sessions, cout cumule, duree totale et tokens utilises par semaine
- **Fichier persistant** : `weekly_stats.json` stocke les donnees entre les sessions
- **Reset automatique** : Les stats se remettent a zero chaque dimanche

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
