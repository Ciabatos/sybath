"use client"
import { abilitiesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchAbilities() {
  const setAbilities = useSetAtom(abilitiesAtom)
  const { data, error, isLoading } = useSWR(`/api/abilities`)

  useEffect(() => {
    console.log("useFetchAbilities", { data, error, isLoading })
    setAbilities(data)
  }, [data, error, isLoading])
}
