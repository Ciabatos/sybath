// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TDistrictsDistrictsRecordByMapTileXMapTileY,
  TDistrictsDistricts,
} from "@/db/postgresMainDatabase/schemas/districts/districts"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchDistrictsDistricts() {
  const districts = useAtomValue(districtsAtom)
  const setDistrictsDistricts = useSetAtom(districtsAtom)

  const { data } = useSWR<TDistrictsDistricts[]>(`/api/districts/districts`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = arrayToObjectKey(["mapTileX", "mapTileY"], data) as TDistrictsDistrictsRecordByMapTileXMapTileY
      setDistrictsDistricts(index)
    }
  }, [data, setDistrictsDistricts])

  return { districts }
}
