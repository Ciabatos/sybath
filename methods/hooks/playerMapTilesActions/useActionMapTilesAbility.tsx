"use client"

import { useMapTilesPath } from "@/methods/hooks/mapTiles/useMapTilesPath"
import { usePlayerAbility } from "@/methods/hooks/playerAbility/usePlayerAbility"
import { usePlayerAbilityRequirements } from "@/methods/hooks/playerAbility/usePlayerAbilityRequirements"
import { clickedTileAtom, mapTilesMovmentPathAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useState } from "react"

export function useActionMapTilesAbility() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const [startingPoint] = useState(clickedTile)
  const { pathFromPointToPoint } = useMapTilesPath()
  const setMapTilesMovmentPath = useSetAtom(mapTilesMovmentPathAtom)
  const { selectedAbilityId, handleUsePlayerAbility, handleCancelPlayerAbility } = usePlayerAbility()
  const { abilityRequirements } = usePlayerAbilityRequirements()

  useEffect(() => {
    if (startingPoint && clickedTile) {
      const movmentPath = pathFromPointToPoint(startingPoint.x, startingPoint.y, clickedTile.x, clickedTile.y, 0)
      setMapTilesMovmentPath(movmentPath)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  const handleButtonUseAbility = () => {
    handleUsePlayerAbility(selectedAbilityId, clickedTile)
  }

  const handleButtonCancel = () => {
    handleCancelPlayerAbility()
  }

  return {
    startingPoint,
    endingPoint: clickedTile,
    abilityRequirements,
    handleButtonUseAbility,
    handleButtonCancel,
  }
}
