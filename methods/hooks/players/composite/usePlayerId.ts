"use client"
import { doSwitchActivePlayerAction } from "@/methods/actions/players/doSwitchActivePlayerAction"
import { useFetchActivePlayer } from "@/methods/hooks/players/core/useFetchActivePlayer"
import { useMutateActivePlayer } from "@/methods/hooks/players/core/useMutateActivePlayer"

export function usePlayerId() {
  const { mutateActivePlayer } = useMutateActivePlayer()
  const { activePlayer } = useFetchActivePlayer()
  const currentPlayer = Object.values(activePlayer)[0]
  const playerId = currentPlayer?.id ?? null

  function switchPlayer(newPlayerId: number) {
    doSwitchActivePlayerAction({ playerId: playerId, switchToPlayerId: newPlayerId })
    mutateActivePlayer({ id: newPlayerId })
  }

  return { playerId, switchPlayer }
}
