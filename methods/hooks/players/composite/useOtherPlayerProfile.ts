"use client"

import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import {
  useFetchOtherPlayerProfile,
  useOtherPlayerProfileState,
} from "@/methods/hooks/players/core/useFetchOtherPlayerProfile"

export function useOtherPlayerProfile() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  useFetchOtherPlayerProfile({ playerId, otherPlayerId })
  const otherPlayerProfileData = useOtherPlayerProfileState()

  const [otherPlayerProfile] = Object.values(otherPlayerProfileData)

  return { otherPlayerProfile }
}
