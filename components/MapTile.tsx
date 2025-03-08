"use client"

import MapTileLayerHandling from "@/components/MapTileLayerHandling"
import style from "@/components/styles/MapTile.module.css"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { useCreateBackgroundImage } from "@/methods/hooks/useCreateBackgroundImage"
import { useCreatePlayerImage } from "@/methods/hooks/useCreatePlayerImage"
import { useMapTileClick } from "@/methods/hooks/useMapTileClick"

interface Props {
  tile: TjoinedMapTile
}

export default function MapTile({ tile }: Props) {
  const backgroundImage = useCreateBackgroundImage(tile.image_url)
  const playerImage = useCreatePlayerImage(tile.player_image_url)
  const { handlieCLickOnMapTile } = useMapTileClick()

  const handleClick = (x: number, y: number) => {
    handlieCLickOnMapTile(x, y)
  }

  return (
    <>
      <div
        className={style.BackgroundImage}
        onDoubleClick={() => handleClick(tile.x, tile.y)}
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
        <MapTileLayerHandling tile={tile} />
      </div>
    </>
  )
}
