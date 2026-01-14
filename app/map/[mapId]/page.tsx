"use server"
import { auth } from "@/auth"
import MapWrapper from "@/components/map/MapWrapper"
import { getMapData } from "@/methods/server-fetchers/world/composite/getMapData"
import { AtomsHydrator } from "@/providers/jotai-hydrator-provider"
import { SWRProvider } from "@/providers/swr-provider"
import styles from "./page.module.css"

type TParams = {
  mapId: number
}

export default async function WorldPage({ params }: { params: TParams }) {
  const session = await auth()
  const sessionUserId = session?.user?.userId

  if (!sessionUserId || isNaN(sessionUserId)) {
    return null
  }

  const clientMapId = Number((await params).mapId)

  if (!clientMapId || isNaN(clientMapId)) {
    return null
  }

  const mapData = await getMapData(clientMapId, playerId)

  if (!mapData) {
    return null
  }

  const { atomHydrationData, fallbackData } = mapData

  return (
    <div className={styles.main}>
      <AtomsHydrator atomValues={[...atomHydrationData]}>
        <SWRProvider
          value={{
            fallback: fallbackData,
          }}
        >
          <MapWrapper />
        </SWRProvider>
      </AtomsHydrator>
    </div>
  )
}
