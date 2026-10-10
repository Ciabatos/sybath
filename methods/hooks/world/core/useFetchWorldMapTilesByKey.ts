// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TWorldMapTilesRecordByXY,
  TWorldMapTiles,
  TWorldMapTilesParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { mapTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateWorldMapTiles` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const WORLDMAPTILES_SWR_KEY_BY_KEY = (params: TWorldMapTilesParamsFetchParams) =>
  params.mapId != null ? `/api/world/map-tiles/${params.mapId}` : null

export function useFetchWorldMapTilesByKey(params: TWorldMapTilesParamsFetchParams) {
  const setWorldMapTiles = useSetAtom(mapTilesAtom)

  const { data } = useSWR<TWorldMapTiles[]>(WORLDMAPTILES_SWR_KEY_BY_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const mapTiles = arrayToObjectKey(["x", "y"], data) as TWorldMapTilesRecordByXY
      setWorldMapTiles(mapTiles)
    }
  }, [data, setWorldMapTiles])
}

export function useWorldMapTilesState() {
  return useAtomValue(mapTilesAtom)
}
