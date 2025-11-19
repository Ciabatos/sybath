// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { playerIdAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useSession } from "next-auth/react"

export function useFetchPlayerId() {
  const playerId = useAtomValue(playerIdAtom)
  const setPlayerId = useSetAtom(playerIdAtom)

  const session = useSession()
  const sessionPlayerId = session.data?.user.playerId

  if (sessionPlayerId) {
    setPlayerId(sessionPlayerId)
  }

  return { playerId }
}
