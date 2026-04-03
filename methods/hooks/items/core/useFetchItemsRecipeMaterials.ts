// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TItemsRecipeMaterialsRecordByRecipeId,
  TItemsRecipeMaterials,
} from "@/db/postgresMainDatabase/schemas/items/recipeMaterials"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { recipeMaterialsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchItemsRecipeMaterials() {
  const setItemsRecipeMaterials = useSetAtom(recipeMaterialsAtom)

  const { data } = useSWR<TItemsRecipeMaterials[]>(`/api/items/recipe-materials`, { refreshInterval: 3000 })

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
