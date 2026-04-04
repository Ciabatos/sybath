"use client"

import { useFetchItemsItems, useItemsItemsState } from "@/methods/hooks/items/core/useFetchItemsItems"
import {
  useFetchPlayerRecipeMaterials,
  usePlayerRecipeMaterialsState,
} from "@/methods/hooks/items/core/useFetchPlayerRecipeMaterials"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export default function useRecipeMaterials(recipeId: number) {
  const { playerId } = usePlayerId()
  useFetchPlayerRecipeMaterials({ playerId, recipeId })
  const playerRecipeMaterials = usePlayerRecipeMaterialsState()

  useFetchItemsItems()
  const items = useItemsItemsState()

  const combinedPlayerRecipeMaterials = Object.values(playerRecipeMaterials).map((recipeMaterials) => ({
    ...items[recipeMaterials.itemId],
    ...recipeMaterials,
  }))

  return { combinedPlayerRecipeMaterials }
}
