"use client"

import { useMapTilesPath } from "@/methods/hooks/mapTiles/useMapTilesPath"
import { usePlayerAbility } from "@/methods/hooks/playerAbility/usePlayerAbility"
import { usePlayerAbilityRequirements } from "@/methods/hooks/playerAbility/usePlayerAbilityRequirements"
import { clickedTileAtom, mapTilesMovmentPathAtom, playerPositionMapTileAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useState } from "react"

export function useActionMapTilesAbility() {
  const [startingPoint, setStartingPoint] = useState({ x: 0, y: 0 })
  const [endingPoint, setEndingPoint] = useState({ x: 0, y: 0 })
  const clickedTile = useAtomValue(clickedTileAtom)
  const playerPositionMapTile = useAtomValue(playerPositionMapTileAtom)
  const { pathFromPointToPoint } = useMapTilesPath()
  const setMapTilesMovmentPath = useSetAtom(mapTilesMovmentPathAtom)
  const { selectedAbilityId, handleUsePlayerAbility, handleCancelPlayerAbility } = usePlayerAbility()
  const { abilityRequirements } = usePlayerAbilityRequirements()

  useEffect(() => {
    const targetTile = clickedTile || playerPositionMapTile
    const movmentPath = pathFromPointToPoint(playerPositionMapTile.x, playerPositionMapTile.y, targetTile.x, targetTile.y, 0)

    setMapTilesMovmentPath(movmentPath)
    setStartingPoint({ x: playerPositionMapTile.x, y: playerPositionMapTile.y })
    setEndingPoint({ x: targetTile.x, y: targetTile.y })

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  const handleButtonUseAbility = () => {
    if (clickedTile) {
      handleUsePlayerAbility(selectedAbilityId, clickedTile)
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
