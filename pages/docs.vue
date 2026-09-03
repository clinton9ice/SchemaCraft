<script setup lang="ts">
useHead({
  title: 'SchemaCraft Documentation - Database Diagram Visual Editor',
  link: [
    {
      rel: 'stylesheet',
      href: 'https://fonts.googleapis.com/css2?family=Public+Sans:ital,wght@0,400;0,500;0,600;0,700;1,400&display=swap',
    },
  ],
  meta: [
    {
      name: 'description',
      content:
        'Comprehensive documentation, language support reference, smart upload pipeline, and future potentials for SchemaCraft Database Diagram Visual Editor.',
    },
  ],
})

const activeSection = ref('getting-started')
const scrollContainerRef = ref<HTMLElement | null>(null)

const sections = [
  { id: 'getting-started', label: '🚀 Getting Started' },
  { id: 'smart-ingestion', label: '⚡ Smart Ingestion & Queue' },
  { id: 'dialect-engine', label: '🔄 MySQL Dialect Engine' },
  { id: 'language-ecosystem', label: '🌐 Supported Languages & ORMs' },
  { id: 'workspace-collection', label: '🗂️ Multi-Tab & Collection.zip' },
  { id: 'export-suite', label: '📦 Export Suite & Transpiler' },
  { id: 'platform-potentials', label: '🔮 Potentials & Roadmap' },
  { id: 'keyboard-shortcuts', label: '⌨️ Keyboard Shortcuts' },
  { id: 'theme-suite', label: '🎨 Monokai & Theme Suite' },
]

function scrollTo(id: string) {
  activeSection.value = id
  const target = document.getElementById(id)
  if (target && scrollContainerRef.value) {
    target.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }
}

// Scroll spy: Update active section on scroll
function handleScroll() {
  const sectionIds = sections.map(s => s.id)
  const scrollPos = scrollContainerRef.value?.scrollTop || 0

  for (const id of sectionIds) {
    const el = document.getElementById(id)
    if (el) {
      const top = el.offsetTop - 120
      const height = el.offsetHeight
      if (scrollPos >= top && scrollPos < top + height) {
        activeSection.value = id
        break
      }
    }
  }
}

onMounted(() => {
  const container = scrollContainerRef.value
  if (container) {
    container.addEventListener('scroll', handleScroll, { passive: true })
  }
})

onBeforeUnmount(() => {
  const container = scrollContainerRef.value
  if (container) {
    container.removeEventListener('scroll', handleScroll)
  }
})
</script>

