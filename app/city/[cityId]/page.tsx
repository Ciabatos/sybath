"use server"
import { auth } from "@/auth"
import CityWrapper from "@/components/city/CityWrapper"
import { getCityData } from "@/methods/server-fetchers/cities/composite/getCityData"
import { AtomsHydrator } from "@/providers/jotai-hydrator-provider"
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

  const clientCityId = (await params).cityId

  if (!clientCityId || isNaN(clientCityId)) {
    return null
  }
  const cityData = await getCityData(clientCityId, playerId)

  if (!cityData) {
    return null
  }

  const { atomHydrationData, fallbackData } = cityData

  return (
    <div className={styles.main}>
      <AtomsHydrator atomValues={[...atomHydrationData]}>
        <SWRProvider
          value={{
            fallback: fallbackData,
          }}
        >
          <CityWrapper />
        </SWRProvider>
      </AtomsHydrator>
    </div>
  )
}
