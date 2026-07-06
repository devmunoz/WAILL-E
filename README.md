# WAILL-E

```text
             .--------.       .--------.
            /  .----.  \     /  .----.  \
           |  /  (o)   |     |   (o)  \  |
           |  \        |     |        /  |
            \  `------' \___/ `------'  /
             `--------'-'   `-'---------'
                         ||
                      ___||___
                  _.-'--------'-._
                 /|  ________  |  \
          ((    / | |WAILL-E | |  |    ))
          ))   |  | |________| |  |   ((
         ((  _ |  |  _      _  |  | _  ))
          \_/ \|  | (_)    (_) |  |/ \_/
              |  |            |  /
               \  \__________/  /
                `--------------'
                  /==========\
                 /  O  O  O   \
                /______________\
```

A minimal, robust framework for fast, tracked, and low-overhead agentic development. Optimized for developers with limited time who need to pick up where they left off without losing context.

## Philosophy

1. **Short, Tracked Iterations**: Avoid context decay by keeping active task state in `.waill-e/ACTIVE_SLICE.md`.
2. **Strict Slicing**: Work in vertical slices of functionality.
3. **Rigid TDD**: Follow the Red-Green-Refactor-Document loop.
4. **Terse Communication**: Use Caveman style to minimize token overhead and keep responses direct.
5. **Interactive Engagement**: Use questions/choices dynamically to resolve ambiguities.

## Getting Started

To use `WAILL-E` in a project:

### Option A: Run the installer script

```bash
curl -fsSL https://raw.githubusercontent.com/devmunoz/WAILL-E/main/install.sh | bash
# optional target path:
curl -fsSL https://raw.githubusercontent.com/devmunoz/WAILL-E/main/install.sh | bash -s -- /path/to/your/project
```

### Option B: Manual setup

1. Copy the framework rules and `.agents/` folder into your project root:
   ```bash
   # 0 clone this repo:
   git clone https://github.com/devmunoz/waill-e.git && cd waill-e

   # 1.a If your project doesn't have an AGENTS.md, copy as AGENTS.md:
   cp WAILL-E.md /path/to/your/project/AGENTS.md

   # 1.b If your project already has an AGENTS.md, copy as WAILL-E.md and reference it:
   cp WAILL-E.md /path/to/your/project/WAILL-E.md
   # Then reference it in your existing AGENTS.md (e.g., "See [WAILL-E.md](WAILL-E.md)").

   # 2. Copy the skills folder:
   cp -r /path/to/waill-e/.agents /path/to/your/project/
   ```

2. **Start iterating**: When the agent is first run, it will automatically create the `.waill-e` folder and initialize `.waill-e/ACTIVE_SLICE.md`.

## Release packaging (maintainers)

The installer downloads this fixed release asset from the latest GitHub release:

- `waill-e-package.tar.gz`

Build it with:

```bash
./scripts/build-release-package.sh
```

This repository also includes a GitHub Action (`.github/workflows/release-package.yml`) that builds and uploads `dist/waill-e-package.tar.gz` automatically when a new tag `v*` (e.g. `vX.Y.Z`) is pushed.

## Updating Skills (maintainers)

To update the skills (`caveman`, `codebase-design`, `grill-me`, `grilling`, `tdd`) to their latest versions from upstream sources, run:

```bash
./scripts/update-skills.sh
```

You can also specify particular skills to update:

```bash
./scripts/update-skills.sh tdd grill-me
```

## Acknowledgements

Skills are sourced from [mattpocock/skills](https://github.com/mattpocock/skills) and [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman), which inspired this framework.