<template>
  <div
    ref="scrollContainerRef"
    class="h-screen w-screen bg-[#0d1117] text-neutral-200 font-public-sans flex flex-col overflow-y-auto overflow-x-hidden scroll-smooth select-text"
  >
    <!-- Top Navigation Header (Sticky) -->
    <header
      class="h-14 border-b border-[#2d2d30] bg-[#161b22]/95 px-6 flex items-center justify-between sticky top-0 z-40 backdrop-blur-md shrink-0 select-none"
    >
      <div class="flex items-center gap-3">
        <nuxt-link to="/" class="flex items-center gap-2.5 group">
          <div
            class="w-8 h-8 rounded-lg bg-gradient-to-tr from-blue-600 to-indigo-500 flex items-center justify-center shadow-md shadow-blue-500/20 text-white font-bold"
          >
            <tools-icon
              dir="editor"
              icon="database"
              width="16"
              height="16"
              svg-class="text-white"
            />
          </div>
          <div class="flex flex-col">
            <span
              class="font-bold text-sm tracking-tight text-white group-hover:text-blue-400 transition-colors"
            >
              SchemaCraft
            </span>
            <span class="text-[10px] font-medium text-neutral-400 font-mono"
              >Documentation Hub</span
            >
          </div>
        </nuxt-link>
      </div>

      <div class="flex items-center gap-3">
        <nuxt-link
          to="/"
          class="inline-flex items-center gap-2 px-3.5 py-1.5 bg-blue-600 hover:bg-blue-500 text-white text-xs font-semibold rounded-lg shadow-sm transition-colors cursor-pointer"
        >
          <tools-icon
            dir="editor"
            icon="arrow-left"
            width="14"
            height="14"
            svg-class="text-white"
          />
          <span>Back to Editor</span>
        </nuxt-link>
      </div>
    </header>

    <!-- Main Content Layout -->
    <div class="flex-1 max-w-7xl w-full mx-auto px-6 py-8 grid grid-cols-1 md:grid-cols-4 gap-8">
      <!-- Left Sticky Sidebar Nav (Scroll Spy) -->
      <aside class="hidden md:block col-span-1">
        <div
          class="sticky top-20 space-y-1.5 text-xs font-medium bg-[#161b22]/50 border border-[#2d2d30] p-2.5 rounded-xl shadow-lg"
        >
          <span
            class="text-[10px] uppercase font-mono font-medium tracking-wider text-neutral-400 block px-3 py-1 mb-1 border-b border-[#2d2d30]"
          >
            Documentation Index
          </span>
          <button
            v-for="s in sections"
            :key="s.id"
            type="button"
            class="w-full text-left px-3 py-2 rounded-lg transition-all duration-150 flex items-center justify-between cursor-pointer font-medium"
            :class="[
              activeSection === s.id
                ? 'bg-blue-600/20 text-blue-400 font-semibold border-l-2 border-blue-500'
                : 'text-neutral-400 hover:text-neutral-200 hover:bg-white/5 border-l-2 border-transparent',
            ]"
            @click="scrollTo(s.id)"
          >
            <span>{{ s.label }}</span>
            <span
              v-if="activeSection === s.id"
              class="w-1.5 h-1.5 rounded-full bg-blue-400 animate-pulse"
            />
          </button>
        </div>
      </aside>

      <!-- Main Docs Articles Area -->
      <main class="col-span-1 md:col-span-3 space-y-16 pb-32">
        <!-- 1. Getting Started Section -->
        <section id="getting-started" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono font-medium text-blue-400 mb-1">
              <span>01 / 09</span>
              <span>•</span>
              <span>Platform Overview</span>
            </div>
            <h1 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>🚀 Getting Started with SchemaCraft</span>
            </h1>
            <p class="text-base text-neutral-300 mt-2 leading-relaxed font-normal">
              SchemaCraft is a developer-first database architecture and diagramming platform
              designed to transform raw DDL SQL, ORM definitions, and heterogeneous database dumps
              into interactive, production-ready Entity-Relationship diagrams in real time.
            </p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div class="bg-[#161b22] border border-[#2d2d30] p-4 rounded-xl space-y-2">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span
                  class="w-5 h-5 rounded-full bg-blue-500/20 text-blue-400 flex items-center justify-center text-xs font-medium"
                  >1</span
                >
                Dual Split-Pane Studio
              </span>
              <p class="text-base text-neutral-300 leading-relaxed font-normal">
                Code on the left with full Monaco syntax highlighting, auto-complete, and instant
                syntax diagnostics. View and navigate interactive visual ER diagrams on the right
                canvas.
              </p>
            </div>

            <div class="bg-[#161b22] border border-[#2d2d30] p-4 rounded-xl space-y-2">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span
                  class="w-5 h-5 rounded-full bg-blue-500/20 text-blue-400 flex items-center justify-center text-xs font-medium"
                  >2</span
                >
                Zero-Latency WebAssembly Engine
              </span>
              <p class="text-base text-neutral-300 leading-relaxed font-normal">
                Powered by official PostgreSQL 13 parser binaries compiled to WebAssembly (<code
                  class="text-blue-400 font-medium"
                  >pg-query-emscripten</code
                >). Parses thousands of lines of complex DDL directly in your browser with zero
                server round-trips.
              </p>
            </div>

            <div class="bg-[#161b22] border border-[#2d2d30] p-4 rounded-xl space-y-2">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span
                  class="w-5 h-5 rounded-full bg-blue-500/20 text-blue-400 flex items-center justify-center text-xs font-medium"
                  >3</span
                >
                Hierarchical Auto-Layout
              </span>
              <p class="text-base text-neutral-300 leading-relaxed font-normal">
                Integrated with Eclipse Layout Kernel (ELK). Press
                <kbd
                  class="px-1.5 py-0.5 bg-[#252528] rounded border border-neutral-700 font-mono font-medium text-[10px]"
                  >⌘S</kbd
                >
                to recalculate optimal 2D node coordinates, eliminate overlapping edges, and cleanly
                route complex relationship paths.
              </p>
            </div>

            <div class="bg-[#161b22] border border-[#2d2d30] p-4 rounded-xl space-y-2">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span
                  class="w-5 h-5 rounded-full bg-blue-500/20 text-blue-400 flex items-center justify-center text-xs font-medium"
                  >4</span
                >
                Cross-Dialect Freedom
              </span>
              <p class="text-base text-neutral-300 leading-relaxed font-normal">
                Drop in MySQL, MariaDB, phpMyAdmin dumps, Prisma schemas, DBML files, Drizzle ORM,
                or TypeORM entities. SchemaCraft normalizes them into unified, interconnected
                relational models.
              </p>
            </div>
          </div>

          <div class="pt-4 flex justify-end">
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-blue-400 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('smart-ingestion')"
            >
              <span>Next: Smart Ingestion & Queue</span>
              <span>→</span>
            </button>
          </div>
        </section>

        <!-- 2. Smart Ingestion & Queue Section -->
        <section id="smart-ingestion" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono font-medium text-blue-400 mb-1">
              <span>02 / 09</span>
              <span>•</span>
              <span>Ingestion Pipeline</span>
            </div>
            <h2 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>⚡ Smart Ingestion & Queue Pipeline</span>
            </h2>
            <p class="text-base text-neutral-300 mt-2 leading-relaxed font-normal">
              SchemaCraft includes a multi-layered upload guard and queue pipeline engineered to
              safeguard browser memory, maintain silky 60fps canvas performance, and provide
              transparent progress feedback.
            </p>
          </div>

          <div class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-3.5">
              <div class="p-4 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-2">
                <div class="flex items-center gap-2 font-bold text-white text-sm">
                  <tools-icon
                    dir="editor"
                    icon="alert"
                    width="16"
                    height="16"
                    svg-class="text-rose-400"
                  />
                  <span>1MB Per-File Guard</span>
                </div>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  Strictly prevents browser tab freezing. Any uploaded schema exceeding 1MB triggers
                  an instant guard modal suggesting that you split queries or export structural DDL
                  without data rows.
                </p>
              </div>

              <div class="p-4 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-2">
                <div class="flex items-center gap-2 font-bold text-white text-sm">
                  <tools-icon
                    dir="editor"
                    icon="files"
                    width="16"
                    height="16"
                    svg-class="text-indigo-400"
                  />
                  <span>3-File Batch Limiter</span>
                </div>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  File pickers and drag-and-drop operations accept up to 3 files simultaneously.
                  Selecting more than 3 files triggers a polite batch warning so ingestion remains
                  fast and predictable.
                </p>
              </div>

              <div class="p-4 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-2">
                <div class="flex items-center gap-2 font-bold text-white text-sm">
                  <tools-icon
                    dir="editor"
                    icon="upload"
                    width="16"
                    height="16"
                    svg-class="text-sky-400"
                  />
                  <span>Viewport Drag-and-Drop</span>
                </div>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  Drag SQL or schema files directly onto the browser window. A frosted glass overlay
                  guides your drop and routes files straight into the validation pipeline.
                </p>
              </div>
            </div>

            <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-3">
              <h3 class="font-bold text-white text-sm">Sequential Queue Processing Stages</h3>
              <p class="text-base text-neutral-300 leading-relaxed font-normal">
                When a batch is uploaded, SchemaCraft processes files sequentially through distinct
                stages with real-time feedback:
              </p>
              <div
                class="grid grid-cols-1 sm:grid-cols-4 gap-2.5 font-mono text-[11px] font-medium"
              >
                <div class="p-2.5 rounded-lg bg-neutral-900/60 border border-neutral-800">
                  <span class="text-blue-400 font-bold block mb-1">01 / Uploading</span>
                  <span class="text-neutral-300 font-medium"
                    >Reads file text asynchronously into memory.</span
                  >
                </div>
                <div class="p-2.5 rounded-lg bg-neutral-900/60 border border-neutral-800">
                  <span class="text-indigo-400 font-bold block mb-1">02 / Reading</span>
                  <span class="text-neutral-300 font-medium"
                    >Inspects SQL statements and structure.</span
                  >
                </div>
                <div class="p-2.5 rounded-lg bg-neutral-900/60 border border-neutral-800">
                  <span class="text-amber-400 font-bold block mb-1">03 / Analyzing</span>
                  <span class="text-neutral-300 font-medium"
                    >Detects syntax markers, keywords, and dialect.</span
                  >
                </div>
                <div class="p-2.5 rounded-lg bg-neutral-900/60 border border-neutral-800">
                  <span class="text-emerald-400 font-bold block mb-1">04 / Ready</span>
                  <span class="text-neutral-300 font-medium"
                    >Populates editor tabs and renders the ERD.</span
                  >
                </div>
              </div>
            </div>
          </div>

          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-neutral-300 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('getting-started')"
            >
              <span>← Previous: Getting Started</span>
            </button>
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-blue-400 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('dialect-engine')"
            >
              <span>Next: MySQL Dialect Engine</span>
              <span>→</span>
            </button>
          </div>
        </section>

        <!-- 3. Universal SQL Dialect Engine Section -->
        <section id="dialect-engine" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono font-medium text-blue-400 mb-1">
              <span>03 / 09</span>
              <span>•</span>
              <span>Dialect Engine</span>
            </div>
            <h2 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>🔄 Universal MySQL / MariaDB Dialect Engine</span>
            </h2>
            <p class="text-base text-neutral-300 mt-2 leading-relaxed font-normal">
              Real-world database dumps from MySQL, MariaDB, and phpMyAdmin are incompatible with
              strict PostgreSQL parsers. SchemaCraft provides an automated, client-side AST
              transformation engine that bridges the gap seamlessly.
            </p>
          </div>

          <div class="space-y-4">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-2">
                <span class="font-bold text-amber-400 text-sm flex items-center gap-1.5">
                  <tools-icon
                    dir="editor"
                    icon="sparkles"
                    width="14"
                    height="14"
                    svg-class="text-amber-400"
                  />
                  <span>Dialect Detection Heuristics</span>
                </span>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  Scans files in microseconds for characteristic MySQL signatures: backtick
                  identifiers (<code class="text-neutral-200 font-medium">`table`</code>),
                  <code class="text-neutral-200 font-medium">USE database;</code>, table options
                  (<code class="text-neutral-200 font-medium">ENGINE=InnoDB</code>,
                  <code class="text-neutral-200 font-medium">DEFAULT CHARSET</code>,
                  <code class="text-neutral-200 font-medium">COLLATE</code>),
                  <code class="text-neutral-200 font-medium">AUTO_INCREMENT</code>, display widths
                  (<code class="text-neutral-200 font-medium">int(11)</code>), and header comments
                  (<code class="text-neutral-200 font-medium">/*!40101 ... */</code>).
                </p>
              </div>

              <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-2">
                <span class="font-bold text-sky-400 text-sm flex items-center gap-1.5">
                  <tools-icon
                    dir="editor"
                    icon="check"
                    width="14"
                    height="14"
                    svg-class="text-sky-400"
                  />
                  <span>Client-Side DDL Transformation</span>
                </span>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  Converts MySQL DDL into standard PostgreSQL DDL entirely within your browser.
                  Strips operational directives, eliminates non-DDL INSERT queries, maps
                  incompatible types to Postgres equivalents, and converts AUTO_INCREMENT to SERIAL
                  identities.
                </p>
              </div>
            </div>

            <!-- Transformation Mapping Table -->
            <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl overflow-hidden shadow-lg">
              <div
                class="px-4 py-2.5 bg-[#12161f] border-b border-[#2d2d30] font-mono font-semibold text-neutral-200 flex items-center justify-between text-xs"
              >
                <span>MySQL to PostgreSQL Transformation Rules</span>
                <span class="text-[10px] font-medium text-blue-400 font-mono">AST Mapping</span>
              </div>
              <table class="w-full text-left font-mono text-[11px] font-medium">
                <thead class="bg-[#161b22] border-b border-[#2d2d30] text-neutral-400 font-medium">
                  <tr>
                    <th class="px-4 py-2 font-medium">MySQL Construct</th>
                    <th class="px-4 py-2 font-medium">PostgreSQL Equivalent</th>
                    <th class="px-4 py-2 font-medium">Transformation Rationale</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-[#2d2d30] text-neutral-300 font-medium">
                  <tr class="hover:bg-white/5">
                    <td class="px-4 py-2 text-amber-300 font-medium">`column_name`</td>
                    <td class="px-4 py-2 text-emerald-300 font-medium">
                      "column_name" / column_name
                    </td>
                    <td class="px-4 py-2 text-neutral-300 font-sans font-medium">
                      Preserves casing with ANSI double quotes for mixed-case names.
                    </td>
                  </tr>
                  <tr class="hover:bg-white/5">
                    <td class="px-4 py-2 text-amber-300 font-medium">int(11) AUTO_INCREMENT</td>
                    <td class="px-4 py-2 text-emerald-300 font-medium">SERIAL PRIMARY KEY</td>
                    <td class="px-4 py-2 text-neutral-300 font-sans font-medium">
                      Upgrades auto-incrementing integers to native PostgreSQL sequences.
                    </td>
                  </tr>
                  <tr class="hover:bg-white/5">
                    <td class="px-4 py-2 text-amber-300 font-medium">bigint(20) AUTO_INCREMENT</td>
                    <td class="px-4 py-2 text-emerald-300 font-medium">BIGSERIAL PRIMARY KEY</td>
                    <td class="px-4 py-2 text-neutral-300 font-sans font-medium">
                      Maps 64-bit auto-incrementing columns to BIGSERIAL.
                    </td>
                  </tr>
                  <tr class="hover:bg-white/5">
                    <td class="px-4 py-2 text-amber-300 font-medium">longtext / mediumtext</td>
                    <td class="px-4 py-2 text-emerald-300 font-medium">TEXT</td>
                    <td class="px-4 py-2 text-neutral-300 font-sans font-medium">
                      PostgreSQL TEXT has arbitrary length; length-suffixed text is normalized.
                    </td>
                  </tr>
                  <tr class="hover:bg-white/5">
                    <td class="px-4 py-2 text-amber-300 font-medium">datetime</td>
                    <td class="px-4 py-2 text-emerald-300 font-medium">TIMESTAMPTZ</td>
                    <td class="px-4 py-2 text-neutral-300 font-sans font-medium">
                      Standardizes date/time with timezone awareness.
                    </td>
                  </tr>
                  <tr class="hover:bg-white/5">
                    <td class="px-4 py-2 text-amber-300 font-medium">
                      ENGINE=InnoDB DEFAULT CHARSET...
                    </td>
                    <td class="px-4 py-2 text-rose-300 font-medium">[STRIPPED]</td>
                    <td class="px-4 py-2 text-neutral-300 font-sans font-medium">
                      Storage engines and collations are stripped clean to prevent syntax errors.
                    </td>
                  </tr>
                  <tr class="hover:bg-white/5">
                    <td class="px-4 py-2 text-amber-300 font-medium">
                      INSERT INTO `table` VALUES ...
                    </td>
                    <td class="px-4 py-2 text-rose-300 font-medium">[STRIPPED]</td>
                    <td class="px-4 py-2 text-neutral-300 font-sans font-medium">
                      Data dumps are omitted to focus purely on schema architecture.
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Casual User Prompt -->
            <div class="bg-neutral-900 border border-neutral-800 rounded-xl p-4 space-y-2">
              <span class="font-bold text-white text-sm block"
                >Casual, Interactive Confirmation</span
              >
              <p class="text-base text-neutral-300 leading-relaxed font-normal">
                When MySQL syntax is detected, SchemaCraft pauses the queue on that specific file
                and asks:
                <em class="text-white font-medium"
                  >"Convert MySQL to PostgreSQL? This file has MySQL-specific syntax (like backticks
                  or types) that PostgreSQL won't parse directly. We can convert it for you right
                  now so your diagram displays without errors."</em
                >
                You can choose to <strong>Convert to PostgreSQL</strong> or
                <strong>Skip file</strong> to keep your workflow in your control.
              </p>
            </div>
          </div>

          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-neutral-300 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('smart-ingestion')"
            >
              <span>← Previous: Smart Ingestion</span>
            </button>
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-blue-400 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('language-ecosystem')"
            >
              <span>Next: Supported Languages & ORMs</span>
              <span>→</span>
            </button>
          </div>
        </section>

        <!-- 4. Language Ecosystem Section -->
        <section id="language-ecosystem" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono font-medium text-blue-400 mb-1">
              <span>04 / 09</span>
              <span>•</span>
              <span>Language Ecosystem</span>
            </div>
            <h2 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>🌐 Fully Supported Languages & ORMs</span>
            </h2>
            <p class="text-base text-neutral-300 mt-2 leading-relaxed font-normal">
              SchemaCraft supports full multi-language schema authoring. Switch the editor language
              or upload schema files from any major ORM or database definition format.
            </p>
          </div>

          <div class="space-y-6">
            <!-- Language Cards Grid -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- PostgreSQL -->
              <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-3">
                <div class="flex items-center justify-between">
                  <span class="font-bold text-sm text-white flex items-center gap-2">
                    <span class="text-blue-400">🐘</span>
                    <span>PostgreSQL DDL</span>
                  </span>
                  <span
                    class="px-2 py-0.5 rounded text-[10px] font-mono font-medium bg-blue-500/20 text-blue-400 border border-blue-500/30"
                    >Native WASM</span
                  >
                </div>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  Full official PostgreSQL DDL syntax. Primary keys, foreign keys (<code
                    class="text-neutral-200 font-medium"
                    >REFERENCES ... ON DELETE/UPDATE</code
                  >), composite constraints, table checks, unique constraints, and schema-qualified
                  tables.
                </p>
                <div
                  class="bg-[#0d1117] p-2.5 rounded-lg font-mono text-[11px] font-medium text-neutral-300 border border-[#2d2d30]"
                >
                  <code
                    >CREATE TABLE users (<br />
                    &nbsp;&nbsp;id SERIAL PRIMARY KEY,<br />
                    &nbsp;&nbsp;email VARCHAR(255) UNIQUE NOT NULL<br />
                    );</code
                  >
                </div>
              </div>

              <!-- MySQL / MariaDB -->
              <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-3">
                <div class="flex items-center justify-between">
                  <span class="font-bold text-sm text-white flex items-center gap-2">
                    <span class="text-amber-400">🐬</span>
                    <span>MySQL / MariaDB</span>
                  </span>
                  <span
                    class="px-2 py-0.5 rounded text-[10px] font-mono font-medium bg-amber-500/20 text-amber-400 border border-amber-500/30"
                    >Auto-Transformed</span
                  >
                </div>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  Standard SQL dumps containing backticks, engine declarations, and auto-increments.
                  Automatically detected and compiled into clean PostgreSQL DDL.
                </p>
                <div
                  class="bg-[#0d1117] p-2.5 rounded-lg font-mono text-[11px] font-medium text-neutral-300 border border-[#2d2d30]"
                >
                  <code
                    >CREATE TABLE `users` (<br />
                    &nbsp;&nbsp;`id` int(11) NOT NULL AUTO_INCREMENT,<br />
                    &nbsp;&nbsp;PRIMARY KEY (`id`)<br />
                    ) ENGINE=InnoDB;</code
                  >
                </div>
              </div>

              <!-- DBML -->
              <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-3">
                <div class="flex items-center justify-between">
                  <span class="font-bold text-sm text-white flex items-center gap-2">
                    <span class="text-emerald-400">📄</span>
                    <span>Database Markup Language (DBML)</span>
                  </span>
                  <span
                    class="px-2 py-0.5 rounded text-[10px] font-mono font-medium bg-emerald-500/20 text-emerald-400 border border-emerald-500/30"
                    >First-Class</span
                  >
                </div>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  Clean, human-readable schema definitions. Table declarations, column types, inline
                  settings (<code class="text-neutral-200 font-medium">[pk, not null, unique]</code
                  >), table notes, and explicit references (<code
                    class="text-neutral-200 font-medium"
                    >Ref: orders.user_id > users.id</code
                  >).
                </p>
                <div
                  class="bg-[#0d1117] p-2.5 rounded-lg font-mono text-[11px] font-medium text-neutral-300 border border-[#2d2d30]"
                >
                  <code
                    >Table users {<br />
                    &nbsp;&nbsp;id integer [pk, increment]<br />
                    &nbsp;&nbsp;name varchar<br />
                    }</code
                  >
                </div>
              </div>

              <!-- Prisma Schema -->
              <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-3">
                <div class="flex items-center justify-between">
                  <span class="font-bold text-sm text-white flex items-center gap-2">
                    <span class="text-indigo-400">💎</span>
                    <span>Prisma ORM Schema</span>
                  </span>
                  <span
                    class="px-2 py-0.5 rounded text-[10px] font-mono font-medium bg-indigo-500/20 text-indigo-400 border border-indigo-500/30"
                    >First-Class</span
                  >
                </div>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  Declarative Prisma schema definitions. Supports
                  <code class="text-neutral-200 font-medium">model</code> blocks,
                  <code class="text-neutral-200 font-medium">@id</code>,
                  <code class="text-neutral-200 font-medium">@default()</code>,
                  <code class="text-neutral-200 font-medium">@relation()</code>, enums, compound
                  IDs, and multi-field indexes.
                </p>
                <div
                  class="bg-[#0d1117] p-2.5 rounded-lg font-mono text-[11px] font-medium text-neutral-300 border border-[#2d2d30]"
                >
                  <code
                    >model User {<br />
                    &nbsp;&nbsp;id Int @id @default(autoincrement())<br />
                    &nbsp;&nbsp;posts Post[]<br />
                    }</code
                  >
                </div>
              </div>

              <!-- Drizzle ORM -->
              <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-3">
                <div class="flex items-center justify-between">
                  <span class="font-bold text-sm text-white flex items-center gap-2">
                    <span class="text-yellow-400">🌧️</span>
                    <span>Drizzle ORM</span>
                  </span>
                  <span
                    class="px-2 py-0.5 rounded text-[10px] font-mono font-medium bg-yellow-500/20 text-yellow-400 border border-yellow-500/30"
                    >TypeScript Native</span
                  >
                </div>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  TypeScript schema declarations using
                  <code class="text-neutral-200 font-medium">pgTable</code>,
                  <code class="text-neutral-200 font-medium">serial</code>,
                  <code class="text-neutral-200 font-medium">text</code>,
                  <code class="text-neutral-200 font-medium">integer</code>,
                  <code class="text-neutral-200 font-medium">.references()</code>, and Drizzle
                  relations helpers.
                </p>
                <div
                  class="bg-[#0d1117] p-2.5 rounded-lg font-mono text-[11px] font-medium text-neutral-300 border border-[#2d2d30]"
                >
                  <code
                    >export const users = pgTable('users', {<br />
                    &nbsp;&nbsp;id: serial('id').primaryKey(),<br />
                    &nbsp;&nbsp;name: text('name').notNull()<br />
                    });</code
                  >
                </div>
              </div>

              <!-- TypeORM -->
              <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-3">
                <div class="flex items-center justify-between">
                  <span class="font-bold text-sm text-white flex items-center gap-2">
                    <span class="text-rose-400">🏛️</span>
                    <span>TypeORM Entities</span>
                  </span>
                  <span
                    class="px-2 py-0.5 rounded text-[10px] font-mono font-medium bg-rose-500/20 text-rose-400 border border-rose-500/30"
                    >Decorator Based</span
                  >
                </div>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  TypeScript classes with
                  <code class="text-neutral-200 font-medium">@Entity()</code>,
                  <code class="text-neutral-200 font-medium">@PrimaryGeneratedColumn()</code>,
                  <code class="text-neutral-200 font-medium">@Column()</code>,
                  <code class="text-neutral-200 font-medium">@OneToMany()</code>, and
                  <code class="text-neutral-200 font-medium">@ManyToOne()</code> decorators.
                </p>
                <div
                  class="bg-[#0d1117] p-2.5 rounded-lg font-mono text-[11px] font-medium text-neutral-300 border border-[#2d2d30]"
                >
                  <code
                    >@Entity()<br />
                    export class User {<br />
                    &nbsp;&nbsp;@PrimaryGeneratedColumn() id: number;<br />
                    &nbsp;&nbsp;@Column() email: string;<br />
                    }</code
                  >
                </div>
              </div>
            </div>
          </div>

          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-neutral-300 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('dialect-engine')"
            >
              <span>← Previous: MySQL Dialect Engine</span>
            </button>
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-blue-400 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('workspace-collection')"
            >
              <span>Next: Multi-Tab & Collection.zip</span>
              <span>→</span>
            </button>
          </div>
        </section>

        <!-- 5. Multi-Tab Workspace & Collection.zip Section -->
        <section id="workspace-collection" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono font-medium text-blue-400 mb-1">
              <span>05 / 09</span>
              <span>•</span>
              <span>Workspace Management</span>
            </div>
            <h2 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>🗂️ Multi-Tab Workspace & Collection Archive</span>
            </h2>
            <p class="text-base text-neutral-300 mt-2 leading-relaxed font-normal">
              Manage multiple database models side-by-side with complete state isolation and
              one-click ZIP packaging.
            </p>
          </div>

          <div class="space-y-4">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-2">
                <span class="font-bold text-amber-400 text-sm flex items-center gap-1.5">
                  <tools-icon
                    dir="editor"
                    icon="tabs"
                    width="14"
                    height="14"
                    svg-class="text-amber-400"
                  />
                  <span>10-Tab Workspace Ceiling</span>
                </span>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  SchemaCraft supports up to 10 active tabs simultaneously. Each tab retains its own
                  independent Monaco undo/redo history, AST parsed tables, active dialect, and
                  canvas zoom/pan coordinates. A live tab counter badge displays capacity in
                  real-time.
                </p>
              </div>

              <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-2">
                <span class="font-bold text-emerald-400 text-sm flex items-center gap-1.5">
                  <tools-icon
                    dir="editor"
                    icon="download"
                    width="14"
                    height="14"
                    svg-class="text-emerald-400"
                  />
                  <span>One-Click Collection.zip Export</span>
                </span>
                <p class="text-base text-neutral-300 leading-relaxed font-normal">
                  Instead of downloading files one by one, click <strong>Collection.zip</strong> in
                  the header or export menu. Powered by the ultra-fast
                  <code class="text-neutral-200 font-medium">fflate</code> library, SchemaCraft
                  packages all your open tabs into a single compressed archive for instant team
                  sharing or backup.
                </p>
              </div>
            </div>

            <div class="p-4 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-2">
              <span class="font-bold text-white text-sm block">Tab Dirty State Tracking</span>
              <p class="text-base text-neutral-300 leading-relaxed font-normal">
                Tabs display an asterisk (<code class="text-amber-400 font-medium">*</code>)
                indicator when unsaved modifications exist. Pressing
                <kbd
                  class="px-1.5 py-0.5 bg-[#252528] rounded border border-neutral-700 font-mono font-medium text-[10px]"
                  >⌘S</kbd
                >
                saves the current tab, updates the visual diagram, and clears the dirty marker.
              </p>
            </div>
          </div>

          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-neutral-300 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('language-ecosystem')"
            >
              <span>← Previous: Language Ecosystem</span>
            </button>
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-blue-400 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('export-suite')"
            >
              <span>Next: Export Suite & Transpiler</span>
              <span>→</span>
            </button>
          </div>
        </section>

        <!-- 6. Export Suite Section -->
        <section id="export-suite" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono font-medium text-blue-400 mb-1">
              <span>06 / 09</span>
              <span>•</span>
              <span>Export Suite</span>
            </div>
            <h2 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>📦 Production Export Suite & Transpiler</span>
            </h2>
            <p class="text-base text-neutral-300 mt-2 leading-relaxed font-normal">
              Export diagrams for documentation, pull requests, and presentations, or transpile
              schemas into production codebases.
            </p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-2">
              <span class="font-bold text-white block text-sm">Visual Diagram Formats</span>
              <ul class="space-y-2 text-neutral-300 text-xs font-medium">
                <li class="flex items-start gap-2">
                  <span class="w-1.5 h-1.5 rounded-full bg-blue-400 mt-1.5 shrink-0" />
                  <span
                    ><strong>High-Resolution PNG (2x):</strong> Crisp pixel rendering ideal for
                    design reviews and Slack updates.</span
                  >
                </li>
                <li class="flex items-start gap-2">
                  <span class="w-1.5 h-1.5 rounded-full bg-indigo-400 mt-1.5 shrink-0" />
                  <span
                    ><strong>Scalable Vector Graphics (SVG):</strong> Infinite resolution for
                    architecture documentation and wiki pages.</span
                  >
                </li>
                <li class="flex items-start gap-2">
                  <span class="w-1.5 h-1.5 rounded-full bg-purple-400 mt-1.5 shrink-0" />
                  <span
                    ><strong>JPEG Format:</strong> Lightweight, compressed visual snapshots.</span
                  >
                </li>
              </ul>
            </div>

            <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl p-4 space-y-2">
              <span class="font-bold text-white block text-sm">Code Transpilation</span>
              <ul class="space-y-2 text-neutral-300 text-xs font-medium">
                <li class="flex items-start gap-2">
                  <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 mt-1.5 shrink-0" />
                  <span
                    ><strong>TypeScript Interfaces:</strong> Generates type-safe model interfaces
                    directly from relational tables.</span
                  >
                </li>
                <li class="flex items-start gap-2">
                  <span class="w-1.5 h-1.5 rounded-full bg-amber-400 mt-1.5 shrink-0" />
                  <span
                    ><strong>Prisma Schema:</strong> Generates Prisma models with explicit
                    relations.</span
                  >
                </li>
                <li class="flex items-start gap-2">
                  <span class="w-1.5 h-1.5 rounded-full bg-sky-400 mt-1.5 shrink-0" />
                  <span
                    ><strong>DBML & JSON:</strong> Interoperable formats for external diagram and
                    pipeline tooling.</span
                  >
                </li>
              </ul>
            </div>
          </div>

          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-neutral-300 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('workspace-collection')"
            >
              <span>← Previous: Multi-Tab & Collection.zip</span>
            </button>
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-blue-400 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('platform-potentials')"
            >
              <span>Next: Potentials & Roadmap</span>
              <span>→</span>
            </button>
          </div>
        </section>

        <!-- 7. Platform Potentials & Roadmap Section -->
        <section id="platform-potentials" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono font-medium text-blue-400 mb-1">
              <span>07 / 09</span>
              <span>•</span>
              <span>Vision & Roadmap</span>
            </div>
            <h2 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>🔮 Platform Potentials & Future Roadmap</span>
            </h2>
            <p class="text-base text-neutral-300 mt-2 leading-relaxed font-normal">
              SchemaCraft is built with an extensible, modular architecture. Discover upcoming
              capabilities engineered to make SchemaCraft the central command center for modern
              database engineering.
            </p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="p-4 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-2.5">
              <span class="font-bold text-sm text-blue-400 flex items-center gap-2">
                <span>🤝</span>
                <span>Live Multiplayer Collaboration</span>
              </span>
              <p class="text-base text-neutral-300 leading-relaxed font-normal">
                Real-time CRDT-backed diagram co-editing (via PartyKit / WebSockets). Multiple
                engineers can model schemas simultaneously, view live cursor movements across the
                canvas, and resolve design decisions collaboratively.
              </p>
            </div>

            <div class="p-4 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-2.5">
              <span class="font-bold text-sm text-emerald-400 flex items-center gap-2">
                <span>⚡</span>
                <span>Live Database Introspection</span>
              </span>
              <p class="text-base text-neutral-300 leading-relaxed font-normal">
                Direct read-only SSL connection pooling to live Postgres databases (Supabase, Neon,
                AWS RDS, Neon, Tembo). Inspect live schemas, view table row count estimates, and
                visualize production topologies with zero manual export.
              </p>
            </div>

            <div class="p-4 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-2.5">
              <span class="font-bold text-sm text-amber-400 flex items-center gap-2">
                <span>🔍</span>
                <span>Visual Schema Migration Diffing</span>
              </span>
              <p class="text-base text-neutral-300 leading-relaxed font-normal">
                Compare two tabs side-by-side (e.g. Staging vs Production). Highlights added,
                altered, or dropped columns in color-coded visual diffs and automatically generates
                safe <code class="text-neutral-200 font-medium">ALTER TABLE</code> migration
                scripts.
              </p>
            </div>

            <div class="p-4 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-2.5">
              <span class="font-bold text-sm text-purple-400 flex items-center gap-2">
                <span>🧠</span>
                <span>AI Schema Architect & Index Advisor</span>
              </span>
              <p class="text-base text-neutral-300 leading-relaxed font-normal">
                Describe business logic in natural language (*"Build a multi-tenant billing system
                with subscriptions, invoices, and payment intents"*) and have SchemaCraft generate
                normalized, index-optimized schemas ready for production.
              </p>
            </div>
          </div>

          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-neutral-300 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('export-suite')"
            >
              <span>← Previous: Export Suite</span>
            </button>
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-blue-400 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('keyboard-shortcuts')"
            >
              <span>Next: Keyboard Shortcuts</span>
              <span>→</span>
            </button>
          </div>
        </section>

        <!-- 8. Keyboard Shortcuts Section -->
        <section id="keyboard-shortcuts" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono font-medium text-blue-400 mb-1">
              <span>08 / 09</span>
              <span>•</span>
              <span>Productivity</span>
            </div>
            <h2 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>⌨️ Keyboard Shortcuts & Hotkeys</span>
            </h2>
            <p class="text-base text-neutral-300 mt-2 leading-relaxed font-normal">
              Boost your authoring and modeling speed with built-in editor shortcuts.
            </p>
          </div>

          <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl overflow-hidden shadow-lg">
            <table class="w-full text-xs font-medium text-left">
              <thead
                class="bg-[#12161f] border-b border-[#2d2d30] text-neutral-400 uppercase font-mono text-[10px] font-medium"
              >
                <tr>
                  <th class="px-4 py-3">Action</th>
                  <th class="px-4 py-3">Mac Shortcut</th>
                  <th class="px-4 py-3">Windows / Linux</th>
                  <th class="px-4 py-3">Description</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-[#2d2d30] font-mono text-neutral-300 font-medium">
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">Save & Re-layout</td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >⌘S</kbd
                    >
                  </td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >Ctrl+S</kbd
                    >
                  </td>
                  <td class="px-4 py-3 font-sans text-neutral-300 font-medium">
                    Saves current tab and recalculates ELK graph layout
                  </td>
                </tr>
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">New Tab</td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >⌘N / +</kbd
                    >
                  </td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >Ctrl+N / +</kbd
                    >
                  </td>
                  <td class="px-4 py-3 font-sans text-neutral-300 font-medium">
                    Creates an isolated schema tab (up to 10 tabs)
                  </td>
                </tr>
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">Zoom In / Out</td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >Scroll / Pinch</kbd
                    >
                  </td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >Ctrl + Scroll</kbd
                    >
                  </td>
                  <td class="px-4 py-3 font-sans text-neutral-300 font-medium">
                    Smooth zoom canvas viewport
                  </td>
                </tr>
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">Pan Canvas</td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >Space + Drag</kbd
                    >
                  </td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >Space + Drag</kbd
                    >
                  </td>
                  <td class="px-4 py-3 font-sans text-neutral-300 font-medium">
                    Pan diagram workspace in all directions
                  </td>
                </tr>
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">Find & Focus Table</td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >⌘K</kbd
                    >
                  </td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >Ctrl+K</kbd
                    >
                  </td>
                  <td class="px-4 py-3 font-sans text-neutral-300 font-medium">
                    Opens table search palette and navigates canvas to selected table
                  </td>
                </tr>
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">Toggle Error Console</td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >⌘J</kbd
                    >
                  </td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >Ctrl+J</kbd
                    >
                  </td>
                  <td class="px-4 py-3 font-sans text-neutral-300 font-medium">
                    Toggles the bottom diagnostic and validation error console
                  </td>
                </tr>
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">Rename Tab</td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >Double Click</kbd
                    >
                  </td>
                  <td class="px-4 py-3">
                    <kbd
                      class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700 font-medium"
                      >Double Click</kbd
                    >
                  </td>
                  <td class="px-4 py-3 font-sans text-neutral-300 font-medium">
                    Edit schema tab title inline
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-neutral-300 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('platform-potentials')"
            >
              <span>← Previous: Potentials & Roadmap</span>
            </button>
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-blue-400 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('theme-suite')"
            >
              <span>Next: Monokai & Themes</span>
              <span>→</span>
            </button>
          </div>
        </section>

        <!-- 9. Theme Suite Section -->
        <section id="theme-suite" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono font-medium text-blue-400 mb-1">
              <span>09 / 09</span>
              <span>•</span>
              <span>Visual Customization</span>
            </div>
            <h2 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>🎨 Monokai & Theme Suite</span>
            </h2>
            <p class="text-base text-neutral-300 mt-2 leading-relaxed font-normal">
              Personalize your editing environment with curated developer palettes designed for
              sustained visual comfort.
            </p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div class="p-4 bg-[#272822] border border-[#49483e] rounded-xl space-y-2 shadow-lg">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span>Monokai Classic</span>
                <span
                  class="px-1.5 py-0.2 rounded text-[9px] font-mono font-medium bg-pink-500/20 text-pink-400 border border-pink-500/40"
                >
                  Suite
                </span>
              </span>
              <p class="text-base text-[#f8f8f2]/90 leading-relaxed font-normal">
                Iconic charcoal background with vibrant pink keywords, yellow strings, green
                identifiers, and cyan data types.
              </p>
            </div>

            <div class="p-4 bg-[#282a36] border border-[#44475a] rounded-xl space-y-2 shadow-lg">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span>Dracula Dark</span>
              </span>
              <p class="text-base text-[#f8f8f2]/90 leading-relaxed font-normal">
                Sleek purple nocturnal aesthetic with glowing cyan, green, and pink syntax
                highlights.
              </p>
            </div>
          </div>

          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-neutral-300 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
              @click="scrollTo('keyboard-shortcuts')"
            >
              <span>← Previous: Keyboard Shortcuts</span>
            </button>
            <nuxt-link
              to="/"
              class="px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white font-semibold text-xs rounded-lg transition-colors flex items-center gap-2 shadow-md"
            >
              <span>Launch Visual Editor</span>
              <span>→</span>
            </nuxt-link>
          </div>
        </section>
      </main>
    </div>
  </div>
</template>
