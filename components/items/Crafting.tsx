"use client"
import Recipe from "@/components/items/Recipe"
import RecipeMaterials from "@/components/items/RecipeMaterials"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import usePlayerRecipes from "@/methods/hooks/items/composite/usePlayerRecipes"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { X } from "lucide-react"
import { useState } from "react"

export default function Crafting() {
  const { playerRecipes } = usePlayerRecipes()
  const { resetModalRightCenter } = useModalRightCenter()
  const [clickedRecipeId, setClickedRecipeId] = useState<number | null>(null)

  function closeCrafting() {
    resetModalRightCenter()
  }

  function clickRecipeMaterials(recipeId: number) {
    setClickedRecipeId(recipeId)
  }

  return (
    <>
      <div>
        {clickedRecipeId !== null && <RecipeMaterials recipeId={clickedRecipeId} />}
        <Button
          onClick={() => closeCrafting()}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>
        {Object.values(playerRecipes).map((recipe) => (
          <div
            key={recipe.id}
            onClick={() => {
              clickRecipeMaterials(recipe.id)
            }}
          >
            <Recipe
              key={recipe.id}
              icon={getIcon(recipe.image)}
              name={recipe.description}
              value={recipe.value}
              maxValue={10}
              description={recipe.description}
            />
          </div>
        ))}
      </div>
    </>
  )
}
