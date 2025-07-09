"use server"
import { auth } from "@/auth"

import MapTilesWrapper from "@/components/map/MapTilesWrapper"
import { getAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { getSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { getPlayerInventorySlots } from "@/db/postgresMainDatabase/schemas/items/inventories"
import { getMapCities, TCitiesByCoordinates } from "@/db/postgresMainDatabase/schemas/map/cities"
import { getMapDistricts, TDistrictsByCoordinates } from "@/db/postgresMainDatabase/schemas/map/districts"
import { getMapLandscapeTypes, TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/mapTiles"
import { getPlayerVisibleMapData, TPlayerVisibleMapDataByCoordinates } from "@/db/postgresMainDatabase/schemas/map/playerVisibleMapData"
import { getMapTerrainTypes, TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/playerAbilities"
import { getPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/playerSkills"
import { arrayToObjectKeyId, arrayToObjectKeysId } from "@/methods/functions/converters"
import { joinMapTiles } from "@/methods/functions/joinMapTiles"
import { SWRProvider } from "@/providers/swr-provider"
import styles from "./page.module.css"

export default async function MapPage() {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return null
  }

  const [mapTerrainTypes, mapTiles, mapLandscapeTypes, mapCities, mapDistricts, skills, abilities, mapPlayerVisibleMapData, playerInventorySlots, playerSkills, playerAbilities] = await Promise.all([
    getMapTerrainTypes(),
    getMapTiles(),
    getMapLandscapeTypes(),
    getMapCities(),
    getMapDistricts(),
    getSkills(),
    getAbilities(),
    getPlayerVisibleMapData(playerId),
    getPlayerInventorySlots(playerId),
    getPlayerSkills(playerId),
    getPlayerAbilities(playerId),
  ])

  const terrainTypes = arrayToObjectKeyId("id", mapTerrainTypes) as TMapTerrainTypesById

  const landscapeTypes = arrayToObjectKeyId("id", mapLandscapeTypes) as TMapLandscapeTypesById

  const cities = mapCities ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", mapCities) as TCitiesByCoordinates) : {}

  const districts = mapDistricts ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", mapDistricts) as TDistrictsByCoordinates) : {}

  const playerVisibleMapData = mapPlayerVisibleMapData ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", mapPlayerVisibleMapData) as TPlayerVisibleMapDataByCoordinates) : {}

  const joinedMapTiles = joinMapTiles(mapTiles, terrainTypes, landscapeTypes, cities, districts, playerVisibleMapData)

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: {
            "/api/map-tiles": mapTiles,
            "/api/skills": skills,
            "/api/abilities": abilities,
            "/api/cities": mapCities,
            "/api/districts": mapDistricts,
            ...(playerId && { [`/api/map-tiles/player-visible-map-data/${playerId}`]: mapPlayerVisibleMapData }),
            ...(playerId && { [`/api/players/${playerId}/inventory-slots`]: playerInventorySlots }),
            ...(playerId && { [`/api/players/${playerId}/skills`]: playerSkills }),
            ...(playerId && { [`/api/players/${playerId}/abilities`]: playerAbilities }),
          },
        }}>
        <MapTilesWrapper
          terrainTypes={terrainTypes}
          landscapeTypes={landscapeTypes}
          joinedMapTiles={joinedMapTiles}
        />
      </SWRProvider>
    </div>
  )
}
