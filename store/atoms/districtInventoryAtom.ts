import { TDistrictInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"
import { atom } from "jotai"

export const districtInventoryAtom = atom<TDistrictInventoryRecordBySlotId>({})
