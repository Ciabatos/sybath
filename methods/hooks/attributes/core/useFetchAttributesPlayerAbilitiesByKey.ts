// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TAttributesPlayerAbilitiesRecordByPlayerId,
  TAttributesPlayerAbilitiesParams,
} from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchAttributesPlayerAbilitiesByKey(params: TAttributesPlayerAbilitiesParams) {
  const playerAbilities = useAtomValue(playerAbilitiesAtom)
  const setAttributesPlayerAbilities = useSetAtom(playerAbilitiesAtom)

  const { data } = useSWR(`/api/attributes/player-abilities/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["playerId"], data) as TAttributesPlayerAbilitiesRecordByPlayerId) : {}
      setAttributesPlayerAbilities(index)
      prevDataRef.current = data
    }
  }, [data, setAttributesPlayerAbilities])

  return { playerAbilities }
}
