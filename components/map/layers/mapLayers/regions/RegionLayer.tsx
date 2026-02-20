"use client"

import { TKnownMapRegion } from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import { buildRegionOutline, orderEdgesToPolygon } from "@/methods/functions/map/layers/buildRegions"
import { useRegionLayerProvince } from "@/methods/hooks/world/composite/useRegionLayerProvince"
import style from "./styles/RegionLayer.module.css"

const TILE_SIZE = 64

export default function RegionLayer() {
  //zamienic na provincesRegion
  const { knownMapRegion } = useRegionLayerProvince()

  const tilesByRegion: Record<number, TKnownMapRegion[]> = {}

  Object.values(knownMapRegion).forEach((tile) => {
    const id = tile.regionId

    if (!id || id <= 0) return

    if (!tilesByRegion[id]) {
      tilesByRegion[id] = []
    }

    tilesByRegion[id].push({
      ...tile,
      mapTileX: tile.mapTileX - 1,
      mapTileY: tile.mapTileY - 1,
    })
  })

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
        const imageOutline = tiles[0]?.imageOutline
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
        const clipId = `clip-region-${regionId}`

        return (
          <g key={regionId}>
            <defs>
              <clipPath id={clipId}>
                <polygon points={points} />
              </clipPath>
            </defs>

            {/* Stroke z podwojoną grubością, przycięty do ZEWNĄTRZ przez inwersję */}
            {/* Trick: rysujemy stroke 2x grubszy, clipPath wycina wnętrze → zostaje tylko zewnętrzny stroke */}
            <polygon
              points={points}
              fill='none'
              stroke={imageOutline}
              strokeWidth={8} // 2x docelowa grubość
              strokeLinejoin='round'
              clipPath={`url(#${clipId})`}
            />
          </g>
        )
      })}
    </svg>
  )
}
