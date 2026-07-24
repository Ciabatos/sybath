import { TOtherPlayerInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerInventory"
import { atom } from "jotai"

export const otherPlayerInventoryAtom = atom<TOtherPlayerInventoryRecordBySlotId>({})
