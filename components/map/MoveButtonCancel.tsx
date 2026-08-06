// GENERATED CODE - DO EDIT MANUALLY - createButton.hbs

"use client"
import { Button } from "@/components/ui/button"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import styles from "./styles/MoveButtonCancel.module.css"

type TMoveButtonCancelProps = {
  onClose?: () => void
}

export default function MoveButtonCancel({ onClose }: TMoveButtonCancelProps) {
  const { closeMovementPanel } = usePlayerMovement()

  function handleClick() {
    closeMovementPanel()
    onClose?.()
  }

  return (
    <Button
      className={styles.actionButton}
      onClick={handleClick}
    >
      MoveButtonCancel
    </Button>
  )
}
