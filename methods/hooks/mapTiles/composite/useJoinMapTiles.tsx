"use client"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { joinMapTiles, TJoinedMapTileById } from "@/methods/functions/joinMapTiles"
import { useFetchCities } from "@/methods/hooks/mapTiles/core/useFetchCities"
import { useFetchDistricts } from "@/methods/hooks/mapTiles/core/useFetchDistricts"
import { useFetchMapTiles } from "@/methods/hooks/mapTiles/core/useFetchMapTiles"
import { useFetchPlayerVisibleMapData } from "@/methods/hooks/mapTiles/core/useFetchPlayerVisibleMapData"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { useEffect } from "react"
interface Props {
  joinedMapTiles: TJoinedMapTileById
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export function useJoinMapTiles({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  useFetchDistricts()

  const [newJoinedMapTilesOnClient, setJoinedMapTiles] = useAtom(joinedMapTilesAtom)
  const { mapTiles } = useFetchMapTiles()
  const { cities } = useFetchCities()
  const { playerVisibleMapData } = useFetchPlayerVisibleMapData()
  const { districts } = useFetchDistricts()

  useEffect(() => {
    if (mapTiles) {
      const updatedTiles = joinMapTiles(mapTiles, terrainTypes, landscapeTypes, cities, districts, playerVisibleMapData, { oldTilesToUpdate: joinedMapTiles })
      setJoinedMapTiles(updatedTiles)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mapTiles, cities, districts, playerVisibleMapData])

  return { joinedMapTiles: newJoinedMapTilesOnClient }
}
