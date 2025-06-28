"use client"

import style from "@/components/city/styles/Tile.module.css"
import { TJoinedCityTiles } from "@/methods/functions/joinCityTiles"
import { useCityTilesManipulation } from "@/methods/hooks/cityTiles/composite/useCityTilesManipulation"
import { useCityTilesActionStatus } from "@/methods/hooks/cityTiles/core/useCityTilesActionStatus"
import { useCreateImage } from "@/methods/hooks/mapTiles/core/useCreateImage"

interface Props {
  tile: TJoinedCityTiles
}

export default function CityTile({ tile }: Props) {
  const { createLandscapeImage, createBackgroundImage, creatBuildingsImage, combineImages } = useCreateImage()
  const { actualCityTileStatus, newCityTilesActionStatus } = useCityTilesActionStatus()
  const { setClickedCityTile } = useCityTilesManipulation()

  const backgroundImage = createBackgroundImage(tile.terrainTypes.image_url)
  const landscapeImage = createLandscapeImage(tile.landscapeTypes?.image_url)
  const buildingsImage = creatBuildingsImage(tile.buildings?.image_url)
  const combinedImages = combineImages(landscapeImage, backgroundImage, buildingsImage)

  function handleClickOnCityTile(tile: TJoinedCityTiles) {
    if (actualCityTileStatus.Inactive) {
      showBuildingActionList(tile)
    }
  }

  function showBuildingActionList(tile: TJoinedCityTiles) {
    setClickedCityTile(tile)
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
        gridColumnStart: tile.cityTiles.x,
        gridRowStart: tile.cityTiles.y,
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
        {tile.cityTiles.x}, {tile.cityTiles.y}
      </div>
    </div>
  )
}
