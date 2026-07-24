import { TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"
import { atom } from "jotai"

export const itemsAtom = atom<TItemsItemsRecordById>({})
