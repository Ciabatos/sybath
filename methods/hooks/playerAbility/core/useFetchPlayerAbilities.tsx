"use client"
import { playerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerAbilities() {
  const session = useSession()
  const playerId = session?.data?.user.playerId

  const setPlayerAbilities = useSetAtom(playerAbilitiesAtom)
  const playerAbilities = useAtomValue(playerAbilitiesAtom)
  const { data } = useSWR(`/api/players/${playerId}/abilities`)

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setPlayerAbilities(data)
      prevDataRef.current = data
    }
  }, [data])

  return { playerAbilities }
}
