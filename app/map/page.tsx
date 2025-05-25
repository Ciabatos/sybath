"use server"
import { auth } from "@/auth"

import MapWrapper from "@/components/map/MapWrapper"
import { getAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { getSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { getPlayerVisibleMapData, TPlayerVisibleMapDataById } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import { getMapCities, TCitiesByMapCoordinates } from "@/db/postgresMainDatabase/schemas/map/tables/cities"
import { getMapDistricts, TDistrictsByMapCoordinates } from "@/db/postgresMainDatabase/schemas/map/tables/districts"
import { getMapLandscapeTypes, TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { getMapTerrainTypes, TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { getInventorySlots } from "@/db/postgresMainDatabase/schemas/players/tables/inventories"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/tables/playerAbilities"
import { getPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/tables/playerSkills"
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

  const [mapTerrainTypes, mapTiles, mapLandscapeTypes, mapCities, mapDistricts, skills, abilities, mapPlayerVisibleMapData, inventorySlots, playerSkills, playerAbilities] = await Promise.all([
    getMapTerrainTypes(),
    getMapTiles(),
    getMapLandscapeTypes(),
    getMapCities(),
    getMapDistricts(),
    getSkills(),
    getAbilities(),
    getPlayerVisibleMapData(playerId),
    getInventorySlots(playerId),
    getPlayerSkills(playerId),
    getPlayerAbilities(playerId),
  ])

  const terrainTypes = arrayToObjectKeyId("id", mapTerrainTypes) as TMapTerrainTypesById

  const landscapeTypes = arrayToObjectKeyId("id", mapLandscapeTypes) as TMapLandscapeTypesById

  const cities = mapCities ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", mapCities) as TCitiesByMapCoordinates) : {}

  const districts = mapDistricts ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", mapDistricts) as TDistrictsByMapCoordinates) : {}

  const playerVisibleMapData = mapPlayerVisibleMapData ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", mapPlayerVisibleMapData) as TPlayerVisibleMapDataById) : {}

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
            ...(playerId && { [`/api/players/${playerId}/inventory-slots`]: inventorySlots }),
            ...(playerId && { [`/api/players/${playerId}/skills`]: playerSkills }),
            ...(playerId && { [`/api/players/${playerId}/abilities`]: playerAbilities }),
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
