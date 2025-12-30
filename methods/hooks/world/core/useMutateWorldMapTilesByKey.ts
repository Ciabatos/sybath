// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import {
  TWorldMapTilesRecordByXY,
  TWorldMapTilesParams,
  TWorldMapTiles,
} from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { mapTilesAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldMapTiles(params: TWorldMapTilesParams) {
  const { mutate } = useSWR<TWorldMapTiles[]>(`/api/world/map-tiles/${params.mapId}`)
  const setWorldMapTiles = useSetAtom(mapTilesAtom)
  const mapTiles = useAtomValue(mapTilesAtom)

  function mutateWorldMapTiles(optimisticParams: Partial<TWorldMapTiles> | Partial<TWorldMapTiles>[]) {
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      mapId: ``,
      x: ``,
      y: ``,
      terrainTypeId: ``,
      landscapeTypeId: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TWorldMapTilesRecordByXY

    const optimisticDataMergeWithOldData: TWorldMapTilesRecordByXY = {
      ...mapTiles,
      ...newObj,
    }

    setWorldMapTiles(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateWorldMapTiles }
}
