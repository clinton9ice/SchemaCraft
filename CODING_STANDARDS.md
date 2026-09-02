# 🛠️ AI Coding Standards: Postgres Visual Architect

You are an expert Nuxt 3 and Vue 3 developer. You MUST adhere to these standards for every line of code you write in this project. No exceptions.

## 1. Architecture & Logic Flow

The system must follow a strict unidirectional data flow:
`Input Text (SQL/DBML/Prisma/TypeORM/Drizzle)` $\rightarrow$ `Language Parser (SQL or TS-AST)` $\rightarrow$ `AST` $\rightarrow$ `Compiler/Utility` $\rightarrow$ `Standardized JSON Schema` $\rightarrow$ `Vue Flow Component`.

### Separation of Concerns:

- **`Parsers/`**: Pure functions that take a string and return an AST. Note: For TypeORM and Drizzle, use TS-AST parsing (e.g., `ts-morph`).
- **`Compiler/`**: Logic that transforms ASTs into the internal JSON Schema (`{ tables: [], relations: [] }`).
- **`Components/`**: Purely visual. They consume the JSON Schema.
- **`Composables/`**: Manage shared state (e.g., active tab, current theme) using the Nuxt 3 Composition API.

---

## 2. Mandatory Implementation Rules

### A. Testing (Zero-Tolerance Policy)

- **Requirement:** Every single new Composable, Utility function, and Component MUST have a corresponding test file.
- **Tooling:**
  - Use `Vitest` for logic, utilities, and composables.
  - Use `Nuxt Test` for component rendering and integration tests.
- **Definition of Done:** A feature is NOT complete until the tests are written and passing.

### B. Asset & Icon Management

- **Rule:** NEVER use `<img>` tags or direct SVG imports in components.
- **Storage:** All SVGs must be stored in `assets/svg/[dir]/[icon].svg` (organized by directory).
- **Implementation:** SVGs must never be called directly. Always use the global `Icon` component located in `components/tools/Icon.vue`.
- **Icon Component Props:**
  - `height`: Height of the icon.
  - `width`: Width of the icon.
  - `dir`: The name of the sub-folder within `assets/svg/`.
  - `icon`: The name of the SVG file.
- **Example:** `<Icon dir="navigation" icon="settings" width="20" height="20" />`

### C. Styling & Aesthetics

- **Palette:** Use a curated, professional color pattern. Avoid generic "AI-generated" look (no over-reliance on standard neon gradients or default Material UI colors).
- **Consistency:** Maintain high contrast for accessibility while keeping the UI clean and minimal.
- **Theming:** All components must support the Global Theme state (Light/Dark/Monokai). Use Tailwind `dark:` classes or CSS variables.
- **Monokai Dark:** This theme must apply to the Monaco Editor, the UI Shell, and the Vue Flow canvas background.

### D. Performance & Bloat

- **Rule:** Favor native Web APIs over external libraries.
- **Optimization:** Implement a 300ms debounce on the validation loop to prevent UI lag during typing.
- **Vue Flow:** Use `shallowRef` for large node/edge arrays to prevent unnecessary reactivity overhead.
- **TS Parsing:** For TypeORM/Drizzle AST parsing, consider using Web Workers to avoid blocking the main thread.

---

## 3. Nuxt 3 / Vue 3 Coding Patterns

- **Naming Conventions:**
  - **Files:** Use `kebab-case` for all file names (e.g., `user-profile.vue`, `use-schema-parser.ts`).
  - **Templates:** Use `kebab-case` when referencing components in templates. Use `<tools-icon />` instead of `<ToolsIcon />`.
- **Script Setup:** Always use `<script setup lang="ts">`.
- **TypeScript:**
  - **Strict Typing:** Mandatory. Define interfaces for the JSON Schema and ASTs.
  - **Forbidden:** The `any` keyword is STRICTLY FORBIDDEN. Use `unknown` or specific interfaces.
- **State Management:** Use Pinia or Nuxt Composables. Avoid prop-drilling.
- **Components:** Keep components small and focused. Break down the `TableNode` into `TableHeader` and `TableRow`.

---

## 4. Linting & Code Quality

- **Zero-Warning Policy:** No warnings or errors are allowed. If a lint error or warning exists, it MUST be resolved before moving to another task.
- **Consistent Formatting:** Use the defined Prettier configuration with TypeScript to ensure global formatting consistency.
- **Git Flow:** All commits must pass the Husky pre-commit hooks (lint-staged $\rightarrow$ prettier $\rightarrow$ eslint).

---

## 5. AI Pre-Submission Checklist

Before you mark a task as complete, you MUST verify the following:

- [ ] Does this change have corresponding `Vitest` or `Nuxt Test` coverage?
- [ ] Are all icons implemented via `components/tools/Icon.vue`?
- [ ] Is the logic separated into Parser $\rightarrow$ Compiler $\rightarrow$ Component?
- [ ] Does the UI match the professional color palette (non-AI look)?
- [ ] Is the code self-documenting with clear naming (No jargon comments)?
- [ ] Does the implementation remain performant (debounced, lean bundle)?
- [ ] Is the code fully responsive (Draggable Split $\leftrightarrow$ Mobile Toggle)?
- [ ] Do TypeORM/Drizzle conversions correctly handle TS-AST parsing?
- [ ] Are all files and components named in `kebab-case`?
- [ ] Is there zero usage of the `any` keyword?
- [ ] Are there zero linting warnings or errors?
