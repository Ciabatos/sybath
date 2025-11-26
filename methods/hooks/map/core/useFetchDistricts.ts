// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TMapDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/districts"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchDistricts() {
  const districts = useAtomValue(districtsAtom)
  const setDistricts = useSetAtom(districtsAtom)

  const { data } = useSWR(`/api/map/districts`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey("mapTileX", "mapTileY", data) as TMapDistrictsRecordByMapTileXMapTileY) : {}
      setDistricts(index)
      prevDataRef.current = data
    }
  }, [data, setDistricts])

  return { districts }
}
