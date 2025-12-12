"use client"

import LayersHandling from "@/components/map/layers/LayersHandling"
import style from "@/components/map/styles/Tile.module.css"
import { createImage } from "@/methods/functions/map/createImage"
import { TJoinMap } from "@/methods/functions/map/joinMap"

interface Props {
  tile: TJoinMap
}

export default function Map({ tile }: Props) {
  const {
    createPlayerImage,
    createLandscapeImage,
    createBackgroundImage,
    createCitiesImage,
    creatDistrictsImage,
    combineImages,
  } = createImage()
  // const { handleClickOnMapTile } = useMapTileActions()
  const backgroundImage = createBackgroundImage(tile.terrainTypes.imageUrl)
  const landscapeImage = createLandscapeImage(tile.landscapeTypes?.imageUrl)
  const playerImage = createPlayerImage(tile.playerVisibleMapData?.playerImageUrl)
  const citiesImage = createCitiesImage(tile.cities?.imageUrl)
  const districtsImage = creatDistrictsImage(tile.districtTypes?.imageUrl)
  const combinedImages = combineImages(landscapeImage, backgroundImage)
  return (
    <div
      className={style.BackgroundImage}
      // onDoubleClick={() => handleClickOnMapTile(tile)}
      style={{
        gridColumnStart: tile.tiles.x,
        gridRowStart: tile.tiles.y,
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
        {tile.tiles.x}, {tile.tiles.y}, {tile.cities?.name}, {tile.districts?.name}
        <LayersHandling tile={tile} />
      </div>
    </div>
  )
}
