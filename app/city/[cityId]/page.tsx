"use server"
import { auth } from "@/auth"

import CityWrapper from "@/components/city/CityWrapper"
import { getAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { getSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { getPlayerInventorySlots } from "@/db/postgresMainDatabase/schemas/items/inventories"
import { getCityBuildings, TCityBuildingsByCoordinates } from "@/db/postgresMainDatabase/schemas/map/buildings"
import { getCityTiles } from "@/db/postgresMainDatabase/schemas/map/cityTiles"
import { getMapLandscapeTypes, TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { getMapTerrainTypes, TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/playerAbilities"
import { getPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/playerSkills"
import { joinCity } from "@/methods/functions/map/joinCity"
import { arrayToObjectKeyId, arrayToObjectKeysId } from "@/methods/functions/util/converters"
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
    getMapCityTilesServer(cityId),
    getMapTerrainTypesServer(),
    getMapLandscapeTypesServer(),
    getCityBuildings(cityId),
    getAttributesSkillsServer(),
    getAttributesAbilitiesServer(),
    getPlayerInventoryServer(playerId),
    getPlayerSkillsServer(playerId),
    getPlayerAbilitiesServer(playerId),
  ])

  if (!cityTiles || cityTiles.length === 0) {
    return <div>City dont exsists</div>
  }

  const joinedCity = joinCity(cityTiles.byKey, terrainTypes.byKey, landscapeTypes.byKey, buildings.byKey)

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: {
            ...{ [cityTiles.apiPath]: cityTiles.raw },
            ...{ [terrainTypes.apiPath]: terrainTypes.raw },
            ...{ [landscapeTypes.apiPath]: landscapeTypes.raw },
            ...{ [buildings.apiPath]: buildings.raw },
            ...{ [skills.apiPath]: skills.raw },
            ...{ [abilities.apiPath]: abilities.raw },
            ...{ [playerIventory.apiPath]: playerIventory.raw },
            ...{ [playerSkills.apiPath]: playerSkills.raw },
            ...{ [playerAbilities.apiPath]: playerAbilities.raw },
          },
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
