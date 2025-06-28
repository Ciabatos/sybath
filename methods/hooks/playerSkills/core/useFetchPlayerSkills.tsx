"use client"
import { playerSkillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerSkills() {
  const session = useSession()
  const playerId = session?.data?.user.playerId

  const setPlayerSkills = useSetAtom(playerSkillsAtom)
  const playerSkills = useAtomValue(playerSkillsAtom)
  const { data } = useSWR(`/api/players/${playerId}/skills`)

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setPlayerSkills(data)
      prevDataRef.current = data
    }
  }, [data])

  return { playerSkills }
}
