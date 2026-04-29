# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Patagonia 2050 is a 3D game built with Godot 4.6 using GDScript. The project uses the `bro` CLI tool for development workflow management.

## Bro CLI

Bro CLI is an internal tool developed by Belisario Studio for Godot game development workflow. It handles Godot version management, git hooks, project validation, and media conversion. Configuration lives in `.bro.toml` and local state in `.bro/local.toml`.

## Commands

**Open the Godot editor:**
```bash
bro godot open
```

**Run the game:**
```bash
bro godot run
```

**Run linter and validations (this is the main command for linting):**
```bash
bro check commit
```

**Run only the custom linter (called internally by bro check commit):**
```bash
godot --headless --path . --script .bro/lint.gd
```

## Project Structure

```
patagonia-2050/
├── .bro.toml          # Bro CLI config
├── .bro/              # Local state + tooling scripts
│   ├── lint.gd        # Custom GDScript linter
├── godot_bin/         # Local Godot installation
├── docs/              # Documentation
└── game/              # Godot project root
    ├── project.godot
    ├── main.tscn      # Entry point scene
    ├── player.tscn    # Player with camera system
    └── map.tscn       # Game world
```

## Linting Rules

The custom linter enforces:
- **no-nested-if**: No if statements inside other if blocks. Use early returns or guard clauses.
- **no-else**: No else/elif blocks. Use early returns or guard clauses.
- **no-runtime-paths**: Use `preload()` instead of `load()` with string paths. This ensures paths are validated at parse time and the editor can track references when files are moved.

## Code Style

- Never write comments in Spanish
- Use early returns and guard clauses instead of nested conditionals
- Follow GDScript conventions (snake_case for functions/variables, PascalCase for classes)
