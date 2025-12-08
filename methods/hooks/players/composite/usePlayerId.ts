// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { playerIdAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect } from "react"

export function usePlayerId() {
  const playerId = useAtomValue(playerIdAtom)
  const setPlayerId = useSetAtom(playerIdAtom)

  const session = useSession()
  const playerId = session.data?.user.playerId
  const sessionPlayerIds = session.data?.user.playerIds

  useEffect(() => {
    if (playerId && playerId !== playerId) {
      setPlayerId(playerId)
    }
  }, [playerId, playerId, setPlayerId])

  const switchPlayer = (newPlayerId: number) => {
    if (!sessionPlayerIds?.includes(newPlayerId)) return
    setPlayerId(newPlayerId)
  }

  return { playerId, switchPlayer }
}
