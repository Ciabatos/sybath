"use client"
import { activePlayerAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerId() {
  const activePlayer = useAtomValue(activePlayerAtom)

  const playerId = Object.values(activePlayer)[0]?.id ?? null

  return { playerId }
}
