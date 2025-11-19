// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TMapBuildingsParams, TMapBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/map/buildings"
import { arrayToObjectKeysId } from "@/methods/functions/util/converters"
import { buildingsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchBuildingsByKey(params: TMapBuildingsParams) {
  const buildings = useAtomValue(buildingsAtom)
  const setBuildings = useSetAtom(buildingsAtom)

  const { data } = useSWR(`/api/map/buildings/${params.id}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKeysId("cityTileX", "cityTileY", data) as TMapBuildingsRecordByCityTileXCityTileY) : {}
      setBuildings(index)
      prevDataRef.current = data
    }
  }, [data, setBuildings])

  return { buildings }
}
