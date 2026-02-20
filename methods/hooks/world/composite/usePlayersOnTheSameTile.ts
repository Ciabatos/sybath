import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchPlayersOnTheSameTile } from "@/methods/hooks/world/core/useFetchPlayersOnTheSameTile"
import { playersOnTheSameTileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export default function usePlayersOnTheSameTile() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchPlayersOnTheSameTile({ mapId, playerId })
  const playersOnTheSameTile = useAtomValue(playersOnTheSameTileAtom)

  return playersOnTheSameTile
}
