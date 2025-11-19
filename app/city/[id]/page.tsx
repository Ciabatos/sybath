"use server"
import { auth } from "@/auth"

import CityTilesWrapper from "@/components/city/CityTilesWrapper"
import { getAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { getSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { getPlayerInventorySlots } from "@/db/postgresMainDatabase/schemas/items/inventories"
import { getCityBuildings, TCityBuildingsByCoordinates } from "@/db/postgresMainDatabase/schemas/map/buildings"
import { getCityTiles } from "@/db/postgresMainDatabase/schemas/map/cityTiles"
import { getMapLandscapeTypes, TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { getMapTerrainTypes, TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/playerAbilities"
import { getPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/playerSkills"
import { joinCityTiles } from "@/methods/functions/map/joinCityTiles"
import { arrayToObjectKeyId, arrayToObjectKeysId } from "@/methods/functions/util/converters"
import { SWRProvider } from "@/providers/swr-provider"
import styles from "./page.module.css"

type TypeParams = {
  id: number
}

export default async function CityPage({ params }: { params: TypeParams }) {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return null
  }

  const cityId = (await params).id

  if (!cityId || isNaN(cityId)) {
    return null
  }

  const [cityTiles, mapTerrainTypes, mapLandscapeTypes, cityBuildings, skills, abilities, playerIventorySlots, playerSkills, playerAbilities] = await Promise.all([
    getCityTiles(cityId),
    getMapTerrainTypes(),
    getMapLandscapeTypes(),
    getCityBuildings(cityId),
    getSkills(),
    getAbilities(),
    getPlayerInventorySlots(playerId),
    getPlayerSkills(playerId),
    getPlayerAbilities(playerId),
  ])

  if (!cityTiles || cityTiles.length === 0) {
    return <div>City dont exsists</div>
  }

  const terrainTypes = arrayToObjectKeyId("id", mapTerrainTypes) as TMapTerrainTypesById

  const landscapeTypes = arrayToObjectKeyId("id", mapLandscapeTypes) as TMapLandscapeTypesById

  const buildings = cityBuildings ? (arrayToObjectKeysId("city_tile_x", "city_tile_y", cityBuildings) as TCityBuildingsByCoordinates) : {}

  const joinedCityTiles = joinCityTiles(cityTiles, terrainTypes, landscapeTypes, buildings)

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: {
            "/api/skills": skills,
            "/api/abilities": abilities,
            ...(cityId && { [`/api/cities/${cityId}/city-tiles`]: cityTiles }),
            ...(cityId && { [`/api/cities/${cityId}/buildings`]: cityBuildings }),
            ...(playerId && { [`/api/players/${playerId}/inventory-slots`]: playerIventorySlots }),
            ...(playerId && { [`/api/players/${playerId}/skills`]: playerSkills }),
            ...(playerId && { [`/api/players/${playerId}/abilities`]: playerAbilities }),
          },
        }}>
        <CityTilesWrapper
          cityId={cityId}
          joinedCityTiles={joinedCityTiles}
          terrainTypes={terrainTypes}
          landscapeTypes={landscapeTypes}
        />
      </SWRProvider>
    </div>
  )
}
