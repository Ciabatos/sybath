import { TPlayerAbilitiesRecordByAbilityId } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { atom } from "jotai"

export const playerAbilitiesAtom = atom<TPlayerAbilitiesRecordByAbilityId>({})
