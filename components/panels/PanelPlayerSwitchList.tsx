"use client"

import styles from "@/components/panels/styles/PlayerSwitchButton.module.css"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { createHeroPortrait } from "@/methods/functions/panels/createHeroPortrait"
import { useActivePlayerSwitchProfiles } from "@/methods/hooks/players/composite/useActivePlayerSwitchProfiles"

export default function PanelPlayerSwitchList() {
  const { activePlayerSwitchProfiles } = useActivePlayerSwitchProfiles()
  const { createPortrait } = createHeroPortrait()

  const handleClick = (id: number) => {
    // switchPlayer(id)
    // openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerPortrait)
  }

  return (
    <ul className={styles.dropdown}>
      {Object.entries(activePlayerSwitchProfiles).map(([id, profile]) => (
        <li key={id}>
          <Button onClick={() => handleClick(Number(id))}>
            <img
              src={profile.imagePortrait}
              alt={profile.name}
              className={styles.portrait}
            />
          </Button>
          <Avatar className={styles.avatar}>
            <AvatarImage
              src={createPortrait(profile.imagePortrait)}
              alt='Hero avatar'
            />
            <AvatarFallback className={styles.avatarFallback}>HV</AvatarFallback>
          </Avatar>
        </li>
      ))}
    </ul>
  )
}
