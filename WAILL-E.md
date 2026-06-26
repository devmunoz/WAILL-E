# Repository Guardrails & waill-e Guidelines

This project uses the **waill-e** framework for agentic development. Follow these rules strictly.

## 1. Process & Slicing

- Work in small, vertical slices of functionality.
- Each slice must follow the **TDD Lifecycle** as defined in the **tdd** skill ([SKILL.md](.agents/skills/tdd/SKILL.md)):
  1. **Red**: Write failing tests first.
  2. **Green**: Write code to pass tests.
  3. **Refactor**: Clean up code and structure.
  4. **Document**: Add or update the docs of the repository and give to the user the manual verification instructions.
- **Strict Rule**: You MUST read the `tdd` skill ([SKILL.md](.agents/skills/tdd/SKILL.md)) and follow its tracer bullet workflow (One test -> One implementation -> Repeat) for any feature addition or bug fix.
- **Strict Rule**: Prioritize grilling sessions using the **grill-me** skill ([SKILL.md](.agents/skills/grill-me/SKILL.md)) (always ask if user wants a session) when defining a slice, discussing a deep fix, or if starting a new implementation without defined slices.

## 2. Context Preservation (State Tracking)

- Active state is stored in `.waill-e/ACTIVE_SLICE.md`.
- **Strict Rule**: The agent MUST update `.waill-e/ACTIVE_SLICE.md` at the end of every turn to keep it fresh.
- The file format must be:
  ```markdown
  # Waill-e Active Slice State

  ## Current Context
  - **Active Branch**: <branch-name>
  - **Current Slice**: <slice-description>
  - **Last Test Run**: <command> (Pass/Fail)

  ## Micro-Task Backlog
  - [ ] Task 1
  - [ ] Task 2

  ## Last Completed Step
  - [x] Action description

  ## Next Immediate Action
  - What to do next.
  - Verification command (e.g., `pnpm test test/some.test.ts`).
  ```

## 3. Communication Style (Caveman)

- **Strict Rule**: You MUST strictly use the **caveman** skill ([SKILL.md](.agents/skills/caveman/SKILL.md)) for all responses, keeping communication ultra-compressed and direct.


## 4. Interactive Engagement

- For any design decisions, ambiguities, or choices, prioritize using interactive questions (`ask_question` or multiple-choice formats) to make the session dynamic and fast.

## 5. Security & Secret Management

- Never commit credentials, local system paths, API keys, or databases to git.
- Keep `.waill-e/` untracked or tracked based on project preference (default is untracked).

## 6. Commit Strategy

- Commit after each TDD phase to track development steps:
  - **Red**: Commit failing tests (prefix `test` / `tests`).
  - **Green**: Commit implementation (prefix `feat`).
  - **Refactor**: Commit cleanups (prefix `refactor` / `fix`).
  - **Document**: Commit documentation (prefix `docs`).

## 7. Development Guardrails

### Simplicity First
- **Minimum code**: Write only what was asked. No speculative features or abstractions for single-use code.
- **Complexity check**: Keep code minimal. If a solution can be significantly shorter, rewrite it.

### Surgical Changes
- **Scope limit**: Touch only what you must. Do not refactor or reformat unrelated adjacent code.
- **Clean orphans**: Remove unused imports, variables, or functions created by your changes. Leave pre-existing dead code unless asked.
