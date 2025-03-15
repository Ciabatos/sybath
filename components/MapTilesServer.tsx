"use server"
import MapWrapper from "@/components/MapWrapper"
import { mapTilesServerData } from "@/methods/services/map/mapTilesServerData"

export default async function MapTilesServer() {
  const { joinedMapTiles, terrainTypesById, landscapeTypesById } = await mapTilesServerData()

  return (
    <MapWrapper
      joinedMapTiles={joinedMapTiles}
      terrainTypesById={terrainTypesById}
      landscapeTypesById={landscapeTypesById}
    />
  )
}
