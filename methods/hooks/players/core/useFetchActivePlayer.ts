// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TActivePlayer, TActivePlayerRecordById } from "@/db/postgresMainDatabase/schemas/players/activePlayer"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { activePlayerAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchActivePlayer() {
  const setActivePlayer = useSetAtom(activePlayerAtom)

  const { data } = useSWR<TActivePlayer[]>(`/api/players/rpc/get-active-player`, {
    refreshInterval: 3000,
  })

  const activePlayer = data ? (arrayToObjectKey(["id"], data) as TActivePlayerRecordById) : {}

  useEffect(() => {
    if (activePlayer) {
      setActivePlayer(activePlayer)
    }
  }, [activePlayer, setActivePlayer])

  return { activePlayer }
}
