"use client"
import Recipe from "@/components/items/Recipe"
import RecipeMaterials from "@/components/items/RecipeMaterials"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import usePlayerRecipes from "@/methods/hooks/items/composite/usePlayerRecipes"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { X } from "lucide-react"
import { Activity, useState } from "react"
import style from "./styles/Crafting.module.css"

export default function Crafting() {
  const { playerRecipes } = usePlayerRecipes()
  const { resetModalRightCenter } = useModalRightCenter()
  const [clickedRecipeId, setClickedRecipeId] = useState<number>(0)

  function closeCrafting() {
    resetModalRightCenter()
  }

  function clickRecipeMaterials(recipeId: number) {
    setClickedRecipeId(recipeId)
  }

  return (
    <div className={style.craftingContainer}>
      <Activity mode={clickedRecipeId > 0 ? "visible" : "hidden"}>
        <div>
          <RecipeMaterials recipeId={clickedRecipeId} />
        </div>
      </Activity>

      <div>
        {Object.values(playerRecipes).map((recipe) => (
          <div
            key={recipe.id}
            onClick={() => clickRecipeMaterials(recipe.id)}
          >
            <Recipe
              icon={getIcon(recipe.image)}
              name={recipe.description}
              value={recipe.value}
              maxValue={10}
              description={recipe.description}
              canCraft={recipe.canCraft}
            />
          </div>
        ))}
      </div>

      <Button
        onClick={closeCrafting}
        variant='ghost'
        size='icon'
      >
        <X />
      </Button>
    </div>
  )
}
