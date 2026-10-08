"use client"

import { usePlayerMovementPlanned } from "@/methods/hooks/players/composite/usePlayerMovement"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import styles from "./styles/MovementPlannedLayer.module.css"

/**
 * Zaplanowana trasa ruchu — przerywana ramka i koszt kafelka.
 *
 * Warstwa „pod" (`layers/mapUnderneath`): renderowana w `MapTile` przed
 * licznikami i ikonicami, żeby przy nakładaniu wygrywała treść, nie obrys.
 */
export default function MovementPlannedLayer({ mapTiles }: TMapTile) {
  const playerMovementPlanned = usePlayerMovementPlanned()
  const layerData = playerMovementPlanned[`${mapTiles.x},${mapTiles.y}`]

  if (!layerData) return null

  return (
    <div className={styles.overlay}>
      <span className={styles.cost}>{layerData.moveCost}</span>
    </div>
  )
}