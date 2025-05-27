import { useFetchDistrictInventorySlots } from "@/methods/hooks/districtInventory/useFetchDistrictInventorySlots"
import { districtInventorySlotsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useDistrictInventorySlots(districtId: number | undefined) {
  useFetchDistrictInventorySlots(districtId)
  const districtInventorySlots = useAtomValue(districtInventorySlotsAtom)

  return { districtInventorySlots }
}
