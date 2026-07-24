import { TOtherPlayerSkillsRecordBySkillId } from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerSkills"
import { atom } from "jotai"

export const otherPlayerSkillsAtom = atom<TOtherPlayerSkillsRecordBySkillId>({})
