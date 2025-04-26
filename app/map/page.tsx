"use server"
import { auth } from "@/auth"
import MapWrapper from "@/components/MapWrapper"
import { getPlayerVisibleMapData, TPlayerVisibleMapDataById } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import { getMapLandscapeTypes, TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { getMapTerrainTypes, TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { getAbilities } from "@/db/postgresMainDatabase/schemas/players/tables/abilities"
import { getInventorySlots } from "@/db/postgresMainDatabase/schemas/players/tables/inventories"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/tables/playerAbilities"
import { getPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/tables/playerSkills"
import { getSkills } from "@/db/postgresMainDatabase/schemas/players/tables/skills"
import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { joinMapTiles } from "@/methods/functions/joinMapTiles"
import { SWRProvider } from "@/providers/swr-provider"
import styles from "./page.module.css"

export default async function MapPage() {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return null
  }

  const [mapTerrainTypes, mapTiles, mapLandscapeTypes, skills, abilities, mapPlayerVisibleMapData, inventorySlots, playerSkills, playerAbilities] = await Promise.all([
    getMapTerrainTypes(),
    getMapTiles(),
    getMapLandscapeTypes(),
    getSkills(),
    getAbilities(),
    getPlayerVisibleMapData(playerId),
    getInventorySlots(playerId),
    getPlayerSkills(playerId),
    getPlayerAbilities(playerId),
  ])

  const terrainTypes = arrayToObjectKeyId("id", mapTerrainTypes) as TMapTerrainTypesById

  const landscapeTypes = arrayToObjectKeyId("id", mapLandscapeTypes) as TMapLandscapeTypesById

  const playerVisibleMapData = mapPlayerVisibleMapData ? (arrayToObjectKeyId("map_tile_id", mapPlayerVisibleMapData) as TPlayerVisibleMapDataById) : {}

  const joinedMapTiles = joinMapTiles(mapTiles, terrainTypes, landscapeTypes, playerVisibleMapData)

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: {
            "/api/map-tiles": mapTiles,
            "/api/skills": skills,
            "/api/abilities": abilities,
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
