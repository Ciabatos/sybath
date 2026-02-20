"use client"

import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchOtherPlayerProfile } from "@/methods/hooks/players/core/useFetchOtherPlayerProfile"
import { otherPlayerProfileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useOtherPlayerProfile() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  useFetchOtherPlayerProfile({ playerId, otherPlayerMaskId: otherPlayerId })
  const otherPlayerProfileData = useAtomValue(otherPlayerProfileAtom)

  const [otherPlayerProfile] = Object.values(otherPlayerProfileData)

  return { otherPlayerProfile }
}
