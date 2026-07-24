import { TPlayerSkillsRecordBySkillId } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { atom } from "jotai"

export const playerSkillsAtom = atom<TPlayerSkillsRecordBySkillId>({})
