"use client"

import LayersHandling from "@/components/map/layers/LayersHandling"
import style from "@/components/map/styles/Tile.module.css"
import { TJoinMap } from "@/methods/functions/map/joinMap"
import { useCreateImage } from "@/methods/hooks/world/composite/useCreateImage"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"

interface Props {
  tile: TJoinMap
}

export default function Map({ tile }: Props) {
  const { createPlayerImage, createLandscapeImage, createBackgroundImage, createCitiesImage, /*creatDistrictsImage,*/ combineImages } = useCreateImage()
  const { handleClickOnMapTile } = useMapTileActions()
  const backgroundImage = createBackgroundImage(tile.terrainTypes.imageUrl)
  const landscapeImage = createLandscapeImage(tile.landscapeTypes?.imageUrl)
  const playerImage = createPlayerImage(tile.playerVisibleMapData?.playerImageUrl)
  const citiesImage = createCitiesImage(tile.cities?.imageUrl)
  const districtsImage = createCitiesImage(tile.cities?.imageUrl) //creatDistrictsImage(tile.districts?.image_url)
  const combinedImages = combineImages(landscapeImage, backgroundImage)
  return (
    <div
      className={style.BackgroundImage}
      onDoubleClick={() => handleClickOnMapTile(tile)}
      style={{
        gridColumnStart: tile.tiles.x,
        gridRowStart: tile.tiles.y,
        backgroundImage: combinedImages,
      }}>
      {citiesImage && (
        <div
          className={style.CitiesImage}
          style={{
            backgroundImage: citiesImage,
          }}></div>
      )}
      {districtsImage && (
        <div
          className={style.DistrictsImage}
          style={{
            backgroundImage: districtsImage,
          }}></div>
      )}
      {playerImage && (
        <div
          className={style.PlayerImage}
          style={{
            backgroundImage: playerImage,
          }}></div>
      )}
      <div>
        {tile.tiles.x}, {tile.tiles.y}, {tile.cities?.name}, {tile.districts?.name}
        <LayersHandling tile={tile} />
      </div>
    </div>
  )
}
