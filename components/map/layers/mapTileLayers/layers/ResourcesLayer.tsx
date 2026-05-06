import { TCombinedResourcesOnMap } from "@/methods/hooks/world/composite/useResourcesLayer"

type TProps = {
  knownMapTilesResourcesOnMap?: TCombinedResourcesOnMap
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
        zIndex: 999999999, // 👈 warstwa nad tile
        pointerEvents: "none", // 👈 żeby klik przechodził do MapTile
      }}
    >
      <div>
        {Object.values(knownMapTilesResourcesOnMap).map((tile) =>
          tile.itemIds.map((resource) => {
            return (
              <div
                key={resource.itemId}
                style={{ position: "relative", zIndex: 99999 }}
              >
                res_{resource.itemId}
              </div>
            )
          }),
        )}
      </div>
    </div>
  )
}
