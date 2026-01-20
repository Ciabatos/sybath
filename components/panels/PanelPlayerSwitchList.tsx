"use client"

import styles from "@/components/panels/styles/PanelPlayerSwitchList.module.css"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
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
    // <ul className={styles.dropdown}>
    //   {Object.entries(activePlayerSwitchProfiles).map(([name, profile]) => (
    //     <li key={name}>
    //       <Button onClick={() => handleClick(Number(name))}>
    //         <img
    //           src={profile.imagePortrait}
    //           alt={profile.name}
    //           className={styles.portrait}
    //         />
    //       </Button>
    //       <Avatar className={styles.avatar}>
    //         <AvatarImage
    //           src={createPortrait(profile.imagePortrait)}
    //           alt='Hero avatar'
    //         />
    //         <AvatarFallback className={styles.avatarFallback}>HV</AvatarFallback>
    //       </Avatar>
    //     </li>
    //   ))}
    // </ul>
    <div className={styles.selectorContainer}>
      <div className={styles.selectorHeader}>
        <span className={styles.selectorTitle}>Select Hero</span>
      </div>
      <div className={styles.heroList}>
        {Object.entries(activePlayerSwitchProfiles).map(([name, profile]) => (
          <button
            key={name}
            type='button'
            className={`${styles.heroItem}`}
          >
            <Avatar className={styles.heroAvatar}>
              <AvatarImage
                src={profile.imagePortrait || "/placeholder.svg"}
                alt={profile.name}
              />
              <AvatarFallback className={styles.heroFallback}>{profile.name.charAt(0)}</AvatarFallback>
            </Avatar>
            <div className={styles.heroInfo}>
              <span className={styles.heroName}>{profile.name}</span>
              <span className={styles.heroDetails}>{profile.name}</span>
            </div>
          </button>
        ))}
      </div>
    </div>
  )
}
