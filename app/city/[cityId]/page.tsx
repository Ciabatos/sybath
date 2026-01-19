"use server"
import { auth } from "@/auth"
import CityWrapper from "@/components/city/CityWrapper"
import { getCityData } from "@/methods/server-fetchers/cities/composite/getCityData"
import { AtomsHydrator } from "@/providers/jotai-hydrator"
import { SWRHydrator } from "@/providers/swr-hydrator"
import styles from "./page.module.css"

type TParams = {
  cityId: number
}

export default async function CityPage({ params }: { params: TParams }) {
  const session = await auth()
  const sessionUserId = session?.user?.userId

  if (!sessionUserId || isNaN(sessionUserId)) {
    return null
  }

  const clientCityId = Number((await params).cityId)

  if (!clientCityId || isNaN(clientCityId)) {
    return null
  }
  const cityData = await getCityData(clientCityId, sessionUserId)

  if (!cityData) {
    return null
  }

  const { atomHydrationData, fallbackData } = cityData

  return (
    <div className={styles.main}>
      <AtomsHydrator atomValues={[...atomHydrationData]}>
        <SWRHydrator fallback={fallbackData}>
          <CityWrapper />
        </SWRHydrator>
      </AtomsHydrator>
    </div>
  )
}
