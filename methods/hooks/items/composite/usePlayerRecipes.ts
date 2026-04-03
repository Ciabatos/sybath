"use client"

import { useFetchPlayerRecipes, usePlayerRecipesState } from "@/methods/hooks/items/core/useFetchPlayerRecipes"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export default function usePlayerRecipes() {
  const { playerId } = usePlayerId()
  useFetchPlayerRecipes({ playerId })
  const playerRecipes = usePlayerRecipesState()

  return { playerRecipes }
}
