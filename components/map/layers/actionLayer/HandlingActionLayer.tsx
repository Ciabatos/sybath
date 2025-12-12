"use client"

import { TJoinMap } from "@/methods/functions/map/joinMap"
import { useActionMapTilesGuardArea } from "@/methods/hooks/players/composite/usePlayerGuardArea"
import { useMapTilesPathFromPointToPoint } from "@/methods/hooks/world/composite/useMapTilesPathFromPointToPoint"

interface Props {
  tile: TJoinMap
}

export default function HandlingActionLayer({ tile }: Props) {
  // const { loadPanel } = useLazyPanelLoader()
  const { mapTilesMovementPathSet } = useMapTilesPathFromPointToPoint()
  const { mapTilesGuardAreaSet } = useActionMapTilesGuardArea()

  const isTileInMovementPath = mapTilesMovementPathSet.has(`${tile.tiles.x},${tile.tiles.y}`)
  const isTileInGuardArea = mapTilesGuardAreaSet.has(`${tile.tiles.x},${tile.tiles.y}`)

  if (!isTileInMovementPath && !isTileInGuardArea) {
    return null
  }

  // if (actualMapTilesActionStatus.GuardAreaAction && isTileInMovementPath && isTileInGuardArea) {
  //   return (
  //     <>
  //       <GuardAreaActionLayer />
  //       <MovementActionLayer />
  //     </>
  //   )
  // }
  // if (actualMapTilesActionStatus.MovementAction && isTileInMovementPath) {
  //   return <MovementActionLayer />
  // }

  // if (actualMapTilesActionStatus.UseAbilityAction && isTileInMovementPath) {
  //   return <MovementActionLayer />
  // }

  // if (actualMapTilesActionStatus.GuardAreaAction && isTileInGuardArea) {
  //   return <GuardAreaActionLayer />
  // }

  // if (actualMapTilesActionStatus.GuardAreaAction && isTileInMovementPath) {
  //   return <MovementActionLayer />
  // }

  return null
}
