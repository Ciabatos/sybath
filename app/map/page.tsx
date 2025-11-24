"use server"
import { auth } from "@/auth"
import MapWrapper from "@/components/map/MapWrapper"
import { joinMap } from "@/methods/functions/map/joinMap"
import { createSwrFallback } from "@/methods/functions/util/createSwrFallback"
import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/getAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/getSkillsServer"
import { getPlayerInventoryServer } from "@/methods/server-fetchers/items/getPlayerInventoryServer"
import { getMapCitiesServer } from "@/methods/server-fetchers/map/getCitiesServer"
import { getMapDistrictsServer } from "@/methods/server-fetchers/map/getDistrictsServer"
import { getMapLandscapeTypesServer } from "@/methods/server-fetchers/map/getLandscapeTypesServer"
import { getMapMapTilesServer } from "@/methods/server-fetchers/map/getMapTilesServer"
import { getPlayerVisibleMapDataServer } from "@/methods/server-fetchers/map/getPlayerVisibleMapDataServer"
import { getMapTerrainTypesServer } from "@/methods/server-fetchers/map/getTerrainTypesServer"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/players/getPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/server-fetchers/players/getPlayerSkillsServer"
import { SWRProvider } from "@/providers/swr-provider"
import styles from "./page.module.css"

export default async function MapPage() {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return null
  }

  const [terrainTypes, mapTiles, landscapeTypes, cities, districts, skills, abilities, playerVisibleMapData, playerInventory, playerSkills, playerAbilities] = await Promise.all([
    getMapTerrainTypesServer(),
    getMapMapTilesServer(),
    getMapLandscapeTypesServer(),
    getMapCitiesServer(),
    getMapDistrictsServer(),
    getAttributesSkillsServer(),
    getAttributesAbilitiesServer(),
    getPlayerVisibleMapDataServer({ playerId }),
    getPlayerInventoryServer({ playerId }),
    getPlayerSkillsServer({ playerId }),
    getPlayerAbilitiesServer({ playerId }),
  ])

  const joinedMap = joinMap(mapTiles.byKey, terrainTypes.byKey, landscapeTypes.byKey, cities.byKey, districts.byKey, playerVisibleMapData.byKey)

  const fallbackData = createSwrFallback(mapTiles, skills, abilities, cities, districts, playerVisibleMapData, playerInventory, playerSkills, playerAbilities)

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
