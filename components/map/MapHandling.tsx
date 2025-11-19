"use client"

import Map from "@/components/map/Map"
import { TMapLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { TJoinMapByXY } from "@/methods/functions/map/joinMap"
import { useRefreshMapHandling } from "@/methods/hooks/map/composite/useRefreshMapHandling"

interface Props {
  joinedMap: TJoinMapByXY
  terrainTypes: TMapTerrainTypesRecordById
  landscapeTypes: TMapLandscapeTypesRecordById
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
