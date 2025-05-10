import { useFetchInventorySlots } from "@/methods/hooks/playerInventory/useFetchInventorySlots"
import { inventorySlotsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useInventorySlots() {
  useFetchInventorySlots()
  const inventorySlots = useAtomValue(inventorySlotsAtom)

  return { inventorySlots }
}
