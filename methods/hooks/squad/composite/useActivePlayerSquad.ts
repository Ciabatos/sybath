"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchActivePlayerSquad } from "@/methods/hooks/squad/core/useFetchActivePlayerSquad"
import { activePlayerSquadAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useActivePlayerSquad() {
  const { playerId } = usePlayerId()

  useFetchActivePlayerSquad({ playerId })
  const activePlayerSquadData = useAtomValue(activePlayerSquadAtom)

  const [activePlayerSquad] = Object.values(activePlayerSquadData)

  return { activePlayerSquad }
}
