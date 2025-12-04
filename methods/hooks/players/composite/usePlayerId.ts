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
  const sessionPlayerId = session.data?.user.playerId
  const sessionPlayerIds = session.data?.user.playerIds

  useEffect(() => {
    if (sessionPlayerId && sessionPlayerId !== playerId) {
      setPlayerId(sessionPlayerId)
    }
  }, [sessionPlayerId, playerId, setPlayerId])

  const switchPlayer = (newPlayerId: number) => {
    if (!sessionPlayerIds?.includes(newPlayerId)) return
    setPlayerId(newPlayerId)
  }

  return { playerId, switchPlayer }
}
