import { useFetchBuildingInventorySlots } from "@/methods/hooks/buildingInventory/useFetchBuildingInventorySlots"
import { buildingInventorySlotsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useBuildingInventorySlots(buildingId: number | undefined) {
  useFetchBuildingInventorySlots(buildingId)
  const buildingInventorySlots = useAtomValue(buildingInventorySlotsAtom)

  return { buildingInventorySlots }
}
