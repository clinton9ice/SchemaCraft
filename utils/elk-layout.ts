import ELK from 'elkjs/lib/elk.bundled.js'
import type { CompiledTable, CompiledRelation } from '~/utils/sql-compiler'

const elk = new ELK()

export interface LayoutedGraph {
  positions: Record<string, { x: number; y: number }>
  width?: number
  height?: number
}

export async function layoutWithElk(
  tables: CompiledTable[],
  relations: CompiledRelation[],
  options: {
    direction?: 'RIGHT' | 'DOWN'
    nodeSpacing?: number
    layerSpacing?: number
  } = {}
): Promise<LayoutedGraph> {
  const { direction = 'RIGHT', nodeSpacing = 70, layerSpacing = 90 } = options

  if (!tables.length) {
    return { positions: {} }
  }

  const validTableNames = new Set(tables.map((t) => t.name))

  const elkNodes = tables.map((table) => {
    const rowCount = table.columns?.length || 1
    const calculatedHeight = Math.max(80, 44 + rowCount * 30 + 16)

    return {
      id: table.name,
      width: 288,
      height: calculatedHeight,
    }
  })

  const elkEdges = relations
    .map((rel, idx) => {
      const sourceTable = rel.fromTable || (rel.from || '').split('.')[0] || ''
      const targetTable = rel.toTable || (rel.to || '').split('.')[0] || ''

      return {
        id: `elk-edge-${idx}`,
        sources: [sourceTable],
        targets: [targetTable],
      }
    })
    .filter(
      (e) =>
        e.sources[0] &&
        e.targets[0] &&
        e.sources[0] !== e.targets[0] &&
        validTableNames.has(e.sources[0]) &&
        validTableNames.has(e.targets[0])
    )

  const graph = {
    id: 'root_diagram',
    layoutOptions: {
      'elk.algorithm': 'layered',
      'elk.direction': direction,
      'elk.spacing.nodeNode': String(nodeSpacing),
      'elk.layered.spacing.nodeNodeBetweenLayers': String(layerSpacing),
      'elk.edgeRouting': 'ORTHOGONAL',
      'elk.layered.nodePlacement.strategy': 'BRANDES_KOEPF',
      'elk.layered.crossingMinimization.strategy': 'LAYER_SWEEP',
    },
    children: elkNodes,
    edges: elkEdges,
  }

  try {
    const layouted = await elk.layout(graph)
    const positions: Record<string, { x: number; y: number }> = {}

    if (layouted.children) {
      layouted.children.forEach((child) => {
        positions[child.id] = {
          x: Math.round(child.x || 0) + 50,
          y: Math.round(child.y || 0) + 50,
        }
      })
    }

    return {
      positions,
      width: (layouted as any).width,
      height: (layouted as any).height,
    }
  } catch (err) {
    console.warn('ELK layout fallback:', err)
    const positions: Record<string, { x: number; y: number }> = {}
    tables.forEach((table, idx) => {
      const colIndex = idx % 3
      const rowIndex = Math.floor(idx / 3)
      positions[table.name] = {
        x: 50 + colIndex * 360,
        y: 50 + rowIndex * 380,
      }
    })
    return { positions }
  }
}

