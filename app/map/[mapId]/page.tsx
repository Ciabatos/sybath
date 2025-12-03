"use server"
import { auth } from "@/auth"
import MapWrapper from "@/components/map/MapWrapper"
import { joinMap } from "@/methods/functions/map/joinMap"
import { createSwrFallback } from "@/methods/functions/util/createSwrFallback"
import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/getAttributesAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/getAttributesSkillsServer"
import { getCitiesCitiesByKeyServer } from "@/methods/server-fetchers/cities/getCitiesCitiesByKeyServer"
import { getDistrictsDistrictsByKeyServer } from "@/methods/server-fetchers/districts/getDistrictsDistrictsByKeyServer"
import { getDistrictsDistrictTypesServer } from "@/methods/server-fetchers/districts/getDistrictsDistrictTypesServer"
import { getGetPlayerInventoryServer } from "@/methods/server-fetchers/inventory/getGetPlayerInventoryServer"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/players/getPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/server-fetchers/players/getPlayerSkillsServer"
import { getPlayerVisibleMapDataServer } from "@/methods/server-fetchers/world/getPlayerVisibleMapDataServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/getWorldLandscapeTypesServer"
import { getWorldMapTilesByKeyServer } from "@/methods/server-fetchers/world/getWorldMapTilesByKeyServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/getWorldTerrainTypesServer"
import { SWRProvider } from "@/providers/swr-provider"
import styles from "./page.module.css"

type TParams = {
  mapId: number
}

export default async function WorldPage({ params }: { params: TParams }) {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return null
  }

  const mapId = (await params).mapId

  if (!mapId || isNaN(mapId)) {
    return null
  }

  const [terrainTypes, mapTiles, landscapeTypes, cities, districts, districtTypes, skills, abilities, playerVisibleMapData, playerSkills, playerAbilities, playerIventory] = await Promise.all([
    getWorldTerrainTypesServer(),
    getWorldMapTilesByKeyServer({ mapId }),
    getWorldLandscapeTypesServer(),
    getCitiesCitiesByKeyServer({ mapId }),
    getDistrictsDistrictsByKeyServer({ mapId }),
    getDistrictsDistrictTypesServer(),
    getAttributesSkillsServer(),
    getAttributesAbilitiesServer(),
    getPlayerVisibleMapDataServer({ playerId }),
    getPlayerSkillsServer({ playerId }),
    getPlayerAbilitiesServer({ playerId }),
    getGetPlayerInventoryServer({ playerId }),
  ])

  const joinedMap = joinMap(mapTiles.byKey, terrainTypes.byKey, landscapeTypes.byKey, cities.byKey, districts.byKey, districtTypes.byKey, playerVisibleMapData.byKey)

  const fallbackData = createSwrFallback(
    mapTiles,
    skills,
    abilities,
    cities,
    districts,
    districtTypes,
    playerVisibleMapData,
    playerSkills,
    playerAbilities,
    playerIventory,
    terrainTypes,
    landscapeTypes,
  )

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
          districtTypes={districtTypes.byKey}
        />
      </SWRProvider>
    </div>
  )
}
