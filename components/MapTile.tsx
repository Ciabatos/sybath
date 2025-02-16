"use server"

import style from "./styles/MapTile.module.css"
import type { TjoinedMapTilesObj } from "./MapTiles"

export default async function MapTile({ tile }: { tile: TjoinedMapTilesObj }) {
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
