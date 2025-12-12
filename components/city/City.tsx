"use client"

import style from "@/components/city/styles/Tile.module.css"
import { TJoinCity } from "@/methods/functions/city/joinCity"
import { createImage } from "@/methods/functions/map/createImage"

interface Props {
  tile: TJoinCity
}

export default function City({ tile }: Props) {
  const { createLandscapeImage, createBackgroundImage, creatBuildingsImage, combineImages } = createImage()
  // const { actualCityTileStatus, newCityTilesActionStatus } = useCityTilesActionStatus()
  // const { setClickedCityTile } = useCityTilesActions()
  const backgroundImage = createBackgroundImage(tile.terrainTypes.imageUrl)
  const landscapeImage = createLandscapeImage(tile.landscapeTypes?.imageUrl)
  const buildingsImage = creatBuildingsImage(tile.buildingTypes?.imageUrl)
  const combinedImages = combineImages(landscapeImage, backgroundImage, buildingsImage)

  // function handleClickOnCityTile(tile: TJoinCity) {
  //   if (actualCityTileStatus.Inactive) {
  //     showBuildingActionList(tile)
  //   }
  // }

  // function showBuildingActionList(tile: TJoinCity) {
  //   setClickedCityTile({ x: tile.tiles.x, y: tile.tiles.y })
  //   //prettier-ignore
  //   if (actualCityTileStatus.Inactive) {
  //     newCityTilesActionStatus.BuildingActionList()
  //   }
  // }
  return (
    <div
      className={style.BackgroundImage}
      onDoubleClick={() => null} //handleClickOnCityTile(tile)}
      style={{
        gridColumnStart: tile.tiles.x,
        gridRowStart: tile.tiles.y,
        backgroundImage: combinedImages,
      }}
    >
      {buildingsImage && (
        <div
          className={style.BuildingsImage}
          style={{
            backgroundImage: buildingsImage,
          }}
        ></div>
      )}
      <div>
        {tile.tiles.x}, {tile.tiles.y}
      </div>
    </div>
  )
}
