"use client"

import { useAStar } from "@/methods/hooks/useAStar"
import style from "./styles/MapTile.module.css"
import { useCreateBackgroundImage } from "@/methods/hooks/useCreateBackgroundImage"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"

interface Props {
  tile: TjoinedMapTile
}

export default function MapTile({ tile }: Props) {
  const runAStar = useAStar(1, 1, 30, 30, 0)

  return (
    <div
      className={style.Hex}
      style={{
        gridColumnStart: tile.x,
        gridRowStart: tile.y,
        backgroundRepeat: "no-repeat",
        backgroundSize: "cover",
        backgroundPosition: "center",
        backgroundImage: useCreateBackgroundImage(tile.image_url),
      }}
      onClick={runAStar}>
      <div>
        {tile.x}, {tile.y}
      </div>
    </div>
  )
}
