"use client"
import { doSwitchActivePlayerAction } from "@/methods/actions/players/doSwitchActivePlayerAction"
import { useFetchActivePlayer } from "@/methods/hooks/players/core/useFetchActivePlayer"
import { useMutateActivePlayer } from "@/methods/hooks/players/core/useMutateActivePlayer"
import { activePlayerAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerId() {
  const { mutateActivePlayer } = useMutateActivePlayer()

  useFetchActivePlayer()
  const activePlayerData = useAtomValue(activePlayerAtom)

  const activePlayer = Object.values(activePlayerData)[0] ?? null
  const playerId = activePlayer?.id

  function switchPlayer(newPlayerId: number) {
    doSwitchActivePlayerAction({ playerId: playerId, switchToPlayerId: newPlayerId })
    mutateActivePlayer({ id: newPlayerId })
  }

  return { playerId, switchPlayer }
}
