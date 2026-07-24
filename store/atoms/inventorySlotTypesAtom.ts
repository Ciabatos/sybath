import { TInventoryInventorySlotTypesRecordById } from "@/db/postgresMainDatabase/schemas/inventory/inventorySlotTypes"
import { atom } from "jotai"

export const inventorySlotTypesAtom = atom<TInventoryInventorySlotTypesRecordById>({})
