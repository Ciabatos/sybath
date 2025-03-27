"use server"
import { auth } from "@/auth"
import MapWrapper from "@/components/MapWrapper"
import { getPlayerVisibleMapData, TPlayerVisibleMapDataById } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import { getMapLandscapeTypes, TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { getMapTerrainTypes, TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { getPlayerInventory } from "@/db/postgresMainDatabase/schemas/players/tables/playerInventories"
import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { joinMapTiles } from "@/methods/functions/joinMapTiles"
import { SWRProvider } from "@/providers/swr-provider"
import styles from "./page.module.css"

export default async function MapPage() {
  const session = await auth()
  const playerId = session?.user?.playerId

  const [mapTerrainTypes, mapTiles, mapLandscapeTypes, mapPlayerVisibleMapData, playerInventory] = await Promise.all([
    getMapTerrainTypes(),
    getMapTiles(),
    getMapLandscapeTypes(),
    getPlayerVisibleMapData(playerId),
    getPlayerInventory(playerId),
  ])

  const terrainTypes = arrayToObjectKeyId("terrain_type_id", mapTerrainTypes) as TMapTerrainTypesById

  const landscapeTypes = arrayToObjectKeyId("landscape_type_id", mapLandscapeTypes) as TMapLandscapeTypesById

  const playerVisibleMapData = mapPlayerVisibleMapData ? (arrayToObjectKeyId("map_tile_id", mapPlayerVisibleMapData) as TPlayerVisibleMapDataById) : {}

  const joinedMapTiles = joinMapTiles(mapTiles, {
    terrainTypes,
    landscapeTypes,
    playerVisibleMapData,
  })

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: {
            "/api/map-tiles": mapTiles,
            ...(playerId && { [`/api/map-tiles/player-visible-map-data/${playerId}`]: mapPlayerVisibleMapData }),
            ...(playerId && { [`/api/player-inventories/${playerId}`]: playerInventory }),
          },
        }}>
        <MapWrapper
          terrainTypes={terrainTypes}
          landscapeTypes={landscapeTypes}
          joinedMapTiles={joinedMapTiles}
        />
      </SWRProvider>
    </div>
  )
}
