import { TItemsRecipeMaterialsRecordById } from "@/db/postgresMainDatabase/schemas/items/recipeMaterials"
import { atom } from "jotai"

export const recipeMaterialsAtom = atom<TItemsRecipeMaterialsRecordById>({})
