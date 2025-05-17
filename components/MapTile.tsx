"use client"

import MapTileLayerHandling from "@/components/MapTileLayerHandling"
import style from "@/components/styles/MapTile.module.css"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useCreateImage } from "@/methods/hooks/mapTiles/useCreateImage"
import { useMapTileManipulation } from "@/methods/hooks/mapTiles/useMapTilesManipulation"

interface Props {
  tile: TJoinedMapTile
}

export default function MapTile({ tile }: Props) {
  const { createPlayerImage, createLandscapeImage, createBackgroundImage, createCitiesImage, creatDistrictsImage, combineImages } = useCreateImage()
  const { handleClickOnMapTile } = useMapTileManipulation()

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
      </div>
      <MapTileLayerHandling tile={tile} />
    </div>
  )
}
