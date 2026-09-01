# 🏗️ SchemaCraft - Database Diagram Visual Editor

SchemaCraft is a professional IDE that turns your database schema code into an interactive visual diagram in real-time. Instead of drawing tables by hand or guessing relationship flows, you write your schema code on the left, and SchemaCraft compiles the visual architecture on the right.

## 🎯 What is this?

It is a "Code-to-Diagram" editor. You write PostgreSQL/Standard SQL, DBML, or Prisma Schema code in the Monaco editor, and get an interactive, draggable entity-relationship diagram on the canvas. It uses a real Postgres engine and AST validators to check syntax with line-level diagnostics in real-time.

## 🚀 Why use this?

**Who it's for:** Backend Developers, Database Administrators (DBAs), System Architects, and Students.

**Key Advantages:**

- **Zero Guesswork:** Visualize multi-table foreign key relationships instantly without manual layout chores.
- **Catch Errors Early:** Real-time Monaco syntax diagnostic markers flag syntax issues with line and column precision.
- **Multi-Tab Workspace:** Work with multiple isolated database schema files in tabs.
- **Bi-Directional Translation:** Switch between SQL, DBML, and Prisma, or convert schemas into new workspace tabs.
- **Automated Smart Layout:** Powered by Eclipse Layout Kernel (ELK) to auto-arrange tables and minimize edge crossings.
- **High-Res Export:** Save diagrams as 2x PNG, vector SVG, or JPEG, or transpile schemas into TypeScript types, DBML, and Prisma.

## 🛠️ Installation Guide

### Prerequisites

- **Node.js** (v18+ LTS recommended)
- **npm** or **yarn** / **pnpm**

### Setup Steps

1. **Clone the project:**

   ```bash
   git clone https://github.com/yourusername/database-diagram-visual-editor.git
   cd database-diagram-visual-editor
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Run the development server:**

   ```bash
   npm run dev
   ```

4. **Open the app:**
   Navigate to `http://localhost:9000` (or `http://localhost:3000`) in your browser.

## 📖 How to Use

1. **Write Code:** Type DDL statements in SQL, DBML, or Prisma.
2. **Validate:** Syntax errors appear with red squiggly lines and detailed tooltips.
3. **Visualize & Rearrange:** Tables render dynamically. Hit **Auto-Layout** or `⌘S` / `Ctrl+S` to compute an optimal ELK layered layout.
4. **Explore:**
   - Drag tables to custom positions.
   - Hover over columns to inspect constraints (like `CHECK`, `UNIQUE`, `NOT NULL`, defaults, and documentation notes).
   - Use the **Language Selector** to switch view modes or trigger **Convert to Tab**.
5. **Export:** Export schemas as TypeScript interfaces, Prisma models, DBML, or high-resolution diagram images.

## ⚙️ Features at a Glance

- ✅ **Real-time AST Validation:** Powered by PostgreSQL engine and language validators.
- ✅ **Multi-Language Architecture:** Full support for Standard SQL, DBML, and Prisma Schema.
- ✅ **ELK Smart Auto-Layout:** Layered graph layout engine for clean relationship routing.
- ✅ **Multi-Tab Sessions:** Independent schema tabs with File System Access API integration.
- ✅ **Developer Themes:** Midnight Slate, Monokai Classic, Dracula Dark, Nordic Frost, and Clean Light.
- ✅ **Mobile & Responsive:** Split-pane desktop view with a dedicated preview mode on mobile devices.
