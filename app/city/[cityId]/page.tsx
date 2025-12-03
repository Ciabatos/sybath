"use server"
import { auth } from "@/auth"
import CityWrapper from "@/components/city/CityWrapper"
import { joinCity } from "@/methods/functions/city/joinCity"
import { createSwrFallback } from "@/methods/functions/util/createSwrFallback"
import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/getAttributesAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/getAttributesSkillsServer"
import { getBuildingsBuildingsByKeyServer } from "@/methods/server-fetchers/buildings/getBuildingsBuildingsByKeyServer"
import { getBuildingsBuildingTypesServer } from "@/methods/server-fetchers/buildings/getBuildingsBuildingTypesServer"
import { getCitiesCityTilesByKeyServer } from "@/methods/server-fetchers/cities/getCitiesCityTilesByKeyServer"
import { getGetPlayerInventoryServer } from "@/methods/server-fetchers/inventory/getGetPlayerInventoryServer"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/players/getPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/server-fetchers/players/getPlayerSkillsServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/getWorldLandscapeTypesServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/getWorldTerrainTypesServer"
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

  const [cityTiles, terrainTypes, landscapeTypes, buildings, skills, abilities, playerIventory, playerSkills, playerAbilities, buildingTypes] = await Promise.all([
    getCitiesCityTilesByKeyServer({ cityId }),
    getWorldTerrainTypesServer(),
    getWorldLandscapeTypesServer(),
    getBuildingsBuildingsByKeyServer({ id: cityId }),
    getAttributesSkillsServer(),
    getAttributesAbilitiesServer(),
    getGetPlayerInventoryServer({ playerId }),
    getPlayerSkillsServer({ playerId }),
    getPlayerAbilitiesServer({ playerId }),
    getBuildingsBuildingTypesServer(),
  ])

  if (!cityTiles) {
    return <div>City dont exsists</div>
  }
  console.log("cityTiles in page", cityTiles.byKey, terrainTypes.byKey, landscapeTypes.byKey, buildings.byKey, buildingTypes.byKey)
  const joinedCity = joinCity(cityTiles.byKey, terrainTypes.byKey, landscapeTypes.byKey, buildings.byKey, buildingTypes.byKey)

  const fallbackData = createSwrFallback(cityTiles, terrainTypes, landscapeTypes, buildings, skills, abilities, playerIventory, playerSkills, playerAbilities, buildingTypes)

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: fallbackData,
        }}>
        <CityWrapper
          cityId={cityId}
          terrainTypes={terrainTypes.byKey}
          landscapeTypes={landscapeTypes.byKey}
          buildingsTypes={buildingTypes.byKey}
          joinedCity={joinedCity}
        />
      </SWRProvider>
    </div>
  )
}
