"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useSetOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import useActivePlayerSquadPlayersProfiles from "@/methods/hooks/squad/composite/useActivePlayerSquadPlayersProfiles"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import styles from "./styles/SquadPlayersProfiles.module.css"

export default function SquadPlayersProfiles() {
  const { openModalRightCenter } = useModalRightCenter()
  const { activePlayerSquadPlayersProfiles } = useActivePlayerSquadPlayersProfiles()
  const setOtherPlayerId = useSetOtherPlayerId()

  function handleClickDetails(otherPlayerId: string) {
    setOtherPlayerId(otherPlayerId)
    openModalRightCenter(EPanelsRightCenter.PanelOtherPlayerPanel)
  }

  return (
    <div className={styles.squadGrid}>
      {Object.values(activePlayerSquadPlayersProfiles).map((player) => (
        <div
          key={player.name + player.secondName}
          className={styles.memberCard}
        >
          <div className={styles.memberHeader}>
            <Avatar className={styles.memberAvatar}>
              <AvatarImage
                src={player.imagePortrait || "/placeholder.svg"}
                alt={player.name}
              />
              <AvatarFallback className={styles.avatarFallback}>{player.name.substring(0, 2)}</AvatarFallback>
            </Avatar>
            <div className={styles.memberInfo}>
              <h3 className={styles.memberName}>{player.name}</h3>
              <h3 className={styles.memberName}>{player.secondName}</h3>
              <h3 className={styles.memberName}>{player.nickname}</h3>
            </div>
          </div>

          <div className={styles.actionButtons}>
            <Button
              onClick={() => handleClickDetails(player.otherPlayerId.toString())}
              className={styles.actionButton}
              size='sm'
            >
              Details
            </Button>
          </div>
        </div>
      ))}
    </div>
  )
}
