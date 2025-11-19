"use server"
import { auth } from "@/auth"

import MapWrapper from "@/components/map/MapWrapper"
import { getAttributesAbilitiesServer } from "@/methods/fetchers/attributes/fetchAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/fetchers/attributes/fetchSkillsServer"
import { getPlayerInventoryServer } from "@/methods/fetchers/items/fetchPlayerInventoryServer"
import { getMapCitiesServer } from "@/methods/fetchers/map/fetchCitiesServer"
import { getMapDistrictsServer } from "@/methods/fetchers/map/fetchDistrictsServer"
import { getMapLandscapeTypesServer } from "@/methods/fetchers/map/fetchLandscapeTypesServer"
import { getMapMapTilesServer } from "@/methods/fetchers/map/fetchMapTilesServer"
import { getPlayerVisibleMapDataServer } from "@/methods/fetchers/map/fetchPlayerVisibleMapDataServer"
import { getMapTerrainTypesServer } from "@/methods/fetchers/map/fetchTerrainTypesServer"
import { getPlayerAbilitiesServer } from "@/methods/fetchers/players/fetchPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/fetchers/players/fetchPlayerSkillsServer"
import { joinMap } from "@/methods/functions/map/joinMap"
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

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: {
            ...{ [mapTiles.apiPath]: mapTiles.raw },
            ...{ [skills.apiPath]: skills.raw },
            ...{ [abilities.apiPath]: abilities.raw },
            ...{ [cities.apiPath]: cities.raw },
            ...{ [districts.apiPath]: districts.raw },
            ...{ [playerVisibleMapData.apiPath]: playerVisibleMapData.raw },
            ...{ [playerInventory.apiPath]: playerInventory.raw },
            ...{ [playerSkills.apiPath]: playerSkills.raw },
            ...{ [playerAbilities.apiPath]: playerAbilities.raw },
          },
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
