"use client"

import { TPlayerVisibleMapData } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import { playerMovementAction } from "@/methods/actions/mapTiles/playerMovementAction"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useMapTilesPath } from "@/methods/hooks/mapTiles/useMapTilesPath"
import { usePlayerAbility } from "@/methods/hooks/playerAbility/usePlayerAbility"
import { usePlayerAbilityRequirements } from "@/methods/hooks/playerAbility/usePlayerAbilityRequirements"
import { useActionTaskInProcess } from "@/methods/hooks/tasks/useActionTaskInProcess"
import { clickedTileAtom, mapTilesMovementPathAtom, playerPositionMapTileAtom } from "@/store/atoms"
import { useAtom, useAtomValue } from "jotai"
import { useEffect, useState } from "react"

export function useActionMapTilesAbility() {
  const playerPositionMapTile = useAtomValue(playerPositionMapTileAtom)
  const clickedTile = useAtomValue(clickedTileAtom)
  const [startingPoint, setStartingPoint] = useState<TPlayerVisibleMapData>()
  const [endingPoint, setEndingPoint] = useState<TJoinedMapTile | undefined>()
  const { selectedAbilityId, handleUsePlayerAbility, handleCancelPlayerAbility } = usePlayerAbility()
  const { abilityRequirements } = usePlayerAbilityRequirements()
  const { pathFromPointToPoint } = useMapTilesPath()
  const { mutateActionTaskInProcess } = useActionTaskInProcess()
  const [mapTilesMovementPath, setMapTilesMovementPath] = useAtom(mapTilesMovementPathAtom)

  useEffect(() => {
    if (playerPositionMapTile) {
      const mapTilesMovementPath = pathFromPointToPoint(
        playerPositionMapTile.map_tile_x ?? 0,
        playerPositionMapTile.map_tile_y ?? 0,
        clickedTile?.mapTile.x ?? playerPositionMapTile.map_tile_x,
        clickedTile?.mapTile.y ?? playerPositionMapTile.map_tile_y,
        0,
      )

      setMapTilesMovementPath(mapTilesMovementPath)
      setStartingPoint(playerPositionMapTile)
      setEndingPoint(clickedTile)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  const handleButtonUseAbility = () => {
    if (clickedTile) {
      handleUsePlayerAbility(selectedAbilityId, clickedTile)
      mutateActionTaskInProcess(mapTilesMovementPath)
      playerMovementAction(mapTilesMovementPath)
    }
  }

  const handleButtonCancel = () => {
    handleCancelPlayerAbility()
  }

  return {
    startingPoint,
    endingPoint,
    abilityRequirements,
    handleButtonUseAbility,
    handleButtonCancel,
  }
}
