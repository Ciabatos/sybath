"use client"
import useSWR from "swr"
import { useEffect } from "react"
import { useSetAtom } from "jotai"
import { mapTilesAtom } from "@/store/atoms"

export default function useFetchMapTiles() {
  const setData = useSetAtom(mapTilesAtom)
  const { data, error, isLoading } = useSWR("/api/map-tiles", { refreshInterval: 3000 })

  useEffect(() => {
    setData(data)
  }, [data, error, isLoading, setData])
}
