"use client"

import style from "@/components/styles/MapTile.module.css"
import { useCreateBackgroundImage } from "@/methods/hooks/useCreateBackgroundImage"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { useCreatePlayerImage } from "@/methods/hooks/useCreatePlayerImage"
import { useClickMapTile } from "@/methods/hooks/useClickTile"
import { usePlayerActionMapTilesMovement } from "@/methods/hooks/usePlayerActionMapTilesMovement"
import { useClickedMapTileValidator } from "@/methods/hooks/useClickedMapTileValidator"
import ModalMapTilesPlayerActionBar from "@/components/ModalMapTilesPlayerActionBar"
import { createPortal } from "react-dom"
import { useState } from "react"

interface Props {
  tile: TjoinedMapTile
}

export type TClickedTile = {
  x: number
  y: number
}

export default function MapTile({ tile }: Props) {
  const { setCoordinatesOnClick } = useClickMapTile()
  const { playerActionMapTilesMovement } = usePlayerActionMapTilesMovement()
  const { checkIfMapTileContainsPlayer } = useClickedMapTileValidator()
  const [isModalMapTilesPlayerActionBarOpen, setIsModalMapTilesPlayerActionBarOpen] = useState(false)

  const backgroundImage = useCreateBackgroundImage(tile.image_url)

  const playerImage = useCreatePlayerImage(tile.player_image_url)

  const handleClick = (x: number, y: number) => {
    setCoordinatesOnClick(x, y)
    // playerActionMapTilesMovement()
    checkIfMapTileContainsPlayer(x, y)
    setIsModalMapTilesPlayerActionBarOpen(true)
  }

  return (
    <div
      className={style.BackgroundImage}
      onClick={() => handleClick(tile.x, tile.y)}
      style={{
        gridColumnStart: tile.x,
        gridRowStart: tile.y,
        backgroundImage: backgroundImage,
      }}>
      <div
        className={style.PlayerImage}
        style={{
          backgroundImage: playerImage,
        }}></div>
      <div>
        {tile.x}, {tile.y}
      </div>
      {isModalMapTilesPlayerActionBarOpen && createPortal(<ModalMapTilesPlayerActionBar />, document.body)}
    </div>
  )
}
