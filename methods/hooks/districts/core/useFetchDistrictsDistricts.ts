// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchDistrictsDistricts() {
  const districts = useAtomValue(districtsAtom)
  const setDistrictsDistricts = useSetAtom(districtsAtom)

  const { data } = useSWR(`/api/districts/districts`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["mapTileX", "mapTileY"], data) as TDistrictsDistrictsRecordByMapTileXMapTileY) : {}
      setDistrictsDistricts(index)
      prevDataRef.current = data
    }
  }, [data, setDistrictsDistricts])

  return { districts }
}
