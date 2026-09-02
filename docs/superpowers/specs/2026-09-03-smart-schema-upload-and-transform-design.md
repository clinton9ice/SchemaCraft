# Smart Schema Ingestion, Transformation & Multi-Tab Management Specification

> **Document Type:** Feature Specification & Architecture Plan  
> **Date:** September 3, 2026  
> **Status:** Draft (Pending User Approval)  
> **Target Surface:** File Upload, Transformation Engine, Multi-Tab Editor, iOS-Style Dialogs, Documentation Hub

---

## 1. Executive Summary & Vision

Postgres Visual Architect ("SchemaCraft") requires an intelligent, resilient file ingestion pipeline. When users upload external SQL dumps—frequently originating from MySQL/MariaDB environments (such as phpMyAdmin dumps like `vestnan1_db.sql` or incremental scripts like `add_columns.sql`)—the raw input contains dialect-specific keywords (`USE`, backticks, `ENGINE=InnoDB`, `AUTO_INCREMENT`, `int(11)`) that break the native PostgreSQL parser (`pg-query-emscripten`).

Rather than failing abruptly with cryptic syntax errors, SchemaCraft will provide a guided, human-centered experience:

1. **Safety Guards:** Strict file size inspection ($\le$ 1MB) with actionable oversize modals, and a maximum 3-file batch upload rule.
2. **Interactive Progress Feedback:** A soothing, iOS-styled dialog with active progress meters and staged conversational status copy for network and processing feedback.
3. **Smart Dialect Detection & Transformation:** Automatic recognition of MySQL/MariaDB constructs, pausing for user approval per file (**Decline** to skip or **Proceed** to transform), converting to standards-compliant PostgreSQL DDL with zero server burden.
4. **Workspace Guardrails (10-Tab Ceiling):** Hard ceiling of 10 editor tabs with a one-click **"Export All as collection.zip"** feature to preserve and archive user work.
5. **Comprehensive Product Marketing & Documentation:** Updating the `/docs` documentation hub with detailed language capabilities and system capabilities once development is concluded and explicitly approved.

---

## 2. Strict Phasing & Human Gate Protocol

> [!IMPORTANT]
> **CRITICAL EXECUTION RULE:**  
> The implementation is strictly divided into **5 sequential phases**. Under no circumstances will any subsequent phase begin until the user has explicitly verified the previous phase and issued the direct instruction to proceed.

---

## 3. Phase Breakdown

### Phase 1: Guards, Tab Ceiling & Collection Zip Exporter

- **File Size Validation Guard:**
  - Files $> 1\text{ MB}$ ($1,048,576\text{ bytes}$) trigger the **File Oversize Modal**.
  - Modal copy: _"This board can only accept files less than or equal to 1MB. Please consider splitting your queries for easy execution."_
  - Buttons: **Dismiss** and **Reupload**.
- **Max 3 Files Upload Enforcement:**
  - If more than 3 files are selected, alert the user that a maximum of 3 files can be uploaded at a time.
- **Strict 10-Tab Workspace Ceiling:**
  - When user has 10 tabs open and attempts to add or upload, or when a batch would exceed 10 tabs, only process up to the 10th tab and display the **Tab Limit Reached Modal**:
    _"You will need to export and save the files you're done with to free up more tabs as you're only allowed to open just 10 tabs per task."_
  - Action button: **"Export All as collection.zip"** (plus Dismiss).
- **Zero-Dependency Collection Zip Exporter (`utils/zip-exporter.ts`):**
  - Pure TypeScript client-side PKZIP generator with CRC32 calculation.
  - Bundles all open tabs with their respective file names and contents into `collection.zip`.
  - Zero external package dependencies, zero security vulnerabilities, lightweight and lightning-fast.
- **Verification:** Unit tests in Vitest for `zip-exporter.test.ts` and tab limit logic.

---

### Phase 2: MySQL-to-PostgreSQL Detection & Transformation Engine

- **Dialect Detector (`utils/sql-dialect-detector.ts`):**
  - Detects MySQL/MariaDB syntax: backticks (`` `...` ``), `USE <db>;`, `ENGINE=...`, `DEFAULT CHARSET=...`, `AUTO_INCREMENT`, `int(...)`, `tinyint`, `datetime`, `longtext`, `COLLATE=...`, `/*!40101 ... */`, `SET SQL_MODE=...`, `DESCRIBE ...;`.
  - Distinguishes standard ANSI/PostgreSQL DDL from MySQL dumps.
