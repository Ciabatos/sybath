// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import { Button } from "@/components/ui/button"
import { useModalBottomCenter } from "@/methods/hooks/modals/useModalBottomCenter"
import { X } from "lucide-react"
import styles from "./styles/MovementPanel.module.css"

export default function MovementPanel() {
  const { resetModalBottomCenter } = useModalBottomCenter()

  function closeMovementPanel() {
    resetModalBottomCenter()
  }

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <Button
          onClick={closeMovementPanel}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>
      </div>
    </div>
  )
}
