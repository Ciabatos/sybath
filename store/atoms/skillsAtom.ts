import { TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { atom } from "jotai"

export const skillsAtom = atom<TAttributesSkillsRecordById>({})
