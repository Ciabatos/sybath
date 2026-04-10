import { doCraftRecipeAction } from "@/methods/actions/items/doCraftRecipeAction"
import { useMutatePlayerInventory } from "@/methods/hooks/inventory/core/useMutatePlayerInventory"
import { useMutatePlayerRecipeMaterials } from "@/methods/hooks/items/core/useMutatePlayerRecipeMaterials"
import { useMutatePlayerRecipes } from "@/methods/hooks/items/core/useMutatePlayerRecipes"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { toast } from "sonner"

type TCraftRecipeParams = {
  recipeId: number
}

export function useCraftRecipe(params: TCraftRecipeParams) {
  const { playerId } = usePlayerId()
  const { mutatePlayerInventory } = useMutatePlayerInventory({ playerId })
  const { mutatePlayerRecipeMaterials } = useMutatePlayerRecipeMaterials({ playerId, recipeId: params.recipeId })
  const { mutatePlayerRecipes } = useMutatePlayerRecipes({ playerId })
  async function craftRecipe() {
    try {
      const result = await doCraftRecipeAction({
        playerId,
        recipeId: params.recipeId,
      })

      if (!result.status) {
        return toast.error(result.message)
      }
      mutatePlayerRecipes()
      mutatePlayerRecipeMaterials()
      mutatePlayerInventory()

      toast.success(`You have crafted ${params.recipeId}!`)
    } catch (error) {
      console.error("Error crafting recipe:", error)
    }
  }

  return { craftRecipe }
}
