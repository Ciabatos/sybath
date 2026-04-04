"use client"
import Material from "@/components/items/Material"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import usePlayerRecipeMaterials from "@/methods/hooks/items/composite/usePlayerRecipeMaterials"
import styles from "./styles/RecipeMaterials.module.css"

type TRecipeMaterialsProps = { recipeId: number }

export default function RecipeMaterials({ recipeId }: TRecipeMaterialsProps) {
  const { combinedPlayerRecipeMaterials } = usePlayerRecipeMaterials(recipeId)
  return (
    <>
      <div className={styles.panel}>
        {Object.values(combinedPlayerRecipeMaterials).map((recipe) => (
          <Material
            key={recipe.id}
            icon={getIcon(recipe.image)}
            name={recipe.name}
            itemId={recipe.itemId}
            quantity={recipe.quantity}
            description={recipe.description}
            ownedQuantity={recipe.ownedQuantity}
            missingQuantity={recipe.missingQuantity}
          />
        ))}
      </div>
      <Button>Craft</Button>
    </>
  )
}
