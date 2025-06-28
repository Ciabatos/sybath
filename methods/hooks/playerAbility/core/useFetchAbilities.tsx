"use client"
import { abilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchAbilities() {
  const abilities = useAtomValue(abilitiesAtom)
  const setAbilities = useSetAtom(abilitiesAtom)
  const { data } = useSWR(`/api/abilities`)
  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setAbilities(data)
      prevDataRef.current = data
    }
  }, [data])

  return { abilities }
}
