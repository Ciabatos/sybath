"use client"

import { abilityRequirementsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchAbilityRequirements(abilityId: number | undefined) {
  const abilityRequirements = useAtomValue(abilityRequirementsAtom)
  const setAbilityRequirementsAtom = useSetAtom(abilityRequirementsAtom)

  const shouldFetch = abilityId
  const { data } = useSWR(shouldFetch ? `/api/abilities/${abilityId}/requirments` : null)

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setAbilityRequirementsAtom(data)
      prevDataRef.current = data
    }
  }, [data])

  return { abilityRequirements }
}
