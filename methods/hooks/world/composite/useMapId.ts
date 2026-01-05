import { useFetchWorldMaps } from "@/methods/hooks/world/core/useFetchWorldMaps"

export function useMapId() {
  const { maps } = useFetchWorldMaps()

  const mapId = maps[1]?.id

  return { mapId }
}
