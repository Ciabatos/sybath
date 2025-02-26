"use client"

import style from "./styles/MapTile.module.css"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"

interface Props {
  tile: TjoinedMapTile
}

export default function MapTile({ tile }: Props) {
  return (
    <div
      className={style.Hex}
      style={{
        gridColumnStart: tile.x,
        gridRowStart: tile.y,
        backgroundRepeat: "no-repeat",
      }}>
      <div>
        {tile.x}, {tile.y}
      </div>
    </div>
  )
}
