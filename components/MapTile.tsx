"use client"

import style from "./styles/MapTile.module.css"
import { useCreateBackgroundImage } from "@/methods/hooks/useCreateBackgroundImage"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { useCreatePlayerImage } from "@/methods/hooks/useCreatePlayerImage"
import { useClickMapTile } from "@/methods/hooks/useClickTile"
import { usePlayerActionMapTilesMovement } from "@/methods/hooks/usePlayerActionMapTilesMovement"
import { useClickedMapTileValidator } from "@/methods/hooks/useClickedMapTileValidator"

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

  const handleClick = (x: number, y: number) => {
    setCoordinatesOnClick(x, y)
    // playerActionMapTilesMovement()
    checkIfMapTileContainsPlayer(x, y)
  }

  return (
    <div
      className={style.BackgroundImage}
      onClick={() => handleClick(tile.x, tile.y)}
      style={{
        gridColumnStart: tile.x,
        gridRowStart: tile.y,
        backgroundImage: useCreateBackgroundImage(tile.image_url),
      }}>
      <div
        className={style.PlayerImage}
        style={{
          backgroundImage: useCreatePlayerImage(tile.player_image_url),
        }}></div>
      <div>
        {tile.x}, {tile.y}
      </div>
    </div>
  )
}
