import { TKnownMapTilesResourcesOnMap } from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnMap"

type TProps = {
  knownMapTilesResourcesOnMap?: TKnownMapTilesResourcesOnMap
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
      {knownMapTilesResourcesOnMap.itemIds.map((item) => (
        <div
          key={item.itemId}
          style={{
            position: "relative",
            zIndex: 20,
          }}
        >
          {item.itemId} RESOURCE
        </div>
      ))}
    </div>
  )
}
