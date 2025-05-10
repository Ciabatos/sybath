import { useFetchPlayerSkills } from "@/methods/hooks/playerSkills/useFetchPlayerSkills"
import { playerSkillsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerSkills() {
  useFetchPlayerSkills()
  const playerSkills = useAtomValue(playerSkillsAtom)
  return { playerSkills }
}
