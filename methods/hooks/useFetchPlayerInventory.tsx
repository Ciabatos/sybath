"use client"
import { TPlayerInventories } from "@/db/postgresMainDatabase/schemas/players/tables/playerInventories"
import { playerInventoryAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerInventory() {
  const session = useSession()
  const playerId = session?.data?.user.playerId

  const setPlayerInventory = useSetAtom(playerInventoryAtom)
  const { data, error, isLoading } = useSWR(`/api/player-inventories/${playerId}`)

  useEffect(() => {
    const playerInventory = data ? (data as TPlayerInventories) : undefined
    setPlayerInventory(playerInventory)
  }, [data, error, isLoading])
}
