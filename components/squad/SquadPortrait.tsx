"use client"
import { createImage } from "@/methods/functions/util/createImage"
import { Avatar, AvatarImage } from "@radix-ui/react-avatar"
import styles from "./styles/SquadPortrait.module.css"

type TPlayerPortrait = {
  squadImagePortrait: string
}

export default function SquadPortrait(props: TPlayerPortrait) {
  const { createSquadPortrait } = createImage()

  const avatarUrl = createSquadPortrait(props.squadImagePortrait)

  return (
    <Avatar className={styles.avatar}>
      <AvatarImage
        src={avatarUrl}
        alt='Hero avatar'
        className={styles.avatarImage}
      />
    </Avatar>
  )
}
