"use client"

import { useFetchAttributesAbilities } from "@/methods/hooks/attributes/core/useFetchAttributesAbilities"
import { useAttributesAbilitiesState } from "@/methods/hooks/attributes/core/useFetchAttributesAbilitiesByKey"

export function useAllAbilities() {
  useFetchAttributesAbilities()
  const abilities = useAttributesAbilitiesState()

  return { abilities }
}
