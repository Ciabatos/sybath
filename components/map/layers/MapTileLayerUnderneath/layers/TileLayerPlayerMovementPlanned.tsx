"use client"

import { usePlayerMovementPlanned } from "@/methods/hooks/players/composite/usePlayerMovement"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import styles from "./styles/TileLayerPlayerMovementPlanned.module.css"

export default function TileLayerPlayerMovementPlanned({ mapTiles }: TMapTile) {
  const playerMovementPlanned = usePlayerMovementPlanned()
  const layerData = playerMovementPlanned[`${mapTiles.x},${mapTiles.y}`]

  if (!layerData) return null

  return (
    <div className={styles.overlay}>
      <span className={styles.cost}>{layerData.moveCost}</span>
    </div>
  )
}