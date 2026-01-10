"use client"

import PanelPlayerSquadPortrait from "@/components/panels/PanelPlayerSquadPortrait"
import PlayerSwitchButton from "@/components/panels/PlayerSwitchButton"
import styles from "@/components/panels/styles/PanelPlayerPortrait.module.css"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { createHeroPortrait } from "@/methods/functions/panels/createHeroPortrait"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useActivePlayer } from "@/methods/hooks/players/composite/useActivePlayer"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"

export default function PanelPlayerPortrait() {
  const { openModalLeftTopBar } = useModalLeftTopBar()
  const { createPortrait } = createHeroPortrait()
  const { activePlayer } = useActivePlayer()

  const handleClick = () => {
    openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerPanel)
  }

  return (
    <div>
      <Button
        onClick={handleClick}
        className={styles.heroButton}
        size='icon'
      >
        <Avatar className={styles.avatar}>
          <AvatarImage
            src={createPortrait("17.png")}
            alt='Hero avatar'
            className={styles.avatarImage}
          />
          {activePlayer?.imagePortrait}
          <AvatarFallback className={styles.avatarFallback}>HV</AvatarFallback>
        </Avatar>
      </Button>
      <PlayerSwitchButton></PlayerSwitchButton>
      <PanelPlayerSquadPortrait></PanelPlayerSquadPortrait>
    </div>
  )
}
