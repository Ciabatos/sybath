import { usePlayerAbility } from "@/methods/hooks/playerAbility/composite/usePlayerAbility"
import { useFetchAbilityRequirements } from "@/methods/hooks/playerAbility/core/useFetchAbilityRequirements"

export function usePlayerAbilityRequirements() {
  const { selectedAbilityId } = usePlayerAbility()
  const { abilityRequirements } = useFetchAbilityRequirements(selectedAbilityId)

  return { abilityRequirements }
}
