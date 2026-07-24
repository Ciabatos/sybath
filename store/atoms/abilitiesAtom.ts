

import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { atom } from "jotai"

export const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})
