"use client"
import { playerSkillsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerSkills() {
  const session = useSession()
  const playerId = session?.data?.user.playerId

  const setPlayerSkills = useSetAtom(playerSkillsAtom)
  const { data, error, isLoading } = useSWR(`/api/players/${playerId}/skills`)

  useEffect(() => {
    console.log("useFetchPlayerSkills", { data, error, isLoading })
    setPlayerSkills(data)
  }, [data, error, isLoading])
}
