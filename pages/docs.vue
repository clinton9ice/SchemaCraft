<script setup lang="ts">
useHead({
  title: 'SchemaCraft Documentation - PostgreSQL DB Diagram Visual Editor',
  meta: [
    {
      name: 'description',
      content:
        'Comprehensive documentation, syntax reference, and keyboard shortcuts for SchemaCraft Database Diagram Visual Editor.',
    },
  ],
})

const activeSection = ref('getting-started')
const scrollContainerRef = ref<HTMLElement | null>(null)

const sections = [
  { id: 'getting-started', label: '🚀 Getting Started' },
  { id: 'syntax-support', label: '🐘 Postgres Syntax Support' },
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
  const sectionIds = ['getting-started', 'syntax-support', 'keyboard-shortcuts', 'theme-suite']
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
    class="h-screen w-screen bg-[#0d1117] text-neutral-200 font-sans flex flex-col overflow-y-auto overflow-x-hidden scroll-smooth select-text"
  >
    <!-- Top Navigation Header (Sticky) -->
    <header
      class="h-14 border-b border-[#2d2d30] bg-[#161b22]/95 px-6 flex items-center justify-between sticky top-0 z-40 backdrop-blur-md shrink-0 select-none"
    >
      <div class="flex items-center gap-3">
        <NuxtLink to="/" class="flex items-center gap-2.5 group">
          <div
            class="w-8 h-8 rounded-lg bg-gradient-to-tr from-blue-600 to-indigo-500 flex items-center justify-center shadow-md shadow-blue-500/20 text-white font-bold"
          >
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <ellipse cx="12" cy="5" rx="9" ry="3" />
              <path d="M3 5V19A9 3 0 0 0 21 19V5" />
              <path d="M3 12A9 3 0 0 0 21 12" />
            </svg>
          </div>
          <div class="flex flex-col">
            <span class="font-bold text-sm tracking-tight text-white group-hover:text-blue-400 transition-colors">
              SchemaCraft
            </span>
            <span class="text-[10px] text-neutral-400 font-mono">Documentation</span>
          </div>
        </NuxtLink>
      </div>

      <div class="flex items-center gap-3">
        <NuxtLink
          to="/"
          class="inline-flex items-center gap-2 px-3.5 py-1.5 bg-blue-600 hover:bg-blue-500 text-white text-xs font-semibold rounded-lg shadow-sm transition-colors cursor-pointer"
        >
          <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="m15 18-6-6 6-6" />
          </svg>
          <span>Back to Editor</span>
        </NuxtLink>
      </div>
    </header>

    <!-- Main Content Layout -->
    <div class="flex-1 max-w-7xl w-full mx-auto px-6 py-8 grid grid-cols-1 md:grid-cols-4 gap-8">
      <!-- Left Sticky Sidebar Nav (Scroll Spy) -->
      <aside class="hidden md:block col-span-1">
        <div class="sticky top-20 space-y-1.5 text-xs font-medium bg-[#161b22]/50 border border-[#2d2d30] p-2.5 rounded-xl shadow-lg">
          <span class="text-[10px] uppercase font-mono tracking-wider text-neutral-400 block px-3 py-1 mb-1 border-b border-[#2d2d30]">
            Table of Contents
          </span>
          <button
            v-for="s in sections"
            :key="s.id"
            type="button"
            @click="scrollTo(s.id)"
            class="w-full text-left px-3 py-2 rounded-lg transition-all duration-150 flex items-center justify-between cursor-pointer"
            :class="[
              activeSection === s.id
                ? 'bg-blue-600/20 text-blue-400 font-semibold border-l-2 border-blue-500'
                : 'text-neutral-400 hover:text-neutral-200 hover:bg-white/5 border-l-2 border-transparent',
            ]"
          >
            <span>{{ s.label }}</span>
            <span v-if="activeSection === s.id" class="w-1.5 h-1.5 rounded-full bg-blue-400 animate-pulse" />
          </button>
        </div>
      </aside>

      <!-- Main Docs Articles Area -->
      <main class="col-span-1 md:col-span-3 space-y-16 pb-32">
        <!-- 1. Getting Started Section -->
        <section id="getting-started" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono text-blue-400 mb-1">
              <span>01 / 04</span>
              <span>•</span>
              <span>Overview</span>
            </div>
            <h1 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>🚀 Getting Started</span>
            </h1>
            <p class="text-sm text-neutral-400 mt-1.5 leading-relaxed">
              SchemaCraft is a high-performance visual database modeling IDE powered by Nitro and Vue Flow. It allows you to write PostgreSQL DDL code and immediately view the corresponding interactive Entity-Relationship diagram.
            </p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div class="bg-[#161b22] border border-[#2d2d30] p-4 rounded-xl space-y-2">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span class="w-5 h-5 rounded-full bg-blue-500/20 text-blue-400 flex items-center justify-center text-xs">1</span>
                Split View Editor
              </span>
              <p class="text-xs text-neutral-300 leading-relaxed">
                Write standard DDL SQL on the left in Monaco Editor. The visual ER diagram dynamically updates in real-time on the right canvas.
              </p>
            </div>

            <div class="bg-[#161b22] border border-[#2d2d30] p-4 rounded-xl space-y-2">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span class="w-5 h-5 rounded-full bg-blue-500/20 text-blue-400 flex items-center justify-center text-xs">2</span>
                Multi-Tab Sessions
              </span>
              <p class="text-xs text-neutral-300 leading-relaxed">
                Open multiple SQL schemas simultaneously with full state isolation. Each tab maintains its own independent SQL code, tables, relations, and diagram layout.
              </p>
            </div>

            <div class="bg-[#161b22] border border-[#2d2d30] p-4 rounded-xl space-y-2">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span class="w-5 h-5 rounded-full bg-blue-500/20 text-blue-400 flex items-center justify-center text-xs">3</span>
                Auto-Layout with ELK
              </span>
              <p class="text-xs text-neutral-300 leading-relaxed">
                Whenever you save (<kbd class="px-1.5 py-0.5 bg-[#252528] rounded border border-neutral-700 font-mono text-[10px]">⌘S</kbd>) or click <strong>Auto-Layout</strong>, Eclipse Layout Kernel calculates optimal 2D coordinates to minimize edge crossings.
              </p>
            </div>

            <div class="bg-[#161b22] border border-[#2d2d30] p-4 rounded-xl space-y-2">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span class="w-5 h-5 rounded-full bg-blue-500/20 text-blue-400 flex items-center justify-center text-xs">4</span>
                Image & Code Export
              </span>
              <p class="text-xs text-neutral-300 leading-relaxed">
                Export diagrams to 2x High-Res PNG, vector SVG, or JPEG, or transpile schemas into TypeScript types, Prisma, DBML, and JSON.
              </p>
            </div>
          </div>

          <!-- Next Section Button -->
          <div class="pt-4 flex justify-end">
            <button
              type="button"
              @click="scrollTo('syntax-support')"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-blue-400 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
            >
              <span>Next: Postgres Syntax Support</span>
              <span>→</span>
            </button>
          </div>
        </section>

        <!-- 2. Postgres Syntax Support Section -->
        <section id="syntax-support" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono text-blue-400 mb-1">
              <span>02 / 04</span>
              <span>•</span>
              <span>Language Reference</span>
            </div>
            <h2 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>🐘 Postgres Syntax Support</span>
            </h2>
            <p class="text-sm text-neutral-400 mt-1.5 leading-relaxed">
              SchemaCraft parses full PostgreSQL DDL syntax directly via our Nitro AST compiler.
            </p>
          </div>

          <div class="space-y-4 text-xs">
            <!-- Table Creation Example -->
            <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl overflow-hidden shadow-lg">
              <div class="px-4 py-2 bg-[#12161f] border-b border-[#2d2d30] font-mono font-semibold text-neutral-300 flex items-center justify-between">
                <span>PostgreSQL Schema Example</span>
                <span class="text-[10px] text-blue-400 font-mono">SQL DDL</span>
              </div>
              <pre class="p-4 bg-[#0d1117] text-neutral-200 font-mono overflow-x-auto leading-relaxed"><code>CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'editor', 'member')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount > 0),
    status VARCHAR(30) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Documentation Comments (Displayed in diagram hover cards)
