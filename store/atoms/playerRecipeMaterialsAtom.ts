import { TPlayerRecipeMaterialsRecordById } from "@/db/postgresMainDatabase/schemas/items/playerRecipeMaterials"
import { atom } from "jotai"

export const playerRecipeMaterialsAtom = atom<TPlayerRecipeMaterialsRecordById>({})
