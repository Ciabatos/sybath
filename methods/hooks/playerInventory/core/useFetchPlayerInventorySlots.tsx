"use client"
import { playerInventorySlotsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerInventorySlots() {
  const session = useSession()
  const playerId = session?.data?.user.playerId

  const setPlayerInventorySlots = useSetAtom(playerInventorySlotsAtom)
  const playerInventorySlots = useAtomValue(playerInventorySlotsAtom)
  const { data } = useSWR(`/api/players/${playerId}/inventory-slots`)

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setPlayerInventorySlots(data)
      prevDataRef.current = data
    }
  }, [data])

  return { playerInventorySlots }
}
