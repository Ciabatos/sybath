"use client"
import CraftingSkill from "@/components/items/Recipe"
import getIcon from "@/methods/functions/icons/getIcon"
import usePlayerRecipes from "@/methods/hooks/items/composite/usePlayerRecipes"

type TRecipeMaterialsProps = { recipeId: number }

export default function RecipeMaterials({ recipeId }: TRecipeMaterialsProps) {
  const { playerRecipes } = usePlayerRecipes()

  return (
    <>
      <div>
        {Object.values(playerRecipes).map((recipe) => (
          <CraftingSkill
            key={recipe.id}
            icon={getIcon(recipe.image)}
            name={recipe.description}
            value={recipe.value}
            maxValue={10}
            description={recipe.description}
          />
        ))}
      </div>
    </>
  )
}
