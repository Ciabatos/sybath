"use client"
import { inventorySlotsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchInventorySlots() {
  const session = useSession()
  const playerId = session?.data?.user.playerId

  const setInventorySlots = useSetAtom(inventorySlotsAtom)
  const { data, error, isLoading } = useSWR(`/api/players/${playerId}/inventory-slots`)

  useEffect(() => {
    console.log("useFetchInventorySlots", { data, error, isLoading })
    setInventorySlots(data)
  }, [data, error, isLoading])
}
