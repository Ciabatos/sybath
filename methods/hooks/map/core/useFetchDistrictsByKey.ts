// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TMapDistrictsParams, TMapDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/districts"
import { arrayToObjectKeysId } from "@/methods/functions/util/converters"
import { districtsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchDistrictsByKey(params: TMapDistrictsParams) {
  const districts = useAtomValue(districtsAtom)
  const setDistricts = useSetAtom(districtsAtom)

  const { data } = useSWR(`/api/map/districts/${params.id}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKeysId("mapTileX", "mapTileY", data) as TMapDistrictsRecordByMapTileXMapTileY) : {}
      setDistricts(index)
      prevDataRef.current = data
    }
  }, [data, setDistricts])

  return { districts }
}
