"use client"

import { doMapTileExplorationAction } from "@/methods/actions/world/doMapTileExplorationAction"
import { usePlayerAbilities } from "@/methods/hooks/attributes/composite/usePlayerAbilities"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useFetchPlayerPosition, usePlayerPositionState } from "@/methods/hooks/world/core/useFetchPlayerPosition"
import { useMutateKnownMapTilesResourcesOnTile } from "@/methods/hooks/world/core/useMutateKnownMapTilesResourcesOnTile"
import { useState } from "react"
import { toast } from "sonner"

export function usePlayerExploration() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()
  const { clickedMapTile } = useMapTileActions()
  const { selectPlayerPathToClickedTile, selectPlayerPathAndMovePlayerToClickedTile, closeMovementPanel } =
    usePlayerMovement()
  const { playerAbilities } = usePlayerAbilities()
  useFetchPlayerPosition({ mapId, playerId })
  const playerPosition = usePlayerPositionState()
  const [isExploring, setIsExploring] = useState(false)

  const { mutateKnownMapTilesResourcesOnTile } = useMutateKnownMapTilesResourcesOnTile({
    mapId,
    mapTileX: clickedMapTile!.mapTiles.x,
    mapTileY: clickedMapTile!.mapTiles.y,
    playerId,
  })

  async function exploreClickedTilePlan() {
    if (!clickedMapTile) return toast.error("No tile selected")

    try {
      if (!playerAbilities[2]?.value) {
        return toast.error("Player does not have exploration ability")
      }

      if (!playerPosition[`${clickedMapTile.mapTiles.x},${clickedMapTile.mapTiles.y}`]) {
        const resultMovement = await selectPlayerPathToClickedTile()

        if (!resultMovement) {
          return toast.error("Failed to move to the tile, cannot explore")
        }
      }
      setIsExploring(true)
    } catch (error) {
      console.error("Error exploring tile:", error)
    }
  }

  async function exploreClickedTileConfirm() {
    if (!clickedMapTile) return toast.error("No tile selected")

    try {
      if (!playerAbilities[2]?.value) {
        return toast.error("Player does not have exploration ability")
      }

      if (!playerPosition[`${clickedMapTile.mapTiles.x},${clickedMapTile.mapTiles.y}`]) {
        const resultMovement = await selectPlayerPathAndMovePlayerToClickedTile()

        if (!resultMovement) {
          return toast.error("Failed to move to the tile, cannot explore")
        }
      }

      const result = await doMapTileExplorationAction({
        playerId,
        mapId: mapId,
        targetTileX: clickedMapTile.mapTiles.x,
        targetTileY: clickedMapTile.mapTiles.y,
      })

      if (!result.status) {
        return toast.error(result.message)
      }

      mutateKnownMapTilesResourcesOnTile()
      setIsExploring(false)

      toast.success(`You are exploring destination tile`)
    } catch (error) {
      console.error("Error exploring tile:", error)
    }
  }

  function closeExplorationPanel() {
    closeMovementPanel()
    setIsExploring(false)
  }

  return { isExploring, exploreClickedTilePlan, exploreClickedTileConfirm, closeExplorationPanel }
}
