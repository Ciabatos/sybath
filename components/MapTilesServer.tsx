"use server"
import MapWrapper from "@/components/MapWrapper"
import { getTerrainTypesById, getJoinedMapTiles } from "@/functions/services/map/mapTilesServerData"

export default async function MapTilesServer() {
  const [terrainTypesById, joinedMapTiles] = await Promise.all([getTerrainTypesById(), getJoinedMapTiles()])
  return (
    <MapWrapper
      joinedMapTiles={joinedMapTiles}
      terrainTypesById={terrainTypesById}
    />
  )
}
