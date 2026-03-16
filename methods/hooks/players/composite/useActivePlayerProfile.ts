"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import {
  useActivePlayerProfileState,
  useFetchActivePlayerProfile,
} from "@/methods/hooks/players/core/useFetchActivePlayerProfile"

export function useActivePlayerProfile() {
  const { playerId } = usePlayerId()

  useFetchActivePlayerProfile({ playerId })
  const activePlayerProfileData = useActivePlayerProfileState()

  const [activePlayerProfile] = Object.values(activePlayerProfileData)

  return { activePlayerProfile }
}
