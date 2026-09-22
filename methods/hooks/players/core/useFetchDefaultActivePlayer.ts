// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TDefaultActivePlayerRecordById,
  TDefaultActivePlayer,
  TDefaultActivePlayerClientParams,
} from "@/db/postgresMainDatabase/schemas/players/defaultActivePlayer"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { defaultActivePlayerAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchDefaultActivePlayer(params: TDefaultActivePlayerClientParams) {
  const setDefaultActivePlayer = useSetAtom(defaultActivePlayerAtom)

  const { data } = useSWR<TDefaultActivePlayer[]>(`/api/players/rpc/get-default-active-player`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const defaultActivePlayer = arrayToObjectKey(["id"], data) as TDefaultActivePlayerRecordById
      setDefaultActivePlayer(defaultActivePlayer)
    }
  }, [data, setDefaultActivePlayer])
}

export function useDefaultActivePlayerState() {
  return useAtomValue(defaultActivePlayerAtom)
}
