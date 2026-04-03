"use client"
import Material from "@/components/items/Material"
import getIcon from "@/methods/functions/icons/getIcon"
import useRecipeMaterials from "@/methods/hooks/items/composite/useRecipeMaterials"
import styles from "./styles/RecipeMaterials.module.css"

type TRecipeMaterialsProps = { recipeId: number }

export default function RecipeMaterials({ recipeId }: TRecipeMaterialsProps) {
  const { combinedRecipeMaterials } = useRecipeMaterials(recipeId)
  console.log("combinedRecipeMaterials", combinedRecipeMaterials)
  return (
    <div className={styles.panel}>
      {Object.values(combinedRecipeMaterials).map((recipe) => (
        <Material
          key={recipe.id}
          icon={getIcon(recipe.image)}
          name={recipe.name}
          itemId={recipe.itemId}
          quantity={recipe.quantity}
          description={recipe.description}
        />
      ))}
    </div>
  )
}
