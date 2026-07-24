import { TPlayerGearInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/playerGearInventory"
import { atom } from "jotai"

export const playerGearInventoryAtom = atom<TPlayerGearInventoryRecordBySlotId>({})
