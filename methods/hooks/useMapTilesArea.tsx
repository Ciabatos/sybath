"use client"

import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export interface TGuardAreaPath {
  id: number
  x: number
  y: number
  terrain_type_id: number
  terrain_name?: string
  terrain_move_cost?: number
  image_url?: string
  map_field_id?: number
  player_image_url?: string
  player_name?: string
}

export function useMapTilesArea() {
  const mapTiles = useAtomValue(joinedMapTilesAtom)

  function areaFromPoint(startX: number, startY: number, objectProperties: number): TGuardAreaPath[] {
    if (!startX || !startY) {
      return []
    }

    const AreaXY: { x: number; y: number }[] = []

    for (let x = startX - objectProperties; x <= startX + objectProperties; x++) {
      for (let y = startY - objectProperties; y <= startY + objectProperties; y++) {
        const dist = Math.abs(startX - x) + Math.abs(startY - y)
        if (dist <= objectProperties || dist <= objectProperties * 2) {
          AreaXY.push({ x, y })
        }
      }
    }

    const filteredMapTiles = AreaXY.map(({ x, y }) => {
      const key = `${x},${y}`
      const tile = mapTiles[key]

      return tile
        ? {
            ...tile,
          }
        : null
    }).filter((tile): tile is TGuardAreaPath => tile !== null) // Remove null values and assert that the remaining tiles are TMovmentPath

    return filteredMapTiles
  }

  return { areaFromPoint }
}
