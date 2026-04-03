// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerRecipesRecordByItemId,
  TPlayerRecipes,
  TPlayerRecipesParams,
} from "@/db/postgresMainDatabase/schemas/items/playerRecipes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerRecipesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerRecipes(params: TPlayerRecipesParams) {
  const setPlayerRecipes = useSetAtom(playerRecipesAtom)

  const { data } = useSWR<TPlayerRecipes[]>(`/api/items/rpc/get-player-recipes/${params.playerId}`, {
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
