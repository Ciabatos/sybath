"use client"

import { useFetchActivePlayer } from "@/methods/hooks/players/core/useFetchActivePlayer"
import { activePlayerAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useActivePlayer() {
  useFetchActivePlayer()
  const activePlayerData = useAtomValue(activePlayerAtom)
  const activePlayer = Object.values(activePlayerData)[0] ?? null

  return { activePlayer }
}
