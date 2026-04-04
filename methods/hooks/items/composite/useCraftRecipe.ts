import { doCraftRecipeAction } from "@/methods/actions/items/doCraftRecipeAction"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { toast } from "sonner"

type TCraftRecipeParams = {
  recipeId: number
}

export function useCraftRecipe(params: TCraftRecipeParams) {
  const { playerId } = usePlayerId()

  async function craftRecipe() {
    try {
      const result = await doCraftRecipeAction({
        playerId,
        recipeId: params.recipeId,
      })

      if (!result.status) {
        return toast.error(result.message)
      }

      toast.success(`You have crafted ${params.recipeId}!`)
    } catch (error) {
      console.error("Error crafting recipe:", error)
    }
  }

  return { craftRecipe }
}
