// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerAbilitiesRecordByAbilityId,
  TOtherPlayerAbilities,
  TOtherPlayerAbilitiesParams,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerAbilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchOtherPlayerAbilities(params: TOtherPlayerAbilitiesParams) {
  const setOtherPlayerAbilities = useSetAtom(otherPlayerAbilitiesAtom)

  const { data } = useSWR<TOtherPlayerAbilities[]>(
    `/api/attributes/rpc/get-other-player-abilities/${params.playerId}/${params.otherPlayerId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const otherPlayerAbilities = arrayToObjectKey(["abilityId"], data) as TOtherPlayerAbilitiesRecordByAbilityId
      setOtherPlayerAbilities(otherPlayerAbilities)
    }
  }, [data, setOtherPlayerAbilities])
}

export function useOtherPlayerAbilities() {
  return useAtomValue(otherPlayerAbilitiesAtom)
}
