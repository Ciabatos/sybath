import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchPlayersOnTile } from "@/methods/hooks/world/core/useFetchPlayersOnTile"
import { playersOnTileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export default function usePlayersOnTile(mapTileX: number, mapTileY: number) {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchPlayersOnTile({ mapId, mapTileX, mapTileY, playerId })
  const playersOnTile = useAtomValue(playersOnTileAtom)

  return { playersOnTile }
}
