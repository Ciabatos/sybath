import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchPlayersOnTile, usePlayersOnTileState } from "@/methods/hooks/world/core/useFetchPlayersOnTile"

export default function usePlayersOnTile(mapTileX: number, mapTileY: number) {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchPlayersOnTile({ mapId, mapTileX, mapTileY, playerId })
  const playersOnTile = usePlayersOnTileState()

  return { playersOnTile }
}
