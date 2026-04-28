"use client"

import { Button } from "@/components/ui/button"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useSquadControls } from "@/methods/hooks/squad/composite/useSquadControls"
import { useSquadInvites } from "@/methods/hooks/squad/composite/useSquadInvites"
import styles from "./styles/SquadSwitchList.module.css"

export default function SquadSwitchList() {
  const { resetModalTopCenter } = useModalTopCenter()
  const { joinSquad } = useSquadControls()
  const { squadInvites } = useSquadInvites()

  function handleJoinSquad(squadInviteId: number) {
    joinSquad(squadInviteId)
    resetModalTopCenter()
  }

  return (
    <div className={styles.selectorContainer}>
      <div className={styles.selectorHeader}>
        <span className={styles.selectorTitle}>Squad Inivites</span>
      </div>
      <div className={styles.heroItem}>
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
