"use client"

import style from "@/components/city/styles/Tile.module.css"
import { TBuildingsBuildings } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { TBuildingsBuildingTypes } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { TCitiesCityTiles } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { TWorldLandscapeTypes } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"

interface Props {
  cityTiles: TCitiesCityTiles
  terrainTypes: TWorldTerrainTypes
  landscapeTypes?: TWorldLandscapeTypes
  buildings?: TBuildingsBuildings
  buildingTypes?: TBuildingsBuildingTypes
}

export default function City(props: Props) {
  const { createLandscapeImage, createBackgroundImage, creatBuildingsImage, combineImages } = createBackgroundImage()
  // const { actualCityTileStatus, newCityTilesActionStatus } = useCityTilesActionStatus()
  // const { setClickedCityTile } = useCityTilesActions()
  const backgroundImage = createBackgroundImage(props.terrainTypes.imageUrl)
  const landscapeImage = createLandscapeImage(props.landscapeTypes?.imageUrl)
  const buildingsImage = creatBuildingsImage(props.buildingTypes?.imageUrl)
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
        gridColumnStart: props.cityTiles.x,
        gridRowStart: props.cityTiles.y,
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
        {props.cityTiles.x}, {props.cityTiles.y}
      </div>
    </div>
  )
}
