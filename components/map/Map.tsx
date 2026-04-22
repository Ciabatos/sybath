"use client"

import TileLayersHandling from "@/components/map/layers/tileLayers/TileLayersHandling"
import style from "@/components/map/styles/Tile.module.css"
import { createImage } from "@/methods/functions/util/createImage"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
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
    createSquadImage,
    createLandscapeImage,
    createTerrainImage,
    createCitiesImage,
    creatDistrictsImage,
    combineImages,
  } = createImage()

  const inSquad = props.playerPosition?.inSquad === true

  const backgroundImage = createTerrainImage(props.terrainTypes.imageUrl)
  const landscapeImage = createLandscapeImage(props.landscapeTypes?.imageUrl)
  const playerImage = createPlayerImage(props.playerPosition?.imageMap)
  const playerSquadImage = createSquadImage(props.playerPosition?.imageMap)
  const knownPlayersPositions = props.knownPlayersPositions?.otherPlayers ?? []
  const citiesImage = createCitiesImage(props.cities?.imageUrl)
  const districtsImage = creatDistrictsImage(props.districtTypes?.imageUrl)
  const combinedImages = combineImages(landscapeImage, backgroundImage)

  const playersCount = (props.playerPosition ? 1 : 0) + (knownPlayersPositions?.length || 0)

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
      {!inSquad && (
        <div
          className={style.PlayerImage}
          style={{ backgroundImage: playerImage }}
        />
      )}

      {inSquad && (
        <div
          className={style.PlayerImage}
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
        {props.mapTiles.x}, {props.mapTiles.y}, {props.cities?.name}, {props.districts?.name}
        <TileLayersHandling {...props} />
      </div>
    </div>
  )
}
