"use client"

import { useMapHandlingData } from "@/methods/hooks/world/composite/useMapHandlingData"
import style from "./styles/RegionLayer.module.css"

type Point = { x: number; y: number }
type Edge = { a: Point; b: Point }

const TILE_SIZE = 64

function buildRegionOutline(tiles: { x: number; y: number }[], tileSize: number) {
  const edges = new Map<string, Edge>()

  function addEdge(a: Point, b: Point) {
    const key = `${a.x},${a.y}|${b.x},${b.y}`
    const reverseKey = `${b.x},${b.y}|${a.x},${a.y}`
    if (edges.has(reverseKey)) edges.delete(reverseKey)
    else edges.set(key, { a, b })
  }

  for (const t of tiles) {
    const x = t.x * tileSize
    const y = t.y * tileSize
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

function orderEdgesToPolygon(edges: Edge[]) {
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

export default function RegionLayer() {
  const { combinedMap } = useMapHandlingData()

  // Grupowanie kafelków po regionId
  const tilesByRegion = combinedMap.reduce(
    (acc, t) => {
      const id = t.mapTiles.regionId
      if (id && id > 0) {
        if (!acc[id]) acc[id] = []
        acc[id].push({
          x: t.mapTiles.x - 1,
          y: t.mapTiles.y - 1,
          // type: t.mapTiles.region_type, // zakładam, że masz region_type w mapTiles
        })
      }
      return acc
    },
    {} as Record<number, { x: number; y: number; type?: string }[]>,
  )

  if (!Object.keys(tilesByRegion).length) return null

  return (
    <svg className={style.Layer}>
      <defs>
        {/* Plażowy pattern */}
        <pattern
          id='beachPattern'
          patternUnits='userSpaceOnUse'
          width='64'
          height='64'
        >
          <image
            href='/terrainTypePicture/beach.png'
            x='0'
            y='0'
            width='64'
            height='64'
          />
        </pattern>

        {/* Filter falowania */}
        <filter id='wavy'>
          <feTurbulence
            type='fractalNoise'
            baseFrequency='0.3'
            numOctaves='6'
            result='noise'
          />
          <feDisplacementMap
            in2='noise'
            in='SourceGraphic'
            scale='6'
          />
        </filter>
      </defs>

      {Object.entries(tilesByRegion).map(([regionIdStr, tiles]) => {
        const regionId = Number(regionIdStr)
        if (!tiles.length) return null

        const edges = buildRegionOutline(tiles, TILE_SIZE)
        const polygon = orderEdgesToPolygon(edges)
        let finalPolygon = polygon
        if (
          polygon.length &&
          (polygon[0].x !== polygon[polygon.length - 1].x || polygon[0].y !== polygon[polygon.length - 1].y)
        ) {
          finalPolygon = [...polygon, polygon[0]]
        }
        const points = finalPolygon.map((p) => `${p.x},${p.y}`).join(" ")

        return (
          <g key={regionId}>
            {/* Plaża/falowany obrys */}
            <polygon
              points={points}
              fill='none'
              stroke='url(#beachPattern)'
              strokeWidth={5}
              strokeLinejoin='round'
              filter='url(#wavy)'
            />

            {/* Fill regionu */}
            <polygon
              points={points}
              fill='none'
            />
          </g>
        )
      })}
    </svg>
  )
}
