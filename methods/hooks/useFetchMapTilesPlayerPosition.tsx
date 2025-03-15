"use client"
import { TMapsFieldsPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapsFieldsPlayerPosition"
import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { mapTilesPlayerPostionAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchMapTilesPlayerPostion() {
  const setMapTilesPlayerPostion = useSetAtom(mapTilesPlayerPostionAtom)
  const { data, error, isLoading } = useSWR("/api/map-tiles-player-position", { refreshInterval: 3000 })

  const mapTilesPlayerPostion = data ? (arrayToObjectKeyId("map_field_id", data) as Record<number, TMapsFieldsPlayerPosition>) : {}

  useEffect(() => {
    setMapTilesPlayerPostion(mapTilesPlayerPostion)
  }, [data, error, isLoading])
}
