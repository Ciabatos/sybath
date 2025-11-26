"use client"

import Map from "@/components/map/Map"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TJoinMapByXY } from "@/methods/functions/map/joinMap"
import { useRefreshMapHandling } from "@/methods/hooks/world/composite/useRefreshMapHandling"

interface Props {
  joinedMap: TJoinMapByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
}

export default function MapHandling({ joinedMap, terrainTypes, landscapeTypes }: Props) {
  const { refreshedJoinedMap } = useRefreshMapHandling({ joinedMap, terrainTypes, landscapeTypes })

  return (
    <>
      {Object.entries(refreshedJoinedMap).map(([key, tile]) => (
        <Map
          key={key}
          tile={tile}
        />
      ))}
    </>
  )
}
