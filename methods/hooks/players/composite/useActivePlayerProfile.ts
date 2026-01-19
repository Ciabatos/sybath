"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchActivePlayerProfile } from "@/methods/hooks/players/core/useFetchActivePlayerProfile"
import { activePlayerProfileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useActivePlayerProfile() {
  const { playerId } = usePlayerId()

  useFetchActivePlayerProfile({ playerId })
  const activePlayerProfileData = useAtomValue(activePlayerProfileAtom)

  const activePlayerProfile = Object.values(activePlayerProfileData)[0] ?? null

  return { activePlayerProfile }
}
