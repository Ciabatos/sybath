"use client"

import style from "./styles/MapTile.module.css"
import type { TjoinedMapTiles } from "./MapTilesServer"

export default function MapTile({ tile }: { tile: TjoinedMapTiles }) {
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
