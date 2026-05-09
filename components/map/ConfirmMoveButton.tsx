"use client"

import { Button } from "@/components/ui/button"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import styles from "./styles/MovementPanel.module.css"

type TConfirmMoveButtonProps = {
  onClose?: () => void
}

export default function ConfirmMoveButton({ onClose }: TConfirmMoveButtonProps) {
  const { moveSelectedPlayerPath, closeMovementPanel } = usePlayerMovement()

  function handleClick() {
    moveSelectedPlayerPath()
    closeMovementPanel()
    onClose?.()
  }

  return (
    <Button
      className={styles.actionButton}
      onClick={handleClick}
    >
      Confirm Move
    </Button>
  )
}
