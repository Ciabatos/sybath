"use server"
import MapWrapper from "@/components/MapWrapper"
import { 
  getJoinedMapTiles,
  getTerrainTypeDictionary,
  type TJoinedMapTile
} from "@/services/mapDataService"

export default async function MapTilesServer() {
  const [joinedMapTiles, terrainTypes] = await Promise.all([
    getJoinedMapTiles(),
    getTerrainTypeDictionary()
  ])

  return (
    <MapWrapper
      joinedMapTiles={joinedMapTiles}
      mapTerrainTypesById={terrainTypes}
    />
  )
}
