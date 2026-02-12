"use client"

import PlayerSwitchButton from "@/components/players/PlayerSwitchButton"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { createImage } from "@/methods/functions/util/createImage"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useActivePlayerProfile } from "@/methods/hooks/players/composite/useActivePlayerProfile"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import styles from "./styles/PanelPlayerPortrait.module.css"

export default function PanelPlayerPortrait() {
  const { openModalLeftTopBar } = useModalLeftTopBar()
  const { createPlayerPortrait } = createImage()
  const { activePlayerProfile } = useActivePlayerProfile()

  const handleClick = () => {
    openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerPanel)
  }

  const avatarUrl = createPlayerPortrait(activePlayerProfile?.imagePortrait)
  const avatarFallback = "VB"

  return (
    <div>
      <Button
        onClick={handleClick}
        className={styles.heroButton}
        size='icon'
      >
        <Avatar className={styles.avatar}>
          <AvatarImage
            src={avatarUrl}
            alt='Hero avatar'
            className={styles.avatarImage}
          />
          <AvatarFallback className={styles.avatarFallback}>{avatarFallback}</AvatarFallback>
        </Avatar>
      </Button>
      <div className={styles.playerSwitchButtonContainer}>
        <PlayerSwitchButton />
      </div>
    </div>
  )
}
