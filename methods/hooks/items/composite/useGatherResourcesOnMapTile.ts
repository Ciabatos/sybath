import { doGatherResourcesOnMapTileAction } from "@/methods/actions/items/doGatherResourcesOnMapTileAction"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { TMapTileResource } from "@/methods/hooks/world/composite/useMapTileDetail"
import { toast } from "sonner"

type TGatherResourcesOnMapTileParams = {
  resource: TMapTileResource | null
  gatherAmount: number
}

export function useGatherResourcesOnMapTile(params: TGatherResourcesOnMapTileParams) {
  const { playerId } = usePlayerId()
  const { clickedMapTile } = useMapTileActions()
  const { selectPlayerPathAndMovePlayerToClickedTile } = usePlayerMovement()

  async function gatherClickedResource() {
    if (!clickedMapTile) return toast.error("No tile selected")

    try {
      const resultMovement = await selectPlayerPathAndMovePlayerToClickedTile()

      if (!resultMovement) {
        return toast.error("Failed to move to the tile, cannot gather resources")
      }

      const result = await doGatherResourcesOnMapTileAction({
        playerId,
        targetTileX: clickedMapTile.mapTiles.x,
        targetTileY: clickedMapTile.mapTiles.y,
        mapTilesResourceId: params.resource?.mapTilesResourceId || 0,
        gatherAmount: params.gatherAmount,
      })

      if (!result.status) {
        return toast.error(result.message)
      }

      toast.success(`You are gathering ${params.gatherAmount}x ${params.resource?.name || "resource"}`)
    } catch (error) {
      console.error("Error gathering resources:", error)
    }
  }

  return { gatherClickedResource }
}
