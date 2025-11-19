import { useFetchAbilityRequirements } from "@/methods/hooks/playerAbility/core/useFetchAbilityRequirements"
import { usePlayerAbility } from "@/methods/hooks/players/composite/usePlayerAbility"

export function usePlayerAbilityRequirements() {
  const { selectedAbilityId } = usePlayerAbility()
  const { abilityRequirements } = useFetchAbilityRequirements(selectedAbilityId)

  return { abilityRequirements }
}
