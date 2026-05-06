"use client"

import MapTileLayerHandling from "@/components/map/layers/mapTileLayers/MapTileLayerHandling"
import style from "@/components/map/styles/MapTile.module.css"
import { createImage } from "@/methods/functions/util/createImage"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { ReactNode } from "react"

type TMapTilemapTile = {
  mapTile: TMapTile
  layers?: ReactNode
}

export default function MapTile({ mapTile, layers }: TMapTilemapTile) {
  const { handleClickOnMapTile } = useMapTileActions()

  const handleClick = () => {
    handleClickOnMapTile(mapTile)
  }

  if (!mapTile.terrainTypes) {
    return (
      <div
        className={style.BackgroundImage}
        onDoubleClick={handleClick}
        style={{
          gridColumnStart: mapTile.mapTiles.x,
          gridRowStart: mapTile.mapTiles.y,
        }}
      >
        <MapTileLayerHandling {...mapTile} />
      </div>
    )
  }

  const {
    createPlayerImage,
    createSquadImage,
    createLandscapeImage,
    createTerrainImage,
    createCitiesImage,
    creatDistrictsImage,
    combineImages,
  } = createImage()

  const inSquad = mapTile.playerPosition?.inSquad === true

  const backgroundImage = createTerrainImage(mapTile.terrainTypes.imageUrl)
  const landscapeImage = createLandscapeImage(mapTile.landscapeTypes?.imageUrl)
  const playerImage = createPlayerImage(mapTile.playerPosition?.imageMap)
  const playerSquadImage = createSquadImage(mapTile.playerPosition?.imageMap)
  const knownPlayersPositions = mapTile.knownPlayersPositions?.otherPlayers ?? []
  const citiesImage = createCitiesImage(mapTile.cities?.imageUrl)
  const districtsImage = creatDistrictsImage(mapTile.districtTypes?.imageUrl)
  const combinedImages = combineImages(landscapeImage, backgroundImage)

  const playersCount = knownPlayersPositions?.length || 0

  return (
    <div
      className={style.BackgroundImage}
      onDoubleClick={handleClick}
      style={{
        gridColumnStart: mapTile.mapTiles.x,
        gridRowStart: mapTile.mapTiles.y,
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
      {!inSquad && mapTile.playerPosition && (
        <div
          className={`${style.PlayerImage} ${style.PlayerHighlight}`}
          style={{ backgroundImage: playerImage }}
        />
      )}

      {inSquad && mapTile.playerPosition && (
        <div
          className={`${style.PlayerImage} ${style.PlayerHighlight}`}
          style={{ backgroundImage: playerSquadImage }}
        />
      )}

      {knownPlayersPositions.map((p) => {
        const isSquad = p.inSquad === true

        return (
          <div
            key={p.otherPlayerId}
            className={style.PlayerImage}
            style={{
              backgroundImage: isSquad ? createSquadImage(p.imageMap) : createPlayerImage(p.imageMap),
            }}
          />
        )
      })}
      {playersCount > 0 && <div className={style.PopulationBadge}>👥 {playersCount}</div>}
      <div>
        {mapTile.mapTiles.x}, {mapTile.mapTiles.y}, {mapTile.cities?.name}, {mapTile.districts?.name}
        <MapTileLayerHandling {...mapTile} />
        {layers}
      </div>
    </div>
  )
}
