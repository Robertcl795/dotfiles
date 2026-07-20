---
description: Scaffold an Angular feature (container + presentational + utils + specs)
---

Scaffold a new Angular feature: $ARGUMENTS

First run the `planner` subagent to produce the component tree, file paths
and state design for this feature, mirroring the conventions of the
surrounding code (module boundaries, naming, lazy loading).

Then implement the scaffold following the plan and the team's instruction
sets (resolve them from `.github/instructions/` in this repo, else
`~/.dotfiles/ai/instructions/`):

- Container (smart) component: OnPush, signals/observables for state, data
  fetching via injected services, error handling for async operations
- Presentational component(s): OnPush, `input()`/`output()`, no business
  logic, @covalent components, `data-pw` attributes, i18n pipes — no static
  text
- `*.util.ts` for any non-trivial logic: pure, typed, individually exported
- SCSS per component: BEM, max 3 nesting levels, theme variables
- Spec files for every component and util (delegate to `test-writer` if the
  logic is non-trivial)

Show me the final file tree and run whatever lint/test targets the repo
defines for the touched project.