- **Client-Side DDL Transformer (`utils/mysql-to-postgres-transformer.ts`):**
  - Runs 100% on the client to avoid server load and ensure snappy responsiveness.
  - Converts backtick identifiers to unquoted or double-quoted identifiers.
  - Strips session headers (`USE`, `SET`, conditional comments, `START TRANSACTION`, `COMMIT`).
  - Translates MySQL types to PostgreSQL equivalents (`int(11)` $\rightarrow$ `INTEGER`, `longtext` $\rightarrow$ `TEXT`, `datetime` $\rightarrow$ `TIMESTAMPTZ`, `varchar(N)` $\rightarrow$ `VARCHAR(N)`).
  - Handles `AUTO_INCREMENT` and converts `PRIMARY KEY` specifications into `SERIAL PRIMARY KEY` or identity columns.
  - Strips table option clauses (`ENGINE=InnoDB`, `DEFAULT CHARSET=...`).
  - Ignores or removes data dump rows (`INSERT INTO ...`) so the visual editor focuses strictly on schema DDL.
- **Verification:** Vitest suite testing `vestnan1_db.sql` and `add_columns.sql` to verify error-free conversion to valid PostgreSQL DDL.

---

### Phase 3: Soothing iOS-Style Upload & Queue Progress Modal

- **Component (`components/features/editor/schema-upload-modal.vue`):**
  - **iOS Dialog Design System (Impeccable Craft):**
    - Frosted glass backdrop blur (`backdrop-blur-2xl bg-neutral-900/80 dark:bg-black/80`).
    - Smooth rounded corners (`rounded-3xl`), delicate hairline border (`border border-white/10`).
    - Tactile button feedback with iOS-inspired spring motion and calming accent colors.
  - **Dynamic Progress Feedback:**
    - Live progress bar (0% to 100%) with stage transitions.
    - Context-aware status copy:
      - _0% – 30%_: _"Uploading file, this should not take long now..."_
      - _30% – 70%_: _"Reading file to determine SQL commands and structure..."_
      - _70% – 95%_: _"Analyzing syntax and dialect compatibility..."_
      - _100%_: _"Analysis complete!"_
  - **Sequential Multi-File Queue:**
    - Queue banner showing current item: e.g., _"Processing File 1 of 3: vestnan1_db.sql"_.
  - **Dialect Discrepancy Prompt (Per File):**
    - Summarizes detected dialect: explains that the file contains MySQL/MariaDB syntax not natively supported by the PostgreSQL engine, and offers transformation to PostgreSQL DDL.
    - Buttons: **Decline** (skips this file, notifies user, advances to next queued file) and **Proceed** (begins transformation).
  - **Transformation Feedback & Completion:**
    - Transformation progress bar with feedback: _"Transforming identifiers and types to PostgreSQL..."_
    - Completion state with a prominent **Visualise** button.

---

### Phase 4: Integration with Multi-Tab Editor, Header & Canvas

- **Header & File Picker Integration (`components/shared/header.vue`):**
  - Connect upload button and drag-and-drop zone to the new `schema-upload-modal`.
  - Support multi-file selection (capped at 3).
- **Tab Appending & Activation:**
  - Processed files are appended as new tabs in `useSchemaStore`.
  - When the user clicks **Visualise**, the modal closes, the newly opened tabs appear in the tab bar, and the first uploaded file in the batch is focused and parsed.
  - Canvas renders the interactive ERD diagram immediately without syntax errors.
- **Verification:** Full end-to-end integration test of uploading `vestnan1_db.sql` and `add_columns.sql`, verifying smooth tab addition, tab switching, and diagram generation.

---

### Phase 5: Comprehensive Documentation Hub Update (Final Phase)

> [!NOTE]
> Phase 5 will NOT be started until all technical phases are fully tested, verified, and the user gives explicit approval to write the documentation.

- **Updated Surface:** `pages/docs.vue` and markdown documentation.
- **Writing Standard:** Authored following the `/product-marketing` and `/document-writer` standards (active voice, clear structure, comprehensive feature breakdown, positioning, supported languages in detail, and future capabilities).
- **Key Sections Covered:**
  1. Multi-dialect ingestion and intelligent MySQL-to-PostgreSQL transformation.
  2. Complete language matrix (PostgreSQL, SQL, DBML, Prisma, TypeORM, Drizzle, and MySQL migration).
  3. Workspace limits, multi-tab workflows, and one-click Collection Zip export.
  4. Visual ERD capabilities and constraint tooltips.

---

## 4. User Review & Step Gate Acknowledgment

Each phase will be executed as an isolated milestone:

1. **Phase 1** will be implemented, tested, and verified first.
2. The agent will **stop** and await user review and explicit order to proceed before touching Phase 2.
3. This sequence repeats for Phase 3, Phase 4, and Phase 5.
