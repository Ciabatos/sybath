"use client"
import { districtInventorySlotsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchDistrictInventorySlots(districtId: number | undefined) {
  const setDistrictInventorySlotsAtom = useSetAtom(districtInventorySlotsAtom)
  const districtInventorySlots = useAtomValue(districtInventorySlotsAtom)
  const { data } = useSWR(`/api/districts/${districtId}/inventory-slots`)

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setDistrictInventorySlotsAtom(data)
      prevDataRef.current = data
    }
  }, [data])

  return {
    districtInventorySlots,
  }
}
