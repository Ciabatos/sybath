import { TAllAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/allAbilities"
import { atom } from "jotai"

export const allAbilitiesAtom = atom<TAllAbilitiesRecordById>({})
