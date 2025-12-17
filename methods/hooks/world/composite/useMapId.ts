import { mapIdAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"

export function useMapId() {
  const mapId = useAtomValue(mapIdAtom)
  const setMapId = useSetAtom(mapIdAtom)

  return { mapId, setMapId }
}
