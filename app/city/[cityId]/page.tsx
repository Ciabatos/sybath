"use server"
import { auth } from "@/auth"
import CityWrapper from "@/components/city/CityWrapper"
import { joinCity } from "@/methods/functions/map/joinCity"
import { createSwrFallback } from "@/methods/functions/util/createSwrFallback"
import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/getAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/getSkillsServer"
import { getPlayerInventoryServer } from "@/methods/server-fetchers/items/getPlayerInventoryServer"
import { getMapBuildingsByKeyServer } from "@/methods/server-fetchers/map/getBuildingsByKeyServer"
import { getMapCityTilesByKeyServer } from "@/methods/server-fetchers/map/getCityTilesByKeyServer"
import { getMapLandscapeTypesServer } from "@/methods/server-fetchers/map/getLandscapeTypesServer"
import { getMapTerrainTypesServer } from "@/methods/server-fetchers/map/getTerrainTypesServer"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/players/getPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/server-fetchers/players/getPlayerSkillsServer"
import { SWRProvider } from "@/providers/swr-provider"
import styles from "./page.module.css"

type TParams = {
  cityId: number
}

export default async function CityPage({ params }: { params: TParams }) {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return null
  }

  const cityId = (await params).cityId

  if (!cityId || isNaN(cityId)) {
    return null
  }

  const [cityTiles, terrainTypes, landscapeTypes, buildings, skills, abilities, playerIventory, playerSkills, playerAbilities] = await Promise.all([
    getMapCityTilesByKeyServer({ cityId }),
    getMapTerrainTypesServer(),
    getMapLandscapeTypesServer(),
    getMapBuildingsByKeyServer({ id: cityId }),
    getAttributesSkillsServer(),
    getAttributesAbilitiesServer(),
    getPlayerInventoryServer({ playerId }),
    getPlayerSkillsServer({ playerId }),
    getPlayerAbilitiesServer({ playerId }),
  ])

  if (!cityTiles) {
    return <div>City dont exsists</div>
  }

  const joinedCity = joinCity(cityTiles.byKey, terrainTypes.byKey, landscapeTypes.byKey, buildings.byKey)

  const fallbackData = createSwrFallback(cityTiles, terrainTypes, landscapeTypes, buildings)

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: fallbackData,
        }}>
        <CityWrapper
          cityId={cityId}
          terrainTypes={terrainTypes}
          landscapeTypes={landscapeTypes}
          joinedCity={joinedCity}
        />
      </SWRProvider>
    </div>
  )
}
