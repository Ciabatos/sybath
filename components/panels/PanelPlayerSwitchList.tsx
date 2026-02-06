"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { createImage } from "@/methods/functions/util/createImage"
import { useActivePlayerSwitchProfiles } from "@/methods/hooks/players/composite/useActivePlayerSwitchProfiles"
import { toast } from "sonner"
import styles from "./styles/PanelPlayerSwitchList.module.css"

export default function PanelPlayerSwitchList() {
  const { activePlayerSwitchProfiles } = useActivePlayerSwitchProfiles()
  const { switchPlayer } = useActivePlayerSwitchProfiles()
  const { createPlayerPortrait } = createImage()

  const handleClick = async (id: number) => {
    const result = await switchPlayer(id)
    toast.error(result)
  }

  return (
    <div className={styles.selectorContainer}>
      <div className={styles.selectorHeader}>
        <span className={styles.selectorTitle}>Select Hero</span>
      </div>
      <div className={styles.heroList}>
        {Object.entries(activePlayerSwitchProfiles).map(([id, profile]) => (
          <button
            key={id}
            type='button'
            className={`${styles.heroItem}`}
            onClick={() => {
              handleClick(profile.id)
            }}
          >
            <Avatar className={styles.heroAvatar}>
              <AvatarImage
                src={createPlayerPortrait(profile.imagePortrait)}
                alt={profile.name}
              />
              <AvatarFallback className={styles.heroFallback}>{profile.name.charAt(0)}</AvatarFallback>
            </Avatar>
            <div className={styles.heroInfo}>
              <span className={styles.heroName}>
                {profile.name} {profile.secondName}
              </span>
              <span className={styles.heroDetails}>{profile.nickname}</span>
            </div>
          </button>
        ))}
      </div>
    </div>
  )
}
