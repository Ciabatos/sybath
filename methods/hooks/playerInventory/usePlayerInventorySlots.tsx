import { useFetchPlayerInventorySlots } from "@/methods/hooks/playerInventory/useFetchPlayerInventorySlots"
import { playerInventorySlotsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerInventorySlots() {
  useFetchPlayerInventorySlots()
  const playerInventorySlots = useAtomValue(playerInventorySlotsAtom)

  return { playerInventorySlots }
}
