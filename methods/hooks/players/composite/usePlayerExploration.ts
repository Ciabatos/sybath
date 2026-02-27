"use client"

import { doMapTileExplorationAction } from "@/methods/actions/world/doMapTileExplorationAction"
import { usePlayerAbilities } from "@/methods/hooks/attributes/composite/usePlayerAbilities"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { toast } from "sonner"

export function usePlayerExploration() {
  const { playerId } = usePlayerId()
  const { clickedMapTile } = useMapTileActions()
  const { selectPlayerPathAndMovePlayerToClickedTile } = usePlayerMovement()
  const { playerAbilities } = usePlayerAbilities()

  async function exploreClickedTile() {
    if (!clickedMapTile) return toast.error("No tile selected")

    try {
      if (!playerAbilities[2]?.value) {
        return toast.error("Player does not have exploration ability")
      }

      const resultMovement = await selectPlayerPathAndMovePlayerToClickedTile()

      if (!resultMovement) {
        return toast.error("Failed to move to the tile, cannot explore")
      }

      const result = await doMapTileExplorationAction({
        playerId,
        targetTileX: clickedMapTile.mapTiles.x,
        targetTileY: clickedMapTile.mapTiles.y,
      })

      if (!result.status) {
        return toast.error(result.message)
      }

      toast.success(`You are exploring destination tile`)
    } catch (error) {
      console.error("Error exploring tile:", error)
    }
  }

  return { exploreClickedTile }
}
