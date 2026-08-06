// GENERATED CODE - DO EDIT MANUALLY - createButton.hbs

"use client"
import { Button } from "@/components/ui/button"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import styles from "./styles/MoveButtonPlan.module.css"

type TMoveButtonPlanProps = {
  onClose?: () => void
}

export default function MoveButtonPlan({ onClose }: TMoveButtonPlanProps) {
  const { selectPlayerPathToClickedTile } = usePlayerMovement()

  function handleClick() {
    selectPlayerPathToClickedTile()
    onClose?.()
  }

  return (
    <Button
      className={styles.actionButton}
      onClick={handleClick}
    >
      MoveButtonPlan
    </Button>
  )
}
