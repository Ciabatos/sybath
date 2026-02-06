"use server"
import { auth } from "@/auth"
import CityWrapper from "@/components/city/CityWrapper"
import { getInitialPageCityData } from "@/methods/server-fetchers/cities/composite/getInitialPageCityData"
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
  const initialPageCityData = await getInitialPageCityData(clientCityId, sessionUserId)

  if (!initialPageCityData) {
    return null
  }

  const { atomHydrationData, fallbackData } = initialPageCityData

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
