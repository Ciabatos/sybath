// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TDistrictsDistrictsRecordByMapTileXMapTileY, TDistrictsDistricts } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchDistrictsDistricts() {
  const setDistrictsDistricts = useSetAtom(districtsAtom)
  
  const { data } = useSWR<TDistrictsDistricts[]>(`/api/districts/districts`, { refreshInterval: 3000 })

  const districts = data
  ? (arrayToObjectKey(["mapTileX", "mapTileY"], data) as TDistrictsDistrictsRecordByMapTileXMapTileY)
  : {}

  useEffect(() => {
    if (districts) {
      setDistrictsDistricts(districts)
    }
  }, [districts, setDistrictsDistricts])

  return { districts }
}
