"use client"

import PlayerSwitchButton from "@/components/panels/PlayerSwitchButton"
import styles from "@/components/panels/styles/PanelPlayerPortrait.module.css"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"

type Props = {
  closePanel: () => void
}

export default function PanelPlayerPortrait({ closePanel }: Props) {
  const { setModalLeftTopBar } = useModalLeftTopBar()

  const handleClick = () => {
    setModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerPanel)
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
            src={"https://github.com/shadcn.png"}
            alt='Hero avatar'
            className={styles.avatarImage}
          />
          <AvatarFallback className={styles.avatarFallback}>{"https://github.com/shadcn.png"}</AvatarFallback>
        </Avatar>
      </Button>
      <PlayerSwitchButton></PlayerSwitchButton>
    </div>
  )
}
