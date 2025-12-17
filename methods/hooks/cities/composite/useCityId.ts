import { cityIdAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"

export function useCityId() {
  const cityId = useAtomValue(cityIdAtom)
  const setCityId = useSetAtom(cityIdAtom)

  return { cityId, setCityId }
}
