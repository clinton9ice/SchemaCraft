<script setup lang="ts">
const { parsedTables, parsedRelations, isParsing } = useSchemaStore()

function getPrimaryKeys(table: any): string {
  if (!table || !Array.isArray(table.columns)) return 'no PK'
  const pks = table.columns.filter((c: any) => c.isPrimaryKey).map((c: any) => c.name)
  return pks.length ? pks.join(', ') : 'no PK'
}
</script>

<template>
  <div class="flex flex-col items-center justify-center p-8 text-center max-w-xl select-none animate-in fade-in duration-300">
    <!-- Visual Canvas Icon -->
    <div class="relative w-16 h-16 mb-5 flex items-center justify-center">
      <div class="absolute inset-0 bg-blue-500/10 rounded-2xl border border-blue-500/20 blur-xs" />
      <div class="relative w-14 h-14 rounded-xl bg-gradient-to-b from-[#1f2430] to-[#141822] border border-[#2d3345] shadow-2xl flex items-center justify-center text-blue-400">
        <svg class="w-7 h-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
          <rect x="3" y="3" width="18" height="18" rx="3"/>
          <path d="M3 9h18"/>
          <path d="M9 21V9"/>
        </svg>
      </div>
    </div>

    <!-- Title & Description -->
    <h3 class="text-base font-semibold text-neutral-100 mb-1.5 tracking-tight">
      Relational Diagram Viewport
    </h3>
    <p class="text-xs text-neutral-400 leading-relaxed mb-5 max-w-md">
      Nitro backend AST parser extracts schema graph structure in real-time.
    </p>

    <!-- Parsed Schema Summary Card -->
    <div class="w-full bg-[#141822]/90 border border-[#252a3a] rounded-xl p-4 text-left shadow-xl">
      <div class="flex items-center justify-between pb-3 border-b border-[#252a3a] mb-3">
        <div class="flex items-center gap-2 text-xs font-semibold text-white">
          <span class="w-2 h-2 rounded-full bg-emerald-400" />
          <span>Extracted Schema Graph</span>
        </div>
        <div class="flex items-center gap-3 text-[11px] text-neutral-400 font-mono">
          <span>{{ parsedTables.length }} Tables</span>
          <span>•</span>
          <span>{{ parsedRelations.length }} Relations</span>
        </div>
      </div>

      <!-- Tables Grid / Badges -->
      <div v-if="parsedTables.length" class="space-y-3">
        <div class="grid grid-cols-2 sm:grid-cols-3 gap-2">
          <div
            v-for="table in parsedTables"
            :key="table.name"
            class="bg-[#1a202c]/80 border border-[#2d3748] rounded-lg p-2.5 flex flex-col gap-1"
          >
            <div class="flex items-center gap-1.5 text-xs font-bold text-blue-300 truncate">
              <svg class="w-3.5 h-3.5 text-blue-400 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="3" width="18" height="18" rx="2"/>
                <line x1="3" y1="9" x2="21" y2="9"/>
              </svg>
              <span class="truncate">{{ table.name }}</span>
            </div>
            <div class="text-[10px] text-neutral-400 font-mono">
              {{ (table.columns || []).length }} columns • {{ getPrimaryKeys(table) }}
            </div>
          </div>
        </div>

        <!-- Relations Preview -->
        <div v-if="parsedRelations.length" class="pt-2 border-t border-[#252a3a]/80">
          <div class="text-[11px] font-semibold text-neutral-400 mb-1.5">Foreign Key References:</div>
          <div class="flex flex-wrap gap-1.5">
            <span
              v-for="(rel, idx) in parsedRelations"
              :key="idx"
              class="inline-flex items-center gap-1 px-2 py-0.5 rounded bg-blue-950/60 border border-blue-800/40 text-[10px] font-mono text-blue-300"
            >
              {{ rel.from }} → {{ rel.to }}
            </span>
          </div>
        </div>
      </div>

      <!-- Empty State / Loading State -->
      <div v-else-if="isParsing" class="py-6 text-center text-xs text-neutral-400 font-mono flex items-center justify-center gap-2">
        <svg class="w-4 h-4 animate-spin text-blue-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 12a9 9 0 1 1-6.219-8.56"/>
        </svg>
        Extracting schema graph on Nitro...
      </div>
      <div v-else class="py-6 text-center text-xs text-neutral-400">
        No <code class="text-blue-400 font-mono">CREATE TABLE</code> statements found in editor.
      </div>
    </div>
  </div>
</template>
