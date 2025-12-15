"use client"

import Map from "@/components/map/Map"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TJoinMapByXY } from "@/methods/functions/map/joinMap"
import { useRefreshJoinedMap } from "@/methods/hooks/world/composite/useRefreshJoinedMap"

interface Props {
  joinedMap: TJoinMapByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  districtTypes: TDistrictsDistrictTypesRecordById
}

export default function MapHandling({ joinedMap, terrainTypes, landscapeTypes, districtTypes }: Props) {
  const { refreshedJoinedMap } = useRefreshJoinedMap({ joinedMap, terrainTypes, landscapeTypes, districtTypes })

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