COMMENT ON COLUMN users.role IS 'User permission access level in organization';
COMMENT ON COLUMN orders.total_amount IS 'Total final order value in USD';</code></pre>
            </div>

            <!-- Features Breakdown List -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
              <div class="p-3.5 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-1">
                <span class="font-bold text-sky-400 block text-xs">Primary & Unique Keys</span>
                <span class="text-neutral-400 leading-relaxed block">Supports inline `PRIMARY KEY`, composite `PRIMARY KEY (a, b)`, and `UNIQUE` constraints with gold/purple badges.</span>
              </div>
              <div class="p-3.5 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-1">
                <span class="font-bold text-sky-400 block text-xs">Foreign Key Relations</span>
                <span class="text-neutral-400 leading-relaxed block">Auto-detects column-level `REFERENCES target(col)` and table-level `FOREIGN KEY (a) REFERENCES target(b)` to draw smooth step lines.</span>
              </div>
              <div class="p-3.5 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-1">
                <span class="font-bold text-amber-400 block text-xs">CHECK Conditions Translation</span>
                <span class="text-neutral-400 leading-relaxed block">Translates complex SQL checks (e.g. `price > 0`) into human-readable sentences (*"price must be greater than 0"*).</span>
              </div>
              <div class="p-3.5 bg-[#161b22] border border-[#2d2d30] rounded-xl space-y-1">
                <span class="font-bold text-emerald-400 block text-xs">SQL Comments & Tooltips</span>
                <span class="text-neutral-400 leading-relaxed block">Parses `COMMENT ON COLUMN / TABLE` and displays documentation notes in zero-clipping hover popovers.</span>
              </div>
            </div>
          </div>

          <!-- Section Navigation Buttons -->
          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              @click="scrollTo('getting-started')"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-neutral-300 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
            >
              <span>← Previous: Getting Started</span>
            </button>
            <button
              type="button"
              @click="scrollTo('keyboard-shortcuts')"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-blue-400 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
            >
              <span>Next: Keyboard Shortcuts</span>
              <span>→</span>
            </button>
          </div>
        </section>

        <!-- 3. Keyboard Shortcuts Section -->
        <section id="keyboard-shortcuts" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono text-blue-400 mb-1">
              <span>03 / 04</span>
              <span>•</span>
              <span>Productivity</span>
            </div>
            <h2 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>⌨️ Keyboard Shortcuts</span>
            </h2>
            <p class="text-sm text-neutral-400 mt-1.5 leading-relaxed">
              Boost your productivity with built-in IDE hotkeys.
            </p>
          </div>

          <div class="bg-[#161b22] border border-[#2d2d30] rounded-xl overflow-hidden shadow-lg">
            <table class="w-full text-xs text-left">
              <thead class="bg-[#12161f] border-b border-[#2d2d30] text-neutral-400 uppercase font-mono text-[10px]">
                <tr>
                  <th class="px-4 py-3">Action</th>
                  <th class="px-4 py-3">Mac Shortcut</th>
                  <th class="px-4 py-3">Windows / Linux</th>
                  <th class="px-4 py-3">Description</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-[#2d2d30] font-mono text-neutral-300">
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">Save & Re-layout</td>
                  <td class="px-4 py-3"><kbd class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700">⌘S</kbd></td>
                  <td class="px-4 py-3"><kbd class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700">Ctrl+S</kbd></td>
                  <td class="px-4 py-3 font-sans text-neutral-400">Saves file and recalculates ELK graph layout</td>
                </tr>
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">New Tab</td>
                  <td class="px-4 py-3"><kbd class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700">⌘N / +</kbd></td>
                  <td class="px-4 py-3"><kbd class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700">Ctrl+N / +</kbd></td>
                  <td class="px-4 py-3 font-sans text-neutral-400">Creates a new isolated SQL schema tab</td>
                </tr>
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">Zoom In / Out</td>
                  <td class="px-4 py-3"><kbd class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700">Scroll / Pinch</kbd></td>
                  <td class="px-4 py-3"><kbd class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700">Ctrl + Scroll</kbd></td>
                  <td class="px-4 py-3 font-sans text-neutral-400">Smooth zoom canvas viewport</td>
                </tr>
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">Pan Canvas</td>
                  <td class="px-4 py-3"><kbd class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700">Space + Drag</kbd></td>
                  <td class="px-4 py-3"><kbd class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700">Space + Drag</kbd></td>
                  <td class="px-4 py-3 font-sans text-neutral-400">Pan diagram workspace in all directions</td>
                </tr>
                <tr class="hover:bg-white/5">
                  <td class="px-4 py-3 font-sans font-semibold text-white">Rename Tab</td>
                  <td class="px-4 py-3"><kbd class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700">Double Click</kbd></td>
                  <td class="px-4 py-3"><kbd class="px-2 py-0.5 bg-[#252528] rounded border border-neutral-700">Double Click</kbd></td>
                  <td class="px-4 py-3 font-sans text-neutral-400">Edit schema tab title inline</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Section Navigation Buttons -->
          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              @click="scrollTo('syntax-support')"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-neutral-300 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
            >
              <span>← Previous: Syntax Support</span>
            </button>
            <button
              type="button"
              @click="scrollTo('theme-suite')"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-blue-400 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
            >
              <span>Next: Monokai & Themes</span>
              <span>→</span>
            </button>
          </div>
        </section>

        <!-- 4. Theme Suite Section -->
        <section id="theme-suite" class="space-y-5 pt-4 scroll-mt-20">
          <div class="border-b border-[#2d2d30] pb-4">
            <div class="flex items-center gap-2 text-xs font-mono text-blue-400 mb-1">
              <span>04 / 04</span>
              <span>•</span>
              <span>Visual Customization</span>
            </div>
            <h2 class="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
              <span>🎨 Monokai & Theme Suite</span>
            </h2>
            <p class="text-sm text-neutral-400 mt-1.5 leading-relaxed">
              Customize the editor and application shell with curated developer palettes.
            </p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div class="p-4 bg-[#272822] border border-[#49483e] rounded-xl space-y-2 shadow-lg">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span>Monokai Classic</span>
                <span class="px-1.5 py-0.2 rounded text-[9px] font-mono bg-pink-500/20 text-pink-400 border border-pink-500/40">
                  Suite
                </span>
              </span>
              <p class="text-xs text-[#f8f8f2]/80 leading-relaxed">
                Charcoal background with iconic vibrant pink keywords, yellow strings, green identifiers, and cyan types.
              </p>
            </div>

            <div class="p-4 bg-[#282a36] border border-[#44475a] rounded-xl space-y-2 shadow-lg">
              <span class="font-bold text-sm text-white flex items-center gap-2">
                <span>Dracula Dark</span>
              </span>
              <p class="text-xs text-[#f8f8f2]/80 leading-relaxed">
                Purple nocturnal aesthetic with glowing cyan, green, and pink highlights.
              </p>
            </div>
          </div>

          <!-- Final Section Navigation Button -->
          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              @click="scrollTo('keyboard-shortcuts')"
              class="px-4 py-2 bg-[#161b22] hover:bg-[#202734] border border-[#2d2d30] text-neutral-300 font-medium text-xs rounded-lg transition-colors flex items-center gap-2 cursor-pointer"
            >
              <span>← Previous: Keyboard Shortcuts</span>
            </button>
            <NuxtLink
              to="/"
              class="px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white font-semibold text-xs rounded-lg transition-colors flex items-center gap-2 shadow-md"
            >
              <span>Launch Visual Editor</span>
              <span>→</span>
            </NuxtLink>
          </div>
        </section>
      </main>
    </div>
  </div>
</template>
