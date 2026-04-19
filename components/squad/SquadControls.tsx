// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import { Button } from "@/components/ui/button"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useSquadControls } from "@/methods/hooks/squad/composite/useSquadControls"
import { useSquadInvites } from "@/methods/hooks/squad/composite/useSquadInvites"
import { X } from "lucide-react"
import styles from "./styles/SquadControls.module.css"

export default function SquadControls() {
  const { resetModalTopCenter } = useModalTopCenter()
  const { createSquad, joinSquad } = useSquadControls()
  const { squadInvites } = useSquadInvites()

  function closeSquadControls() {
    resetModalTopCenter()
  }

  function handleCreateSquad() {
    createSquad()
    resetModalTopCenter()
  }

  function handleJoinSquad(squadInviteId: number) {
    joinSquad(squadInviteId)
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
        {Object.values(squadInvites).map((invite) => (
          <Button
            key={invite.id}
            onClick={() => handleJoinSquad(invite.id)}
          >
            Invited to {invite.description} by {invite.name}
            {invite.nickname ? ` (${invite.nickname})` : ""} {invite.secondName}
          </Button>
        ))}
      </div>
    </div>
  )
}
