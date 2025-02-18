"use client"

import style from "./styles/MapTile.module.css"
import type { TjoinedMapTile } from "@/functions/map/mapTilesServerData"

export default function MapTile({ tile }: { tile: TjoinedMapTile }) {
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
