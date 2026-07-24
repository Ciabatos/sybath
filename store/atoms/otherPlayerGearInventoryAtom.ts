import { TOtherPlayerGearInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerGearInventory"
import { atom } from "jotai"

export const otherPlayerGearInventoryAtom = atom<TOtherPlayerGearInventoryRecordBySlotId>({})
