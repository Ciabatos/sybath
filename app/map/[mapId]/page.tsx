"use server"
import MapWrapper from "@/components/map/MapWrapper"
import { auth } from "@/lib/auth"
import { getInitialPageMapData } from "@/methods/server-fetchers/world/composite/getInitialPageMapData"
import { AtomsHydrator } from "@/providers/jotai-hydrator"
import { SWRHydrator } from "@/providers/swr-hydrator"
import { headers } from "next/headers"
import styles from "./page.module.css"

type TParams = {
  mapId: number
}

export default async function WorldPage({ params }: { params: TParams }) {
  const session = await auth.api.getSession({ headers: await headers() })
  const sessionUserId = session?.user?.id

  if (!sessionUserId) {
    return null
  }

  const clientMapId = Number((await params).mapId)

  if (!clientMapId || isNaN(clientMapId)) {
    return null
  }

  const initialPageMapData = await getInitialPageMapData(clientMapId, sessionUserId)

  if (!initialPageMapData) {
    return null
  }

  const { atomHydrationData, fallbackData } = initialPageMapData

  return (
    <div className={styles.main}>
      <AtomsHydrator atomValues={[...atomHydrationData]}>
        <SWRHydrator fallback={fallbackData}>
          <MapWrapper />
        </SWRHydrator>
      </AtomsHydrator>
    </div>
  )
}
