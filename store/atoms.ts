"use client"

import { TActionTaskInProcess } from "@/app/api/map-tiles/action-task-in-process/route"
import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TAbilityRequirements } from "@/db/postgresMainDatabase/schemas/attributes/abilityRequirements"
import { TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { TInventorySlots } from "@/db/postgresMainDatabase/schemas/items/inventories"
import { TPlayerInventoryRecordByRowCol } from "@/db/postgresMainDatabase/schemas/items/playerInventory"
import { TMapBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/map/buildings"
import { TMapCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/cities"
import { TMapCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/map/cityTiles"
import { TMapDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/districts"
import { TMapLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { TMapMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/map/mapTiles"
import { TMovementActionInProcessRecordByScheduledAt } from "@/db/postgresMainDatabase/schemas/map/movementActionInProcess"
import { TPlayerVisibleMapData, TPlayerVisibleMapDataRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/playerVisibleMapData"
import { TMapTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { TPlayerAbilitiesRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/players/playerAbilities"
import { TPlayerSkillsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/players/playerSkills"
import { TJoinCityByXY } from "@/methods/functions/map/joinCity"
import { TJoinMapByXY } from "@/methods/functions/map/joinMap"
import { TMapTilesGuardAreaSet } from "@/methods/hooks/map/composite/useActionMapTilesGuardArea"
import { TMapTilesMovementPathSet } from "@/methods/hooks/map/composite/useActionMapTilesMovement"
import { TClickeCityTile } from "@/methods/hooks/map/composite/useCityTilesActions"
import { TClickedTile } from "@/methods/hooks/map/composite/useMapTileActions"
import { ECityTilesActionStatus } from "@/types/enumeration/CityTilesActionStatusEnum"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { atom } from "jotai"

//Map
export const clickedTileAtom = atom<TClickedTile>()
export const joinedMapAtom = atom<TJoinMapByXY>({})
export const mapTilesActionStatusAtom = atom<EMapTilesActionStatus>(EMapTilesActionStatus.Inactive)

//Map Set
export const mapTilesGuardAreaSetAtom = atom<TMapTilesGuardAreaSet>(new Set<string>())
export const mapTilesMovementPathSetAtom = atom<TMapTilesMovementPathSet>(new Set<string>())

//City
export const clickedCityTileAtom = atom<TClickeCityTile>()
export const joinedCityAtom = atom<TJoinCityByXY>({})
export const cityTilesActionStatusAtom = atom<ECityTilesActionStatus>(ECityTilesActionStatus.Inactive)

//Player
export const playerIdAtom = atom<number>(0)
export const playerPositionMapTileAtom = atom<TPlayerVisibleMapData>()
export const playerInventorySlotsAtom = atom<TInventorySlots[]>([])

//Attributes
export const selectedAbilityIdAtom = atom<number>()
export const abilityRequirementsAtom = atom<TAbilityRequirements[]>([])

//Districts
export const districtInventorySlotsAtom = atom<TInventorySlots[]>([])

//Buildings
export const buildingInventorySlotsAtom = atom<TInventorySlots[]>([])

//Tasks
export const actionTaskInProcessAtom = atom<TActionTaskInProcess>()

//Tables
export const cityTilesAtom = atom<TMapCityTilesRecordByXY>({})
export const skillsAtom = atom<TAttributesSkillsRecordById>({})
export const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})
export const districtsAtom = atom<TMapDistrictsRecordByMapTileXMapTileY>({})
export const citiesAtom = atom<TMapCitiesRecordByMapTileXMapTileY>({})
export const landscapeTypesAtom = atom<TMapLandscapeTypesRecordById>({})
export const mapTilesAtom = atom<TMapMapTilesRecordByXY>({})
export const terrainTypesAtom = atom<TMapTerrainTypesRecordById>({})
export const buildingsAtom = atom<TMapBuildingsRecordByCityTileXCityTileY>({})

//Functions
export const movementActionInProcessAtom = atom<TMovementActionInProcessRecordByScheduledAt>({})
export const playerVisibleMapDataAtom = atom<TPlayerVisibleMapDataRecordByMapTileXMapTileY>({})
export const playerInventoryAtom = atom<TPlayerInventoryRecordByRowCol>({})
export const playerAbilitiesAtom = atom<TPlayerAbilitiesRecordByPlayerId>({})
export const playerSkillsAtom = atom<TPlayerSkillsRecordByPlayerId>({})
