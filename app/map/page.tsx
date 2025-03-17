"use server"
import { auth } from "@/auth"
import MapWrapper from "@/components/MapWrapper"
import { getMapLandscapeTypes, TMapLandscapeTypes } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { getMapTerrainTypes, TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { getMapsTilesPlayerPosition, TMapsFieldsPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapTilesPlayerPosition"
import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { joinMapTiles } from "@/methods/functions/joinMapTiles"
import { SWRProvider } from "@/providers/swr-provider"
import styles from "./page.module.css"

export default async function MapPage() {
  const session = await auth()
  console.log(session, "Server session")

  const [mapTerrainTypes, mapTiles, mapLandscapeTypes, mapTilesPlayerPostion] = await Promise.all([getMapTerrainTypes(), getMapTiles(), getMapLandscapeTypes(), getMapsTilesPlayerPosition()])

  const terrainTypes = arrayToObjectKeyId("id", mapTerrainTypes) as Record<number, TMapTerrainTypes>

  const landscapeTypes = arrayToObjectKeyId("id", mapLandscapeTypes) as Record<number, TMapLandscapeTypes>

  const mapTilesPlayerPosition = mapTilesPlayerPostion ? (arrayToObjectKeyId("map_field_id", mapTilesPlayerPostion) as Record<number, TMapsFieldsPlayerPosition>) : {}

  const joinedMapTiles = joinMapTiles(mapTiles, {
    terrainTypes,
    landscapeTypes,
    mapTilesPlayerPosition,
  })

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: {
            "/api/map-tiles": mapTiles,
            "/api/map-tiles-player-position": mapTilesPlayerPostion,
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
