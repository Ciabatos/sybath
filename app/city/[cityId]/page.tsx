"use server"
import { auth } from "@/auth"
import CityWrapper from "@/components/city/CityWrapper"
import { getCityData } from "@/methods/server-fetchers/cities/composite/getCityData"
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
  const cityData = await getCityData(cityId)

  if (!cityData) {
    return null
  }

  const { terrainTypes, landscapeTypes, buildingTypes, joinedCity, fallbackData } = cityData

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
