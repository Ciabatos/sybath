"use client"

import { Avatar, AvatarImage } from "@/components/ui/avatar"
import { createImage } from "@/methods/functions/util/createImage"
import styles from "./styles/PlayerPortrait.module.css"

type TPlayerPortrait = {
  imagePortrait: string | null
}

export default function PlayerPortrait(props: TPlayerPortrait) {
  if (!props.imagePortrait) return null
  const { createPlayerPortrait } = createImage()
  const avatarUrl =
    props.imagePortrait && props.imagePortrait.trim() !== ""
      ? createPlayerPortrait(props.imagePortrait)
      : createPlayerPortrait("masked.png")

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
