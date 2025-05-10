import { useFetchAbilityRequirements } from "@/methods/hooks/fetchers/useFetchAbilityRequirements"
import { abilityRequirementsAtom, selectedAbilityIdAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerAbilityRequirements() {
  const selectedAbilityId = useAtomValue(selectedAbilityIdAtom)

  useFetchAbilityRequirements(selectedAbilityId)
  const abilityRequirements = useAtomValue(abilityRequirementsAtom)

  return { abilityRequirements }
}
