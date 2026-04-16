// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import { Button } from "@/components/ui/button"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { X } from "lucide-react"
import styles from "./styles/SquadControls.module.css"

export default function SquadControls() {
  const { resetModalTopCenter } = useModalTopCenter()

  function closeSquadControls() {
    resetModalTopCenter()
  }

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <Button
          onClick={closeSquadControls}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>
        <Button>Create Squad</Button>
        <Button>Join Squad</Button>
      </div>
    </div>
  )
}
