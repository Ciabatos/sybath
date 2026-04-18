// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import { Button } from "@/components/ui/button"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useSquadControls } from "@/methods/hooks/squad/composite/useSquadControls"
import { X } from "lucide-react"
import styles from "./styles/SquadControls.module.css"

export default function SquadControls() {
  const { resetModalTopCenter } = useModalTopCenter()
  const { createSquad } = useSquadControls()

  function closeSquadControls() {
    resetModalTopCenter()
  }

  function handleCreateSquad() {
    createSquad()
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
        <Button onClick={handleCreateSquad}>Create Squad</Button>
        <div>Pending Invites</div>
      </div>
    </div>
  )
}
