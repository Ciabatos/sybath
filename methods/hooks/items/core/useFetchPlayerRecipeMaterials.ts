// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerRecipeMaterialsRecordById,
  TPlayerRecipeMaterials,
  TPlayerRecipeMaterialsFetchParams,
} from "@/db/postgresMainDatabase/schemas/items/playerRecipeMaterials"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerRecipeMaterialsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerRecipeMaterials` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERRECIPEMATERIALS_SWR_KEY = (params: TPlayerRecipeMaterialsFetchParams) =>
  params.playerId != null && params.recipeId != null
    ? `/api/items/rpc/get-player-recipe-materials/${params.playerId}/${params.recipeId}`
    : null

export function useFetchPlayerRecipeMaterials(params: TPlayerRecipeMaterialsFetchParams) {
  const setPlayerRecipeMaterials = useSetAtom(playerRecipeMaterialsAtom)

  const { data } = useSWR<TPlayerRecipeMaterials[]>(PLAYERRECIPEMATERIALS_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerRecipeMaterials = arrayToObjectKey(["id"], data) as TPlayerRecipeMaterialsRecordById
      setPlayerRecipeMaterials(playerRecipeMaterials)
    }
  }, [data, setPlayerRecipeMaterials])
}

export function usePlayerRecipeMaterialsState() {
  return useAtomValue(playerRecipeMaterialsAtom)
}
