"use client"

import { useFetchItemsItems, useItemsItemsState } from "@/methods/hooks/items/core/useFetchItemsItems"
import { useItemsRecipeMaterialsState } from "@/methods/hooks/items/core/useFetchItemsRecipeMaterials"
import { useFetchItemsRecipeMaterialsByKey } from "@/methods/hooks/items/core/useFetchItemsRecipeMaterialsByKey"

export default function useRecipeMaterials(recipeId: number) {
  useFetchItemsRecipeMaterialsByKey({ recipeId })
  const recipeMaterials = useItemsRecipeMaterialsState()
  console.log("recipeMaterials", recipeMaterials)
  useFetchItemsItems()
  const items = useItemsItemsState()

  const combinedRecipeMaterials = Object.values(recipeMaterials).map((recipeMaterials) => ({
    ...items[recipeMaterials.itemId],
    ...recipeMaterials,
  }))

  return { combinedRecipeMaterials }
}
