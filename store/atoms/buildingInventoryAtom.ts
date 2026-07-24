import { TBuildingInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import { atom } from "jotai"

export const buildingInventoryAtom = atom<TBuildingInventoryRecordBySlotId>({})
