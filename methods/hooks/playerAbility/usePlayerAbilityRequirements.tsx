import { useFetchAbilityRequirements } from "@/methods/hooks/playerAbility/useFetchAbilityRequirements"
import { abilityRequirementsAtom, selectedAbilityIdAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerAbilityRequirements() {
  const selectedAbilityId = useAtomValue(selectedAbilityIdAtom)

  useFetchAbilityRequirements(selectedAbilityId)
  const abilityRequirements = useAtomValue(abilityRequirementsAtom)

  return { abilityRequirements }
}
