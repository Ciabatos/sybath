"use client"
import { buildingInventorySlotsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchBuildingInventorySlots(buildingId: number | undefined) {
  const buildingInventorySlots = useAtomValue(buildingInventorySlotsAtom)
  const setBuildingInventorySlots = useSetAtom(buildingInventorySlotsAtom)
  const { data } = useSWR(`/api/buildings/${buildingId}/inventory-slots`)

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setBuildingInventorySlots(data)
      prevDataRef.current = data
    }
  }, [data])

  return { buildingInventorySlots }
}
