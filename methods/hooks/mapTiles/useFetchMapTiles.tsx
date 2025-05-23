"use client"
import { mapTilesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchMapTiles() {
  const setMapTiles = useSetAtom(mapTilesAtom)
  const { data } = useSWR("/api/map-tiles", { refreshInterval: 3000 })
  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setMapTiles(data)
      prevDataRef.current = data
    }
  }, [data])
}
