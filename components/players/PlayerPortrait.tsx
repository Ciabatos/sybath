"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { createImage } from "@/methods/functions/util/createImage"
import { useActivePlayerProfile } from "@/methods/hooks/players/composite/useActivePlayerProfile"
import styles from "./styles/PlayerPortrait.module.css"

export default function PlayerPortrait() {
  const { createPlayerPortrait } = createImage()
  const { activePlayerProfile } = useActivePlayerProfile()

  const avatarUrl = createPlayerPortrait(activePlayerProfile?.imagePortrait)
  const avatarFallback = "VB"

  return (
    <>
      <Avatar className={styles.avatar}>
        <AvatarImage
          src={avatarUrl}
          alt='Hero avatar'
          className={styles.avatarImage}
        />
        <AvatarFallback className={styles.avatarFallback}>{avatarFallback}</AvatarFallback>
      </Avatar>
    </>
  )
}
