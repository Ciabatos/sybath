// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TGetPlayerAbilitiesRecordByAbilityId,
  TGetPlayerAbilitiesParams,
} from "@/db/postgresMainDatabase/schemas/attributes/getPlayerAbilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchGetPlayerAbilities(params: TGetPlayerAbilitiesParams) {
  const getPlayerAbilities = useAtomValue(getPlayerAbilitiesAtom)
  const setGetPlayerAbilities = useSetAtom(getPlayerAbilitiesAtom)

  const { data } = useSWR(`/api/attributes/rpc/get-player-abilities/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["abilityId"], data) as TGetPlayerAbilitiesRecordByAbilityId) : {}
      setGetPlayerAbilities(index)
      prevDataRef.current = data
    }
  }, [data, setGetPlayerAbilities])

  return { getPlayerAbilities }
}
