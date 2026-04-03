// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TItemsRecipeMaterialsRecordByRecipeId,
  TItemsRecipeMaterials,
  TItemsRecipeMaterialsParams,
} from "@/db/postgresMainDatabase/schemas/items/recipeMaterials"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { recipeMaterialsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchItemsRecipeMaterialsByKey(params: TItemsRecipeMaterialsParams) {
  const setItemsRecipeMaterials = useSetAtom(recipeMaterialsAtom)

  const { data } = useSWR<TItemsRecipeMaterials[]>(`/api/items/recipe-materials/${params.recipeId}`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const recipeMaterials = arrayToObjectKey(["recipeId"], data) as TItemsRecipeMaterialsRecordByRecipeId
      setItemsRecipeMaterials(recipeMaterials)
    }
  }, [data, setItemsRecipeMaterials])
}

export function useItemsRecipeMaterialsState() {
  return useAtomValue(recipeMaterialsAtom)
}
