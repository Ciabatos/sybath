import { TCombinedResourcesOnMap } from "@/methods/hooks/world/composite/useResourcesLayer"

type TProps = {
  knownMapTilesResourcesOnMap?: TCombinedResourcesOnMap[string]
}

export default function ResourcesLayer({ knownMapTilesResourcesOnMap }: TProps) {
  if (!knownMapTilesResourcesOnMap) return null

  return (
    <div
      style={{
        position: "absolute",
        top: 0,
        left: 0,
        width: "100%",
        height: "100%",
        zIndex: 999999999,
        pointerEvents: "none",
      }}
    >
      <div>
        {knownMapTilesResourcesOnMap.itemIds.map((resource) => (
          <div
            key={resource.itemId}
            style={{ position: "relative", zIndex: 99999 }}
          >
            res_{resource.itemId}
          </div>
        ))}
      </div>
    </div>
  )
}
