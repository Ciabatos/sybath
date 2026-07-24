import { TOtherPlayerAbilitiesRecordByAbilityId } from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerAbilities"
import { atom } from "jotai"

export const otherPlayerAbilitiesAtom = atom<TOtherPlayerAbilitiesRecordByAbilityId>({})
