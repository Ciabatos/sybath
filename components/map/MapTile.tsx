"use client"

import LayersHandling from "@/components/map/layers/LayersHandling"
import style from "@/components/map/styles/Tile.module.css"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useMapTileActions } from "@/methods/hooks/mapTiles/composite/useMapTileActions"
import { useCreateImage } from "@/methods/hooks/mapTiles/core/useCreateImage"

interface Props {
  tile: TJoinedMapTile
}

export default function MapTile({ tile }: Props) {
  const { createPlayerImage, createLandscapeImage, createBackgroundImage, createCitiesImage, creatDistrictsImage, combineImages } = useCreateImage()
  const { handleClickOnMapTile } = useMapTileActions()

  const backgroundImage = createBackgroundImage(tile.terrainTypes.image_url)
  const landscapeImage = createLandscapeImage(tile.landscapeTypes?.image_url)
  const playerImage = createPlayerImage(tile.playerVisibleMapData?.player_image_url)
  const citiesImage = createCitiesImage(tile.cities?.image_url)
  const districtsImage = creatDistrictsImage(tile.districts?.image_url)
  const combinedImages = combineImages(landscapeImage, backgroundImage)

  return (
    <div
      className={style.BackgroundImage}
      onDoubleClick={() => handleClickOnMapTile(tile)}
      style={{
        gridColumnStart: tile.mapTile.x,
        gridRowStart: tile.mapTile.y,
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
        {tile.mapTile.x}, {tile.mapTile.y}, {tile.cities?.name}, {tile.districts?.name}
        <LayersHandling tile={tile} />
      </div>
    </div>
  )
}
