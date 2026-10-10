// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerRecipesRecordByItemId,
  TPlayerRecipes,
  TPlayerRecipesFetchParams,
} from "@/db/postgresMainDatabase/schemas/items/playerRecipes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerRecipesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerRecipes` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERRECIPES_SWR_KEY = (params: TPlayerRecipesFetchParams) =>
  params.playerId != null ? `/api/items/rpc/get-player-recipes/${params.playerId}` : null

export function useFetchPlayerRecipes(params: TPlayerRecipesFetchParams) {
  const setPlayerRecipes = useSetAtom(playerRecipesAtom)

  const { data } = useSWR<TPlayerRecipes[]>(PLAYERRECIPES_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerRecipes = arrayToObjectKey(["itemId"], data) as TPlayerRecipesRecordByItemId
      setPlayerRecipes(playerRecipes)
    }
  }, [data, setPlayerRecipes])
}

export function usePlayerRecipesState() {
  return useAtomValue(playerRecipesAtom)
}
