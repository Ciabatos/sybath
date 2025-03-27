"use client"

import MapTileLayerHandling from "@/components/MapTileLayerHandling"
import style from "@/components/styles/MapTile.module.css"
import { combineImages } from "@/methods/functions/combineImages"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useCreateBackgroundImage } from "@/methods/hooks/useCreateBackgroundImage"
import { useCreateLandscapeImage } from "@/methods/hooks/useCreateLandscapeImage"
import { useCreatePlayerImage } from "@/methods/hooks/useCreatePlayerImage"
import { useMapTileClickHandling } from "@/methods/hooks/useMapTileClickHandling"

interface Props {
  tile: TJoinedMapTile
}

export default function MapTile({ tile }: Props) {
  const backgroundImage = useCreateBackgroundImage(tile.terrain_image_url)
  const landscapeImage = useCreateLandscapeImage(tile.landscape_image_url)
  const playerImage = useCreatePlayerImage(tile.player_image_url)
  const combinedImages = combineImages(landscapeImage, backgroundImage)
  const { handleClickOnMapTile } = useMapTileClickHandling()

  const handleClick = (x: number, y: number) => {
    handleClickOnMapTile(x, y)
  }

  return (
    <>
      <div
        className={style.BackgroundImage}
        onDoubleClick={() => handleClick(tile.x, tile.y)}
        style={{
          gridColumnStart: tile.x,
          gridRowStart: tile.y,
          backgroundImage: combinedImages,
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
