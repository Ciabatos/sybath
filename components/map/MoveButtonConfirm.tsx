// GENERATED CODE - DO EDIT MANUALLY - createButton.hbs

"use client"
import { Button } from "@/components/ui/button"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import styles from "./styles/MoveButtonConfirm.module.css"

type TMoveButtonConfirmProps = {
  onClose?: () => void
}

export default function MoveButtonConfirm({ onClose }: TMoveButtonConfirmProps) {
  const { moveSelectedPlayerPath } = usePlayerMovement()

  function handleClick() {
    moveSelectedPlayerPath()
    onClose?.()
  }

  return (
    <Button
      className={styles.actionButton}
      onClick={handleClick}
    >
      MoveButtonConfirm
    </Button>
  )
}
