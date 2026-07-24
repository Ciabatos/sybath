import { TAllSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/allSkills"
import { atom } from "jotai"

export const allSkillsAtom = atom<TAllSkillsRecordById>({})
