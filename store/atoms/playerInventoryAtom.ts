import { TPlayerInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { atom } from "jotai"

export const playerInventoryAtom = atom<TPlayerInventoryRecordBySlotId>({})
