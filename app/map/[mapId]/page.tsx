"use server"
import { auth } from "@/auth"
import MapWrapper from "@/components/map/MapWrapper"
import { getMapData } from "@/methods/server-fetchers/world/composite/getMapData"
import { SWRProvider } from "@/providers/swr-provider"
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

  const mapData = await getMapData(mapId)

  if (!mapData) {
    return null
  }

  const { terrainTypes, landscapeTypes, districtTypes, joinedMap, fallbackData } = mapData

  return (
    <div className={styles.main}>
      <SWRProvider
        value={{
          fallback: fallbackData,
        }}>
        <MapWrapper
          terrainTypes={terrainTypes.byKey}
          landscapeTypes={landscapeTypes.byKey}
          joinedMap={joinedMap}
          districtTypes={districtTypes.byKey}
        />
      </SWRProvider>
    </div>
  )
}
