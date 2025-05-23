"use client"
import { inventorySlotsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchInventorySlots() {
  const session = useSession()
  const playerId = session?.data?.user.playerId

  const setInventorySlots = useSetAtom(inventorySlotsAtom)
  const { data } = useSWR(`/api/players/${playerId}/inventory-slots`)

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setInventorySlots(data)
      prevDataRef.current = data
    }
  }, [data])
}
