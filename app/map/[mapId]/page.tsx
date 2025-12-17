"use server"
import { auth } from "@/auth"
import MapWrapper from "@/components/map/MapWrapper"
import { getMapData } from "@/methods/server-fetchers/world/composite/getMapData"
import { AtomsHydrator } from "@/providers/jotai-hydrator-provider"
import { SWRProvider } from "@/providers/swr-provider"
import { mapIdAtom, playerIdAtom } from "@/store/atoms"
import styles from "./page.module.css"

type TParams = {
  mapId: number
}

export default async function WorldPage({ params }: { params: TParams }) {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return null
  }

  const mapId = (await params).mapId

  if (!mapId || isNaN(mapId)) {
    return null
  }

  const mapData = await getMapData(mapId, playerId)

  if (!mapData) {
    return null
  }

  const { atomHydrationData, fallbackData } = mapData

  return (
    <div className={styles.main}>
      <AtomsHydrator atomValues={[...atomHydrationData, [mapIdAtom, mapId], [playerIdAtom, playerId]]}>
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
