"use client"

import { Button } from "@/components/ui/button"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { TJoinSquadParams, useSquadControls } from "@/methods/hooks/squad/composite/useSquadControls"
import { useSquadInvites } from "@/methods/hooks/squad/composite/useSquadInvites"
import styles from "./styles/SquadSwitchList.module.css"

export default function SquadSwitchList() {
  const { resetModalTopCenter } = useModalTopCenter()
  const { joinSquad } = useSquadControls()
  const { squadInvites } = useSquadInvites()

  function handleJoinSquad({ squadInviteId, mapId, mapTileX, mapTileY }: TJoinSquadParams) {
    joinSquad({ squadInviteId, mapId, mapTileX, mapTileY })
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
