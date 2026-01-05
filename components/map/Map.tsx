"use client"

import style from "@/components/map/styles/Tile.module.css"
import { TCitiesCities } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistricts } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypes } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TWorldLandscapeTypes } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTiles } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { TWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { createImage } from "@/methods/functions/map/createImage"

interface Props {
  mapTiles: TWorldMapTiles
  terrainTypes: TWorldTerrainTypes
  landscapeTypes?: TWorldLandscapeTypes
  cities?: TCitiesCities
  districts?: TDistrictsDistricts
  districtTypes?: TDistrictsDistrictTypes
  playerPosition?: TPlayerPosition
}

export default function Map(props: Props) {
  const {
    createPlayerImage,
    createLandscapeImage,
    createBackgroundImage,
    createCitiesImage,
    creatDistrictsImage,
    combineImages,
  } = createImage()
  // const { handleClickOnMapTile } = useMapTileActions()
  const backgroundImage = createBackgroundImage(props.terrainTypes.imageUrl)
  const landscapeImage = createLandscapeImage(props.landscapeTypes?.imageUrl)
  const playerImage = createPlayerImage(props.playerPosition?.imageUrl)
  const citiesImage = createCitiesImage(props.cities?.imageUrl)
  const districtsImage = creatDistrictsImage(props.districtTypes?.imageUrl)
  const combinedImages = combineImages(landscapeImage, backgroundImage)

  // console.log("Map Tile Rendered:", props.mapTiles.x, props.mapTiles.y)
  return (
    <div
      className={style.BackgroundImage}
      // onDoubleClick={() => handleClickOnMapTile(props)}
      style={{
        gridColumnStart: props.mapTiles.x,
        gridRowStart: props.mapTiles.y,
        backgroundImage: combinedImages,
      }}
    >
      {citiesImage && (
        <div
          className={style.CitiesImage}
          style={{
            backgroundImage: citiesImage,
          }}
        ></div>
      )}
      {districtsImage && (
        <div
          className={style.DistrictsImage}
          style={{
            backgroundImage: districtsImage,
          }}
        ></div>
      )}
      {playerImage && (
        <div
          className={style.PlayerImage}
          style={{
            backgroundImage: playerImage,
          }}
        ></div>
      )}
      <div>
        {props.mapTiles.x}, {props.mapTiles.y}, {props.cities?.name}, {props.districts?.name}
        {/* <LayersHandling props={props} /> */}
      </div>
    </div>
  )
}
