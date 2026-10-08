"use client"

import MapTileLayerHandling from "@/components/map/layers/mapTileLayers/MapTileLayerHandling"
import style from "@/components/map/styles/MapTile.module.css"
import { createImage } from "@/methods/functions/util/createImage"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { ReactNode } from "react"

type TProps = {
  mapTile: TMapTile
  layers?: ReactNode
}

// `createImage` jest czyste (tylko buduje closure'y), więc wywołanie raz na
// moduł zamiast raz na każdy render każdego kafelka. Przy kilkuset kafelkach
// to oszczędza ~700 alokacji na przerysowanie.
const {
  createPlayerImage,
  createSquadImage,
  createLandscapeImage,
  createTerrainImage,
  createCitiesImage,
  creatDistrictsImage,
  combineImages,
} = createImage()

export default function MapTile({ mapTile, layers }: TProps) {
  const { handleClickOnMapTile } = useMapTileActions()

  const {
    mapTiles,
    terrainTypes,
    landscapeTypes,
    cities,
    districts,
    districtTypes,
    playerPosition,
    knownPlayersPositions,
  } = mapTile

  const handleClick = () => {
    handleClickOnMapTile(mapTile)
  }

  const gridPlacement = {
    gridColumnStart: mapTiles.x,
    gridRowStart: mapTiles.y,
  }

  // Kafel bez typu terenu nie jest jeszcze odkryty — pusty, sam w sobie.
  if (!terrainTypes) {
    return (
      <div
        className={style.tile}
        onDoubleClick={handleClick}
        style={gridPlacement}
      >
        <div className={style.layers}>
          <MapTileLayerHandling {...mapTile} />
        </div>
      </div>
    )
  }

  const inSquad = playerPosition?.inSquad === true

  const terrainImage = createTerrainImage(terrainTypes.imageUrl)
  const landscapeImage = createLandscapeImage(landscapeTypes?.imageUrl)
  const citiesImage = createCitiesImage(cities?.imageUrl)
  const districtsImage = creatDistrictsImage(districtTypes?.imageUrl)

  // Jedna gałąź zamiast dwóch identycznych bloków różniących się obrazem.
  const playerImage = playerPosition
    ? inSquad
      ? createSquadImage(playerPosition.imageMap)
      : createPlayerImage(playerPosition.imageMap)
    : ""

  const otherPlayers = knownPlayersPositions?.otherPlayers ?? []

  return (
    <div
      className={style.tile}
      onDoubleClick={handleClick}
      style={{
        ...gridPlacement,
        backgroundImage: combineImages(landscapeImage, terrainImage),
      }}
    >
      {citiesImage && (
        <div
          className={style.CitiesImage}
          style={{ backgroundImage: citiesImage }}
        />
      )}

      {districtsImage && (
        <div
          className={style.DistrictsImage}
          style={{ backgroundImage: districtsImage }}
        />
      )}

      {/*
        Wszystkie nakładki kafelka w jednym kontekście stackingowym i POZA
        divem debug — inaczej lądowały w przepływie tekstu.
      */}
      <div className={style.layers}>
        <MapTileLayerHandling {...mapTile} />
        {layers}
      </div>

      {otherPlayers.map((other) => {
        const otherImage = other.inSquad === true ? createSquadImage(other.imageMap) : createPlayerImage(other.imageMap)

        return (
          <span
            key={other.otherPlayerId}
            className={style.otherPlayerMarker}
            style={{ backgroundImage: otherImage }}
          />
        )
      })}

      {playerPosition && (
        <span className={style.playerMarker}>
          <span
            className={style.playerAvatar}
            style={{ backgroundImage: playerImage }}
          />
        </span>
      )}

      {otherPlayers.length > 0 && <span className={style.PopulationBadge}>{otherPlayers.length}</span>}
      <div className={style.debugText}>
        {mapTiles.x}, {mapTiles.y}, {cities?.name}, {districts?.name}
      </div>
    </div>
  )
}
