"use client"

import style from "@/components/styles/MapTile.module.css"
import { TJoinedCityTiles } from "@/methods/functions/joinCityTiles"
import { useCreateImage } from "@/methods/hooks/mapTiles/useCreateImage"

interface Props {
  tile: TJoinedCityTiles
}

export default function CityTile({ tile }: Props) {
  const { createLandscapeImage, createBackgroundImage, combineImages } = useCreateImage()

  const backgroundImage = createBackgroundImage(tile.terrainTypes.image_url)
  const landscapeImage = createLandscapeImage(tile.landscapeTypes?.image_url)

  const combinedImages = combineImages(landscapeImage, backgroundImage)

  return (
    <div
      className={style.BackgroundImage}
      style={{
        gridColumnStart: tile.cityTiles.x,
        gridRowStart: tile.cityTiles.y,
        backgroundImage: combinedImages,
      }}>
      <div>
        {tile.cityTiles.x}, {tile.cityTiles.y}
      </div>
    </div>
  )
}
