"use client"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { joinMapTiles, TJoinedMapTileById } from "@/methods/functions/joinMapTiles"
import { useFetchCities } from "@/methods/hooks/mapTiles/useFetchCities"
import { useFetchDistricts } from "@/methods/hooks/mapTiles/useFetchDistricts"
import { useFetchMapTiles } from "@/methods/hooks/mapTiles/useFetchMapTiles"
import { useFetchPlayerVisibleMapData } from "@/methods/hooks/mapTiles/useFetchPlayerVisibleMapData"
import { citiesAtom, districtsAtom, joinedMapTilesAtom, mapTilesAtom, playerVisibleMapDataAtom } from "@/store/atoms"
import { useAtom, useAtomValue } from "jotai"
import { useEffect } from "react"
interface Props {
  joinedMapTiles: TJoinedMapTileById
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export function useJoinMapTiles({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  useFetchMapTiles()
  useFetchCities()
  useFetchDistricts()
  useFetchPlayerVisibleMapData()

  const [newJoinedMapTilesOnClient, setJoinedMapTiles] = useAtom(joinedMapTilesAtom)
  const newMapTiles = useAtomValue(mapTilesAtom)
  const cities = useAtomValue(citiesAtom)
  const districts = useAtomValue(districtsAtom)
  const playerVisibleMapData = useAtomValue(playerVisibleMapDataAtom)

  useEffect(() => {
    if (newMapTiles) {
      const updatedTiles = joinMapTiles(newMapTiles, terrainTypes, landscapeTypes, cities, districts, playerVisibleMapData, { oldTilesToUpdate: joinedMapTiles })
      setJoinedMapTiles(updatedTiles)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [newMapTiles, cities, districts, playerVisibleMapData])

  return { newJoinedMapTilesOnClient }
}
