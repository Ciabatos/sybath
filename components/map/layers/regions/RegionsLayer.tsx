"use client"

import { TKnownMapRegion } from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import { buildRegionLoops, loopToPolygonPath, tileCentroid } from "@/methods/functions/map/layers/regionOutline"
import { useRegionLayerProvince } from "@/methods/hooks/world/composite/useRegionLayerProvince"
import { useMemo } from "react"
import style from "./styles/RegionsLayer.module.css"

const TILE_SIZE = 64

/**
 * Obrys regionów.
 *
 * Jedyna warstwa, która nie należy do pojedynczego kafelka — rysuje się na całej
 * siatce jako `<svg>`. Nie potrzebuje osobnej grupy ruchu, bo `position:
 * absolute` i tak wyrywa ją z przepływu.
 *
 * `useRegionLayerProvince` ma na sztywno `regionType = 1`, czyli na razie
 *(regiony == provinces). Odkąd pojawią się inne typy regionów, nazwa
 * `useRegionLayerProvince` przestanie pasować.
 *
 * Każda pętla rysowana jest dwukrotnie: grubsza ciemna „obwódka" pod węższą
 * złotą linią, żeby obrys był czytelny nad każdym terenem.
 */
export default function RegionsLayer() {
  const { knownMapRegion } = useRegionLayerProvince()

  const regions = useMemo(() => {
    const tilesByRegion: Record<number, TKnownMapRegion[]> = {}

    Object.values(knownMapRegion).forEach((tile) => {
      const id = tile.regionId

      if (!id || id <= 0) return

      if (!tilesByRegion[id]) tilesByRegion[id] = []

      tilesByRegion[id].push({
        ...tile,
        // Przesunięcie o 1 z oryginalnej wersji — nie zmieniam go, bo nie da się
        // zweryfikować pochodzenia bez bazy. Jeśli obrys jest przesunięty o
        // kafel, to jest to miejsce do poprawki.
        mapTileX: tile.mapTileX - 1,
        mapTileY: tile.mapTileY - 1,
      })
    })

    return Object.entries(tilesByRegion)
      .map(([regionId, tiles]) => ({
        regionId: Number(regionId),
        name: tiles[0]?.regionName,
        paths: buildRegionLoops(tiles, TILE_SIZE)
          .map((loop) => loopToPolygonPath(loop))
          .filter(Boolean),
        label: tileCentroid(tiles, TILE_SIZE),
      }))
      .filter((region) => region.paths.length > 0)
  }, [knownMapRegion])

  if (!regions.length) return null

  return (
    <svg className={style.Layer}>
      {regions.map(({ regionId, paths }) => (
        <g key={regionId}>
          {paths.map((d) => (
            <g key={d}>
              {/* Obwódka — ciemna, grubsza, żeby linia nie ginęła na terenie. */}
              <path className={style.casing} d={d} />
              {/* Właściwa linia. */}
              <path className={style.line} d={d} />
            </g>
          ))}
        </g>
      ))}

      {regions.map(({ regionId, name, label }) =>
        name && label ? (
          <text
            key={`label-${regionId}`}
            className={style.label}
            x={label.x}
            y={label.y}
            /*
              Siatka `.Tiles` to `rotate(-45deg) skew(15deg,15deg)`, więc odwrócenie
              to `skew(-15deg,-15deg) rotate(45deg)`. SVG składa listę
              transformów od lewej do prawej, więc kolejność musi być dokładnie taka.
            */
            transform={`skew(-15 -15 ${label.x} ${label.y}) rotate(45 ${label.x} ${label.y})`}
          >
            {name}
          </text>
        ) : null,
      )}
    </svg>
  )
}