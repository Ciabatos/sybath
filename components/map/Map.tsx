"use client"

import TileLayersHandling from "@/components/map/layers/tileLayers/TileLayersHandling"
import style from "@/components/map/styles/Tile.module.css"
import { createImage } from "@/methods/functions/util/createImage"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandlingData"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"

export default function Map(props: TMapTile) {
  const { handleClickOnMapTile } = useMapTileActions()

  const handleClick = () => {
    handleClickOnMapTile(props)
  }

  if (!props.terrainTypes) {
    return (
      <div
        className={style.BackgroundImage}
        onDoubleClick={handleClick}
        style={{
          gridColumnStart: props.mapTiles.x,
          gridRowStart: props.mapTiles.y,
        }}
      >
        <TileLayersHandling {...props} />
      </div>
    )
  }

  const {
    createPlayerImage,
    createLandscapeImage,
    createTerrainImage,
    createCitiesImage,
    creatDistrictsImage,
    combineImages,
  } = createImage()

  const backgroundImage = createTerrainImage(props.terrainTypes.imageUrl)
  const landscapeImage = createLandscapeImage(props.landscapeTypes?.imageUrl)
  const playerImage = createPlayerImage(props.playerPosition?.imageMap)
  const otherPlayerImage = createPlayerImage(props.knownPlayersPositions?.imageMap)
  const citiesImage = createCitiesImage(props.cities?.imageUrl)
  const districtsImage = creatDistrictsImage(props.districtTypes?.imageUrl)
  const combinedImages = combineImages(landscapeImage, backgroundImage)

  return (
    <div
      className={style.BackgroundImage}
      onDoubleClick={handleClick}
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
      {otherPlayerImage && (
        <div
          className={style.PlayerImage}
          style={{
            backgroundImage: otherPlayerImage,
          }}
        ></div>
      )}
      <div>
        {props.mapTiles.x}, {props.mapTiles.y}, {props.cities?.name}, {props.districts?.name}
        <TileLayersHandling {...props} />
      </div>
    </div>
  )
}
