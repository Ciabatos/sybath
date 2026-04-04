// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerRecipeMaterialsRecordById,
  TPlayerRecipeMaterials,
  TPlayerRecipeMaterialsParams,
} from "@/db/postgresMainDatabase/schemas/items/playerRecipeMaterials"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerRecipeMaterialsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerRecipeMaterials(params: TPlayerRecipeMaterialsParams) {
  const setPlayerRecipeMaterials = useSetAtom(playerRecipeMaterialsAtom)

  const { data } = useSWR<TPlayerRecipeMaterials[]>(
    `/api/items/rpc/get-player-recipe-materials/${params.playerId}/${params.recipeId}`,
    { refreshInterval: 3000 },
  )

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
