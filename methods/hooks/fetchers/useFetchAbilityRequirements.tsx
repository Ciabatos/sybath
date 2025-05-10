"use client"

import { abilityRequirementsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchAbilityRequirements(abilityId: number | undefined) {
  const setAbilityRequirementsAtom = useSetAtom(abilityRequirementsAtom)

  const shouldFetch = abilityId
  const { data, error, isLoading } = useSWR(shouldFetch ? `/api/abilities/${abilityId}/requirments` : null)

  useEffect(() => {
    if (data) {
      setAbilityRequirementsAtom(data)
    }
  }, [data, error, isLoading])
}
