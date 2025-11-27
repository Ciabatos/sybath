"use client"

import GuardAreaActionLayer from "@/components/map/layers/actionLayer/GuardAreaActionLayer"
import MovementActionLayer from "@/components/map/layers/actionLayer/MovementActionLayer"
import { TJoinMap } from "@/methods/functions/map/joinMap"
import { useActionMapTilesGuardArea } from "@/methods/hooks/world/composite/useActionMapTilesGuardArea"
import { useActionMapTilesMovement } from "@/methods/hooks/world/composite/useActionMapTilesMovement"
import { useModal } from "@/methods/hooks/modals/useModal"

interface Props {
  tile: TJoinMap
}

export default function HandlingActionLayer({ tile }: Props) {
  const { actualMapTilesActionStatus } = useModal()
  const { mapTilesMovementPathSet } = useActionMapTilesMovement()
  const { mapTilesGuardAreaSet } = useActionMapTilesGuardArea()

  const isTileInMovementPath = mapTilesMovementPathSet.has(`${tile.tiles.x},${tile.tiles.y}`)
  const isTileInGuardArea = mapTilesGuardAreaSet.has(`${tile.tiles.x},${tile.tiles.y}`)

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
