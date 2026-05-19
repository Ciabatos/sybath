"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { createImage } from "@/methods/functions/util/createImage"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useSetOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import usePlayerSquadPlayersProfiles from "@/methods/hooks/squad/composite/usePlayerSquadPlayersProfiles"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import styles from "./styles/SquadPlayersProfiles.module.css"

export default function SquadPlayersProfiles() {
  const { openModalRightCenter } = useModalRightCenter()
  const { squadPlayersProfiles } = usePlayerSquadPlayersProfiles()
  const setOtherPlayerId = useSetOtherPlayerId()
  const { createPlayerPortrait } = createImage()

  function handleClickDetails(otherPlayerId: string) {
    setOtherPlayerId(otherPlayerId)
    openModalRightCenter(EPanelsRightCenter.OtherPlayerPanel)
  }

  return (
    <div className={styles.squadGrid}>
      {Object.values(squadPlayersProfiles).map((player) => (
        <div
          key={player.name + player.secondName}
          className={styles.memberCard}
        >
          <div className={styles.memberHeader}>
            <Avatar className={styles.avatar}>
              <AvatarImage
                src={createPlayerPortrait(player?.imagePortrait)}
                alt='Hero'
                className={styles.avatarImage}
              />
              <AvatarFallback className={styles.avatarFallback}>{"VB"}</AvatarFallback>
            </Avatar>
            <div className={styles.memberInfo}>
              <h3 className={styles.memberName}>{player.name}</h3>
              <h3 className={styles.memberName}>{player.secondName}</h3>
              <h3 className={styles.memberName}>{player.nickname}</h3>
            </div>
          </div>

          <div className={styles.actionButtons}>
            <Button
              onClick={() => handleClickDetails(player.otherPlayerId)}
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
