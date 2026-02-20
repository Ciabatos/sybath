"use client"

import { Avatar, AvatarImage } from "@/components/ui/avatar"
import { createImage } from "@/methods/functions/util/createImage"
import styles from "./styles/PlayerPortrait.module.css"

type TPlayerPortrait = {
  imagePortrait: string
}

export default function PlayerPortrait(props: TPlayerPortrait) {
  const { createPlayerPortrait } = createImage()

  const avatarUrl = createPlayerPortrait(props.imagePortrait)
  const avatarMasked = createPlayerPortrait("masked.png")

  if (!avatarUrl) {
    return (
      <>
        <Avatar className={styles.avatar}>
          <AvatarImage
            src={avatarMasked}
            alt='Hero avatar'
            className={styles.avatarImage}
          />
        </Avatar>
      </>
    )
  }

  return (
    <>
      <Avatar className={styles.avatar}>
        <AvatarImage
          src={avatarUrl}
          alt='Hero avatar'
          className={styles.avatarImage}
        />
      </Avatar>
    </>
  )
}
