"use client"

import MapTileLayerHandling from "@/components/MapTileLayerHandling"
import style from "@/components/styles/MapTile.module.css"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useCreateImage } from "@/methods/hooks/useCreateImage"
import { useMapTileManipulation } from "@/methods/hooks/useMapTileManipulation"

interface Props {
  tile: TJoinedMapTile
}

export default function MapTile({ tile }: Props) {
  const { createPlayerImage, createLandscapeImage, createBackgroundImage, combineImages } = useCreateImage()

  const backgroundImage = createBackgroundImage(tile.terrainTypes.image_url)
  const landscapeImage = createLandscapeImage(tile.landscapeTypes?.image_url)
  const playerImage = createPlayerImage(tile.playerVisibleMapData?.player_image_url)
  const combinedImages = combineImages(landscapeImage, backgroundImage)

  const { handleClickOnMapTile } = useMapTileManipulation()

  const handleButtonClick = (x: number, y: number) => {
    handleClickOnMapTile(x, y)
  }

  return (
    <div
      className={style.BackgroundImage}
      onDoubleClick={() => handleButtonClick(tile.mapTile.x, tile.mapTile.y)}
      style={{
        gridColumnStart: tile.mapTile.x,
        gridRowStart: tile.mapTile.y,
        backgroundImage: combinedImages,
      }}>
      <div
        className={style.PlayerImage}
        style={{
          backgroundImage: playerImage,
        }}></div>
      <div>
        {tile.mapTile.x}, {tile.mapTile.y}
      </div>
      <MapTileLayerHandling tile={tile} />
    </div>
  )
}
