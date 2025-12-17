"use client"

import { TActionTaskInProcess } from "@/app/api/deprecated/map-tiles/action-task-in-process/route"
import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TGetPlayerAbilitiesRecordByAbilityId } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerAbilities"
import { TGetPlayerSkillsRecordBySkillId } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerSkills"
import { TGetPlayerStatsRecordByStatId } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerStats"
import { TAttributesPlayerAbilitiesRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { TAttributesPlayerSkillsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { TAttributesPlayerStatsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { TBuildingsBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TGetPlayerInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/getPlayerInventory"
import { TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"
import { TGetActivePlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerPosition"
import { TGetActivePlayerVisionPlayersPositionsRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerVisionPlayersPositions"
import { TGetPlayerMovementRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getPlayerMovement"
import { TGetPlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getPlayerPosition"
import { TGetPlayerVisionPlayersPositionsRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getPlayerVisionPlayersPositions"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TWorldMapTilesPlayersPositionsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"
import { TWorldMapsRecordById } from "@/db/postgresMainDatabase/schemas/world/maps"
import { TPlayerVisibleMapData } from "@/db/postgresMainDatabase/schemas/world/playerVisibleMapData"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TJoinCityByXY } from "@/methods/functions/city/joinCity"
import { TJoinMap, TJoinMapByXY } from "@/methods/functions/map/joinMap"
import { TClickeCityTile } from "@/methods/hooks/cities/composite/useCityTilesActions"
import { TAreaRecordByXY } from "@/methods/hooks/world/composite/useMapTilesArea"
import { TMapTilesMovementPathRecordByXY } from "@/methods/hooks/world/composite/useMapTilesPathFromPointToPoint"
import { EPanels } from "@/types/enumeration/EPanels"
import { atom } from "jotai"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TWorldMapsRecordById } from "@/db/postgresMainDatabase/schemas/world/maps"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"

//Modals
export const modalBottomCenterBarAtom = atom<EPanels>(EPanels.Inactive)
export const modalLeftTopBarAtom = atom<EPanels>(EPanels.Inactive)
export const modalRightCenterAtom = atom<EPanels>(EPanels.Inactive)
export const modalTopCenterAtom = atom<EPanels>(EPanels.Inactive)

//Map

export const joinedMapAtom = atom<TJoinMapByXY>({})

//Map Set

//City
export const clickedCityTileAtom = atom<TClickeCityTile>()
export const joinedCityAtom = atom<TJoinCityByXY>({})

//Player
export const playerIdAtom = atom<number>(0)
export const playerPositionMapTilesAtom = atom<TPlayerVisibleMapData>()
export const playerInventorySlotsAtom = atom<TInventorySlots[]>([])

//Districts
export const districtInventorySlotsAtom = atom<TInventorySlots[]>([])

//Buildings
export const buildingInventorySlotsAtom = atom<TInventorySlots[]>([])

//REFACTORED

//City
export const cityIdAtom = atom<number>()
//Map
export const clickedTileAtom = atom<TJoinMap>()
export const mapIdAtom = atom<number>()

//Player
export const playerMapTilesMovementPathAtom = atom<TMapTilesMovementPathRecordByXY>({})
export const playerMapTilesGuardAreaAtom = atom<TAreaRecordByXY>({})
//Tasks
export const actionTaskInProcessAtom = atom<TActionTaskInProcess>()

//Tables
export const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})
export const terrainTypesAtom = atom<TWorldTerrainTypesRecordById>({})
export const mapsAtom = atom<TWorldMapsRecordById>({})
export const mapTilesAtom = atom<TWorldMapTilesRecordByXY>({})
export const landscapeTypesAtom = atom<TWorldLandscapeTypesRecordById>({})
export const mapTilesPlayersPositionsAtom = atom<TWorldMapTilesPlayersPositionsRecordByMapTileXMapTileY>({})
export const terrainTypesAtom = atom<TWorldTerrainTypesRecordById>({})
export const mapsAtom = atom<TWorldMapsRecordById>({})
export const mapTilesAtom = atom<TWorldMapTilesRecordByXY>({})
export const landscapeTypesAtom = atom<TWorldLandscapeTypesRecordById>({})
export const itemsAtom = atom<TItemsItemsRecordById>({})
export const districtsAtom = atom<TDistrictsDistrictsRecordByMapTileXMapTileY>({})
export const districtTypesAtom = atom<TDistrictsDistrictTypesRecordById>({})
export const cityTilesAtom = atom<TCitiesCityTilesRecordByXY>({})
export const citiesAtom = atom<TCitiesCitiesRecordByMapTileXMapTileY>({})
export const buildingsAtom = atom<TBuildingsBuildingsRecordByCityTileXCityTileY>({})
export const buildingTypesAtom = atom<TBuildingsBuildingTypesRecordById>({})
export const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})
export const statsAtom = atom<TAttributesStatsRecordById>({})
export const skillsAtom = atom<TAttributesSkillsRecordById>({})
export const playerStatsAtom = atom<TAttributesPlayerStatsRecordByPlayerId>({})
export const playerSkillsAtom = atom<TAttributesPlayerSkillsRecordByPlayerId>({})
export const playerAbilitiesAtom = atom<TAttributesPlayerAbilitiesRecordByPlayerId>({})

//Functions
export const getPlayerVisionPlayersPositionsAtom = atom<TGetPlayerVisionPlayersPositionsRecordByXY>({})
export const getPlayerPositionAtom = atom<TGetPlayerPositionRecordByXY>({})
export const getPlayerMovementAtom = atom<TGetPlayerMovementRecordByXY>({})

export const getActivePlayerVisionPlayersPositionsAtom = atom<TGetActivePlayerVisionPlayersPositionsRecordByXY>({})
export const getPlayerStatsAtom = atom<TGetPlayerStatsRecordByStatId>({})
export const getPlayerSkillsAtom = atom<TGetPlayerSkillsRecordBySkillId>({})
export const getPlayerAbilitiesAtom = atom<TGetPlayerAbilitiesRecordByAbilityId>({})

export const getActivePlayerPositionAtom = atom<TGetActivePlayerPositionRecordByXY>({})

export const getPlayerInventoryAtom = atom<TGetPlayerInventoryRecordBySlotId>({})
// export const getPlayerInventoryAtom = atom<TGetPlayerInventoryRecordBySlotId>({})
// export const playerSkillsAtom = atom<TPlayerSkillsRecordByPlayerId>({})
// export const playerAbilitiesAtom = atom<TPlayerAbilitiesRecordByPlayerId>({})
// export const movementActionInProcessAtom = atom<TMovementActionInProcessRecordByScheduledAt>({})
// export const playerVisibleMapDataAtom = atom<TPlayerVisibleMapDataRecordByMapTileXMapTileY>({})
