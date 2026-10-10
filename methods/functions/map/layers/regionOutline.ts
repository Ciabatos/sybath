import { TKnownMapRegion } from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"

export type TPoint = { x: number; y: number }

type TEdge = { a: TPoint; b: TPoint }

/* Kierunki w kolejności zgodnej z ruchem wskazówek zegara (oś Y w dół). */
const DIR_RIGHT = 0
const DIR_DOWN = 1
const DIR_LEFT = 2
const DIR_UP = 3

function key(p: TPoint) {
  return `${p.x},${p.y}`
}

function edgeKey(e: TEdge) {
  return `${key(e.a)}>${key(e.b)}`
}

function dirIndex(from: TPoint, to: TPoint): number {
  const dx = to.x - from.x
  const dy = to.y - from.y

  if (dx > 0) return DIR_RIGHT
  if (dy > 0) return DIR_DOWN
  if (dx < 0) return DIR_LEFT

  return DIR_UP
}

function round2(n: number) {
  return Math.round(n * 100) / 100
}

/**
 * Krawędzie brzegowe regionu jako skierowane półkrawędzie.
 *
 * Każdy kafelek dokłada swoje cztery krawędzie w kolejności zgodnej z ruchem
 * wskazówek zegara (współrzędne ekranowe, Y w dół), więc wnętrze jest stale
 * po prawej stronie kierunku marszu. Krawędź dzielona przez dwa kafelki pojawia
 * się wtedy dwa razy w przeciwnych kierunkach — wystarczy je parami skasować.
 * Zostają wyłącznie krawędzie brzegowe.
 */
function collectBoundaryEdges(tiles: TKnownMapRegion[], tileSize: number): TEdge[] {
  const edges = new Map<string, TEdge>()

  function addEdge(a: TPoint, b: TPoint) {
    const forward = `${key(a)}>${key(b)}`
    const backward = `${key(b)}>${key(a)}`

    if (edges.has(backward)) edges.delete(backward)
    else edges.set(forward, { a, b })
  }

  for (const t of tiles) {
    const x = t.mapTileX * tileSize
    const y = t.mapTileY * tileSize
    const s = tileSize

    addEdge({ x, y }, { x: x + s, y })
    addEdge({ x: x + s, y }, { x: x + s, y: y + s })
    addEdge({ x: x + s, y: y + s }, { x, y: y + s })
    addEdge({ x, y: y + s }, { x, y })
  }

  return [...edges.values()]
}

/**
 * Rozbija brzeg regionu na domknięte pętle.
 *
 * Zwraca WSZYSTKIE pętle, nie tylko pierwszą: region może mieć dziurę albo
 * składać się z kilku rozłącznych kawałków i każdy musi dostać własną obwódkę.
 *
 * W wierzchołku, gdzie stykają się cztery kafelki „na krzyż", istnieją dwie
 * krawędzie wychodzące. Bierzemy tę z skrętem w prawo, potem prostą, potem w
 * lewo — dzięki temu pętle się nie przecinają i każda zawija się ciasno wokół
 * własnego wnętrza.
 */
