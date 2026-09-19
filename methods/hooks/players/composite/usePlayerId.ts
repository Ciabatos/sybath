"use client"
import { activePlayerAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerId() {
  const activePlayer = useAtomValue(activePlayerAtom)

  const playerId = activePlayer
  console.log("activePlayer", activePlayer)
  return { playerId }
}
