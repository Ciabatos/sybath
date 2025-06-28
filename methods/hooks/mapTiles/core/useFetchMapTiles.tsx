"use client"
import { mapTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchMapTiles() {
  const mapTiles = useAtomValue(mapTilesAtom)
  const setMapTiles = useSetAtom(mapTilesAtom)
  const { data } = useSWR("/api/map-tiles", { refreshInterval: 3000 })
  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setMapTiles(data)
      prevDataRef.current = data
    }
  }, [data])

  return { mapTiles }
}
