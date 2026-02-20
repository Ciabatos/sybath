import { TKnownMapRegion } from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"

type Point = { x: number; y: number }
type Edge = { a: Point; b: Point }

export function buildRegionOutline(tiles: TKnownMapRegion[], tileSize: number) {
  const edges = new Map<string, Edge>()

  function addEdge(a: Point, b: Point) {
    const key = `${a.x},${a.y}|${b.x},${b.y}`
    const reverseKey = `${b.x},${b.y}|${a.x},${a.y}`
    if (edges.has(reverseKey)) edges.delete(reverseKey)
    else edges.set(key, { a, b })
  }

  for (const t of tiles) {
    const x = t.mapTileX * tileSize
    const y = t.mapTileY * tileSize
    const s = tileSize

    const p1 = { x, y }
    const p2 = { x: x + s, y }
    const p3 = { x: x + s, y: y + s }
    const p4 = { x, y: y + s }

    addEdge(p1, p2)
    addEdge(p2, p3)
    addEdge(p3, p4)
    addEdge(p4, p1)
  }

  return [...edges.values()]
}

export function orderEdgesToPolygon(edges: Edge[]) {
  if (!edges.length) return []

  const result: Point[] = []
  const first = edges.pop()!
  result.push(first.a, first.b)

  while (edges.length) {
    const last = result[result.length - 1]
    const idx = edges.findIndex((e) => (e.a.x === last.x && e.a.y === last.y) || (e.b.x === last.x && e.b.y === last.y))
    if (idx === -1) break
    const e = edges.splice(idx, 1)[0]
    if (e.a.x === last.x && e.a.y === last.y) result.push(e.b)
    else result.push(e.a)
  }

  return result
}
