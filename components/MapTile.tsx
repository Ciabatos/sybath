"use client"

import { useAStar } from "@/methods/hooks/useAStar"
import style from "./styles/MapTile.module.css"
import { useCreateBackgroundImage } from "@/methods/hooks/useCreateBackgroundImage"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { useCreatePlayerImage } from "@/methods/hooks/useCreatePlayerImage"

interface Props {
  tile: TjoinedMapTile
}

export default function MapTile({ tile }: Props) {
  const runAStar = useAStar(1, 1, 30, 30, 0)

  return (
    <div
      className={style.BackgroundImage}
      style={{
        gridColumnStart: tile.x,
        gridRowStart: tile.y,
        backgroundImage: useCreateBackgroundImage(tile.image_url),
      }}
      onClick={runAStar}>
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
