import { TKnownMapTilesResourcesOnMap } from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnMap"

type TProps = {
  knownMapTilesResourcesOnMap?: TKnownMapTilesResourcesOnMap
}

export default function ResourcesLayer({ knownMapTilesResourcesOnMap }: TProps) {
  if (!knownMapTilesResourcesOnMap) return null

  return (
    <div>
      {knownMapTilesResourcesOnMap.itemIds.map((item) => (
        <div key={item.itemId}>{item.itemId}</div>
      ))}
    </div>
  )
}