export function buildRegionLoops(tiles: TKnownMapRegion[], tileSize: number): TPoint[][] {
  const allEdges = collectBoundaryEdges(tiles, tileSize)

  if (!allEdges.length) return []

  const outgoing = new Map<string, TEdge[]>()

  for (const edge of allEdges) {
    const k = key(edge.a)
    const list = outgoing.get(k)

    if (list) list.push(edge)
    else outgoing.set(k, [edge])
  }

  const used = new Set<string>()
  const loops: TPoint[][] = []

  for (const start of allEdges) {
    if (used.has(edgeKey(start))) continue

    used.add(edgeKey(start))

    const loop: TPoint[] = [start.a]
    let current = start
    let closed = false

    while (true) {
      const from = current.b
      const dir = dirIndex(current.a, current.b)
      const candidates = (outgoing.get(key(from)) ?? []).filter((edge) => !used.has(edgeKey(edge)))

      if (!candidates.length) break

      const preference = [(dir + 1) % 4, dir, (dir + 3) % 4, (dir + 2) % 4]
      let next: TEdge | undefined

      for (const wanted of preference) {
        next = candidates.find((edge) => dirIndex(from, edge.b) === wanted)
        if (next) break
      }

      if (!next) break

      used.add(edgeKey(next))

      /*
        Dokładamy `next.a`, czyli punkt, przez który właśnie przeszliśmy —
        a NIE `next.b`. Wcześniej pushowaliśmy `next.b`, przez co pomijał się
        wierzchołek `current.b`: pętla z jednego kafelka miała [A, C, D]
        zamiast [A, B, C, D], a `Z` domykał ją trójkątem. Stąd „piramidy".
      */
      loop.push(next.a)

      current = next

      // Wróciliśmy do punktu startowego — pętla domknięta.
      if (key(next.b) === key(start.a)) {
        closed = true
        break
      }
    }

    /*
      Otwarty łańcuch to nie jest obrys. Bez tego warunku trafiłby do wyników,
      a `loopToPolygonPath` domknąłby go poleceniem `Z` — czyli prostą od
      ostatniego wierzchołka z powrotem do pierwszego.
    */
    if (!closed) continue

    if (loop.length >= 3) loops.push(loop)
  }

  return loops
}

/** Usuwa duplikaty i wierzchołki leżące na jednej prostej. */
function simplify(points: TPoint[]): TPoint[] {
  const deduped: TPoint[] = []

  for (const p of points) {
    const previous = deduped[deduped.length - 1]

    if (!previous || previous.x !== p.x || previous.y !== p.y) deduped.push(p)
  }

  if (deduped.length > 1) {
    const first = deduped[0]
    const last = deduped[deduped.length - 1]

    if (first.x === last.x && first.y === last.y) deduped.pop()
  }

  const n = deduped.length
  const corners: TPoint[] = []

  for (let i = 0; i < n; i++) {
    const prev = deduped[(i - 1 + n) % n]
    const cur = deduped[i]
    const next = deduped[(i + 1) % n]

    const cross = (cur.x - prev.x) * (next.y - cur.y) - (cur.y - prev.y) * (next.x - cur.x)

    // Zerowy cross = kąt prosty w marszu, czyli punkt leży na prostej.
    if (cross !== 0) corners.push(cur)
  }

  return corners.length >= 3 ? corners : deduped
}

/**
 * Ścieżka SVG złamanej — bez zaokrągleń.
 *
 * Krawędź regionu to schody o kroku 64px i kąty proste. Zaokrąglanie narożników
 * na przekrzywionej siatce czyta się jako plamy, a nie obrys, więc zostawiamy
 * surowe łamanie. `simplify` i tak usuwa punkty leżące na prostej, więc ścieżka
 * zawiera wyłącznie narożniki.
 */
export function loopToPolygonPath(points: TPoint[]): string {
  const corners = simplify(points)
  const n = corners.length

  if (n < 3) return ""

  let d = `M ${round2(corners[0].x)} ${round2(corners[0].y)}`

  for (let i = 1; i < n; i++) {
    d += ` L ${round2(corners[i].x)} ${round2(corners[i].y)}`
  }

  return `${d} Z`
}

/** Środek z obszaru kafelków regionu — zawsze wewnątrz, w przeciwieństwie do środka wielokąta. */
export function tileCentroid(tiles: TKnownMapRegion[], tileSize: number): TPoint | null {
  if (!tiles.length) return null

  let sumX = 0
  let sumY = 0

  for (const t of tiles) {
    sumX += t.mapTileX * tileSize + tileSize / 2
    sumY += t.mapTileY * tileSize + tileSize / 2
  }

  return { x: round2(sumX / tiles.length), y: round2(sumY / tiles.length) }
}
