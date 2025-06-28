"use client"

import GuardAreaActionLayer from "@/components/map/layers/actionLayer/GuardAreaActionLayer"
import MovementActionLayer from "@/components/map/layers/actionLayer/MovementActionLayer"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useActionMapTilesGuardArea } from "@/methods/hooks/mapTiles/composite/useActionMapTilesGuardArea"
import { useActionMapTilesMovement } from "@/methods/hooks/mapTiles/composite/useActionMapTilesMovement"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"

interface Props {
  tile: TJoinedMapTile
}

export default function HandlingActionLayer({ tile }: Props) {
  const { actualMapTilesActionStatus } = useMapTilesActionStatus()
  const { mapTilesMovementPathSet } = useActionMapTilesMovement()
  const { mapTilesGuardAreaSet } = useActionMapTilesGuardArea()

  const isTileInMovementPath = mapTilesMovementPathSet.has(`${tile.mapTile.x},${tile.mapTile.y}`)
  const isTileInGuardArea = mapTilesGuardAreaSet.has(`${tile.mapTile.x},${tile.mapTile.y}`)

  if (!isTileInMovementPath && !isTileInGuardArea) {
    return null
  }

  if (actualMapTilesActionStatus.GuardAreaAction && isTileInMovementPath && isTileInGuardArea) {
    return (
      <>
        <GuardAreaActionLayer />
        <MovementActionLayer />
      </>
    )
  }
  if (actualMapTilesActionStatus.MovementAction && isTileInMovementPath) {
    return <MovementActionLayer />
  }

  if (actualMapTilesActionStatus.UseAbilityAction && isTileInMovementPath) {
    return <MovementActionLayer />
  }

  if (actualMapTilesActionStatus.GuardAreaAction && isTileInGuardArea) {
    return <GuardAreaActionLayer />
  }

  if (actualMapTilesActionStatus.GuardAreaAction && isTileInMovementPath) {
    return <MovementActionLayer />
  }

  return null
}
