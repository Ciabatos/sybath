// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerAbilitiesRecordByAbilityId, TPlayerAbilities , TPlayerAbilitiesParams  } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerAbilitiesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerAbilities( params: TPlayerAbilitiesParams) {
  const setPlayerAbilities = useSetAtom(playerAbilitiesAtom)

  const { data } = useSWR<TPlayerAbilities[]>(`/api/attributes/rpc/get-player-abilities/${params.playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const playerAbilities = arrayToObjectKey(["abilityId"], data) as TPlayerAbilitiesRecordByAbilityId
      setPlayerAbilities(playerAbilities)
    }
  }, [data, setPlayerAbilities])
}
