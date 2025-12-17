// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerAbilitiesRecordByAbilityId,
  TPlayerAbilitiesParams,
} from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerAbilities(params: TPlayerAbilitiesParams) {
  const playerAbilities = useAtomValue(playerAbilitiesAtom)
  const setPlayerAbilities = useSetAtom(playerAbilitiesAtom)

  const { data } = useSWR(`/api/attributes/rpc/get-player-abilities/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["abilityId"], data) as TPlayerAbilitiesRecordByAbilityId) : {}
      setPlayerAbilities(index)
      prevDataRef.current = data
    }
  }, [data, setPlayerAbilities])

  return { playerAbilities }
}
