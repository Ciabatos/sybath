"use server"
import { auth } from "@/auth"
import MapWrapper from "@/components/map/MapWrapper"
import { joinMap } from "@/methods/functions/map/joinMap"
import { createSwrFallback } from "@/methods/functions/util/createSwrFallback"
import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/getAttributesAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/getAttributesSkillsServer"
import { getCitiesCitiesServer } from "@/methods/server-fetchers/cities/getCitiesCitiesServer"
import { getDistrictsDistrictsServer } from "@/methods/server-fetchers/districts/getDistrictsDistrictsServer"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/players/getPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/server-fetchers/players/getPlayerSkillsServer"
import { getPlayerVisibleMapDataServer } from "@/methods/server-fetchers/world/getPlayerVisibleMapDataServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/getWorldLandscapeTypesServer"
import { getWorldMapTilesServer } from "@/methods/server-fetchers/world/getWorldMapTilesServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/getWorldTerrainTypesServer"
import { SWRProvider } from "@/providers/swr-provider"
import styles from "./page.module.css"

export default async function MapPage() {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return null
  }

  const [terrainTypes, mapTiles, landscapeTypes, cities, districts, skills, abilities, playerVisibleMapData, playerSkills, playerAbilities] = await Promise.all([
    getWorldTerrainTypesServer(),
    getWorldMapTilesServer(),
    getWorldLandscapeTypesServer(),
    getCitiesCitiesServer(),
    getDistrictsDistrictsServer(),
    getAttributesSkillsServer(),
    getAttributesAbilitiesServer(),
    getPlayerVisibleMapDataServer({ playerId }),
    getPlayerSkillsServer({ playerId }),
    getPlayerAbilitiesServer({ playerId }),
  ])

  const joinedMap = joinMap(mapTiles.byKey, terrainTypes.byKey, landscapeTypes.byKey, cities.byKey, districts.byKey, playerVisibleMapData.byKey)

  const fallbackData = createSwrFallback(mapTiles, skills, abilities, cities, districts, playerVisibleMapData, playerSkills, playerAbilities)

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: fallbackData,
        }}>
        <MapWrapper
          terrainTypes={terrainTypes.byKey}
          landscapeTypes={landscapeTypes.byKey}
          joinedMap={joinedMap}
        />
      </SWRProvider>
    </div>
  )
}
