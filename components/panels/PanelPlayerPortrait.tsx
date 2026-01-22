"use client"

import PanelPlayerSquadPortrait from "@/components/panels/PanelPlayerSquadPortrait"
import PlayerSwitchButton from "@/components/panels/PlayerSwitchButton"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { createHeroPortrait } from "@/methods/functions/panels/createHeroPortrait"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useActivePlayerProfile } from "@/methods/hooks/players/composite/useActivePlayerProfile"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import styles from "./styles/PanelPlayerPortrait.module.css"

export default function PanelPlayerPortrait() {
  const { openModalLeftTopBar } = useModalLeftTopBar()
  const { createPortrait } = createHeroPortrait()
  const { activePlayerProfile } = useActivePlayerProfile()

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
            src={createPortrait(activePlayerProfile?.imagePortrait)}
            alt='Hero avatar'
            className={styles.avatarImage}
          />
          <AvatarFallback className={styles.avatarFallback}>HV</AvatarFallback>
        </Avatar>
      </Button>
      <PlayerSwitchButton></PlayerSwitchButton>
      <PanelPlayerSquadPortrait></PanelPlayerSquadPortrait>
    </div>
  )
}
