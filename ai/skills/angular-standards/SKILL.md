---
name: angular-standards
description: Team standards for Angular enterprise code. Use BEFORE creating or editing .component.ts, .html templates, .scss, or .util.ts files in an Angular repo — loads the canonical DO/DO-NOT instruction set for the exact file type being touched.
---

# Angular Standards

Before writing or editing an Angular file, read the canonical instruction set
for that file type — only the one(s) you need. Resolve the directory in this
order:

1. `.github/instructions/` in the current repo (scaffolded repos)
2. `$DOTFILES_DIR/ai/instructions/` (fallback: `~/.dotfiles/ai/instructions/`)

| Editing | Read |
|---|---|
| `*.component.ts` | `components.instructions.md` |
| `*.html` | `html.instructions.md` |
| `*.scss` | `scss.instructions.md` |
| `*.util.ts` | `util.instructions.md` |

## Non-negotiables (summary — the files above are authoritative)

- **Components**: OnPush; `takeUntilDestroyed()`/`DestroyRef` over OnDestroy;
  signals/observables over mutation; complex logic extracted to `*.util.ts`;
  container/presentational split; typed everything.
- **Templates**: @covalent components first; `data-pw` attributes for e2e;
  reactive forms; async pipe; trackBy on loops; i18n pipes — zero static
  text; no logic in templates; sanitize anything dynamic.
- **SCSS**: theme variables; BEM; nesting ≤ 3; low specificity; no global
  styles from component files; transform/opacity for animations.
- **Utils**: pure, typed, individually exported, single-responsibility;
  Web Workers for CPU-heavy paths; memoize expensive calls; exhaustive edge
  cases in specs.

Honor the DO NOT lists in each file: they exclude entire finding categories
(e.g. accessibility nits in templates, formatting nits everywhere) — do not
reintroduce them "to be helpful".
