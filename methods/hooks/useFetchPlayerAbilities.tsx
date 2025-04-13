"use client"
import { playerAbilitiesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerAbilities() {
  const session = useSession()
  const playerId = session?.data?.user.playerId

  const setPlayerAbilities = useSetAtom(playerAbilitiesAtom)
  const { data, error, isLoading } = useSWR(`/api/player-abilities/${playerId}`)

  useEffect(() => {
    console.log("useFetchPlayerAbilities", { data, error, isLoading })
    setPlayerAbilities(data)
  }, [data, error, isLoading])
}
