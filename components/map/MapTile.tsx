"use client"

import PlannedRouteLayer from "@/components/map/layers/movement/PlannedRouteLayer"
import style from "@/components/map/styles/MapTile.module.css"
import { createImage } from "@/methods/functions/util/createImage"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { ReactNode } from "react"

type TProps = {
  mapTile: TMapTile
  /** Warstwy przekazane przez `MapHandling` — liczniki i ikony. */
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

  const { mapTiles, terrainTypes, landscapeTypes, cities, districts, districtTypes, playerPosition } = mapTile

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
          <PlannedRouteLayer {...mapTile} />
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

        Kolejność ma znaczenie i jest jawna tutaj: plan ruchu idzie pierwszy,
        więc liczniki i ikony z `layers/` lądują na wierzchu.
      */}
      <div className={style.layers}>
        <PlannedRouteLayer {...mapTile} />
        {layers}
      </div>

      {playerPosition && (
        <span className={style.playerMarker}>
          <span
            className={style.playerAvatar}
            style={{ backgroundImage: playerImage }}
          />
        </span>
      )}

      <div className={style.debugText}>
        {mapTiles.x}, {mapTiles.y}, {cities?.name}, {districts?.name}
      </div>
    </div>
  )
}
