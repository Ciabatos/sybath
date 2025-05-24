"use server"
import { auth } from "@/auth"
import CityWrapper from "@/components/CityWrapper"
import { getCityTiles } from "@/db/postgresMainDatabase/schemas/map/tables/cityTiles"
import { getMapLandscapeTypes, TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import { getMapTerrainTypes, TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { getAbilities } from "@/db/postgresMainDatabase/schemas/players/tables/abilities"
import { getInventorySlots } from "@/db/postgresMainDatabase/schemas/players/tables/inventories"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/tables/playerAbilities"
import { getPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/tables/playerSkills"
import { getSkills } from "@/db/postgresMainDatabase/schemas/players/tables/skills"
import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { joinCityTiles } from "@/methods/functions/joinCityTiles"
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

  const [cityTiles, mapTerrainTypes, mapLandscapeTypes, skills, abilities, inventorySlots, playerSkills, playerAbilities] = await Promise.all([
    getCityTiles(cityId),
    getMapTerrainTypes(),
    getMapLandscapeTypes(),
    getSkills(),
    getAbilities(),
    getInventorySlots(playerId),
    getPlayerSkills(playerId),
    getPlayerAbilities(playerId),
  ])

  if (!cityTiles || cityTiles.length === 0) {
    return <div>City dont exsists</div>
  }

  const terrainTypes = arrayToObjectKeyId("id", mapTerrainTypes) as TMapTerrainTypesById

  const landscapeTypes = arrayToObjectKeyId("id", mapLandscapeTypes) as TMapLandscapeTypesById

  const joinedCityTiles = joinCityTiles(cityTiles, terrainTypes, landscapeTypes)

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: {
            "/api/skills": skills,
            "/api/abilities": abilities,
            ...(cityId && { [`/api/cities/${cityId}/city-tiles`]: cityTiles }),
            ...(playerId && { [`/api/players/${playerId}/inventory-slots`]: inventorySlots }),
            ...(playerId && { [`/api/players/${playerId}/skills`]: playerSkills }),
            ...(playerId && { [`/api/players/${playerId}/abilities`]: playerAbilities }),
          },
        }}>
        <CityWrapper
          cityId={cityId}
          joinedCityTiles={joinedCityTiles}
          terrainTypes={terrainTypes}
          landscapeTypes={landscapeTypes}
        />
      </SWRProvider>
    </div>
  )
}
