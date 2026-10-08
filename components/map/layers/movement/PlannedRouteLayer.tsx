"use client"

import { usePlayerMovementPlanned } from "@/methods/hooks/players/composite/usePlayerMovement"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import styles from "./styles/PlannedRouteLayer.module.css"

/**
 * Zaplanowana trasa ruchu — przerywana ramka i koszt do zapłaty na kafelku.
 *
 * Rysowana pierwsza w `.layers` kafelka, więc liczniki i ikony innych warstw
 * lądują na wierzchu. Kolejność jest jawna w `MapTile`, nie w nazwie folderu.
 */
export default function PlannedRouteLayer({ mapTiles }: TMapTile) {
  const playerMovementPlanned = usePlayerMovementPlanned()
  const layerData = playerMovementPlanned[`${mapTiles.x},${mapTiles.y}`]

  if (!layerData) return null

  return (
    <div className={styles.overlay}>
      <span className={styles.cost}>{layerData.moveCost}</span>
    </div>
  )
}