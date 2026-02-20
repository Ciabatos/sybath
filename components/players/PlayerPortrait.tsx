"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { createImage } from "@/methods/functions/util/createImage"
import styles from "./styles/PlayerPortrait.module.css"

type TPlayerPortrait = {
  imagePortrait: string
}

export default function PlayerPortrait(props: TPlayerPortrait) {
  const { createPlayerPortrait } = createImage()

  const avatarUrl = createPlayerPortrait(props.imagePortrait)
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
