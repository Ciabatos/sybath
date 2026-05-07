// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import { Button } from "@/components/ui/button"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { TJoinSquadParams, useSquadControls } from "@/methods/hooks/squad/composite/useSquadControls"
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

  function handleJoinSquad({ squadInviteId, mapId, mapTileX, mapTileY }: TJoinSquadParams) {
    joinSquad({ squadInviteId, mapId, mapTileX, mapTileY })
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
            onClick={() =>
              handleJoinSquad({
                squadInviteId: invite.id,
                mapId: invite.mapId,
                mapTileX: invite.mapTileX,
                mapTileY: invite.mapTileY,
              })
            }
          >
            Invited to {invite.secondName} by {invite.name}
            {invite.nickname ? ` (${invite.nickname})` : ""} {invite.secondName}
          </Button>
        ))}
      </div>
    </div>
  )
}
