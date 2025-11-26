"use client"

import style from "@/components/city/styles/Tile.module.css"
import { TJoinCity } from "@/methods/functions/map/joinCity"
import { useCityTilesActionStatus } from "@/methods/hooks/cities/composite/useCityTilesActionStatus"
import { useCityTilesActions } from "@/methods/hooks/cities/composite/useCityTilesActions"
import { useCreateImage } from "@/methods/hooks/world/composite/useCreateImage"

interface Props {
  tile: TJoinCity
}

export default function City({ tile }: Props) {
  const { createLandscapeImage, createBackgroundImage, creatBuildingsImage, combineImages } = useCreateImage()
  const { actualCityTileStatus, newCityTilesActionStatus } = useCityTilesActionStatus()
  const { setClickedCityTile } = useCityTilesActions()

  const backgroundImage = createBackgroundImage(tile.terrainTypes.image_url)
  const landscapeImage = createLandscapeImage(tile.landscapeTypes?.image_url)
  const buildingsImage = creatBuildingsImage(tile.buildings?.image_url)
  const combinedImages = combineImages(landscapeImage, backgroundImage, buildingsImage)

  function handleClickOnCityTile(tile: TJoinCity) {
    if (actualCityTileStatus.Inactive) {
      showBuildingActionList(tile)
    }
  }

  function showBuildingActionList(tile: TJoinCity) {
    setClickedCityTile({ x: tile.tiles.x, y: tile.tiles.y })
    //prettier-ignore
    if (actualCityTileStatus.Inactive) {
      newCityTilesActionStatus.BuildingActionList()
    }
  }
  return (
    <div
      className={style.BackgroundImage}
      onDoubleClick={() => handleClickOnCityTile(tile)}
      style={{
        gridColumnStart: tile.tiles.x,
        gridRowStart: tile.tiles.y,
        backgroundImage: combinedImages,
      }}>
      {buildingsImage && (
        <div
          className={style.BuildingsImage}
          style={{
            backgroundImage: buildingsImage,
          }}></div>
      )}
      <div>
        {tile.tiles.x}, {tile.tiles.y}
      </div>
    </div>
  )
}
