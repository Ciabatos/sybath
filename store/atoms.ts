"use client"

import { TActionTaskInProcess } from "@/app/api/map-tiles/action-task-in-process/route"
import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TPlayerVisibleMapData } from "@/db/postgresMainDatabase/schemas/world/playerVisibleMapData"
import { TJoinCityByXY } from "@/methods/functions/city/joinCity"
import { TJoinMapByXY } from "@/methods/functions/map/joinMap"
import { TClickeCityTile } from "@/methods/hooks/cities/composite/useCityTilesActions"
import { TMapTilesGuardAreaSet } from "@/methods/hooks/world/composite/useActionMapTilesGuardArea"
import { TMapTilesMovementPathSet } from "@/methods/hooks/world/composite/useActionMapTilesMovement"
import { TClickedTile } from "@/methods/hooks/world/composite/useMapTileActions"
import { EPanels } from "@/types/enumeration/EPanels"
import { atom } from "jotai"

//Modals
export const modalBottomCenterBarAtom = atom<EPanels>(EPanels.Inactive)
export const modalLeftTopBarAtom = atom<EPanels>(EPanels.Inactive)
export const modalRightCenterAtom = atom<EPanels>(EPanels.Inactive)
export const modalTopCenterAtom = atom<EPanels>(EPanels.Inactive)

//Map
export const clickedTileAtom = atom<TClickedTile>()
export const joinedMapAtom = atom<TJoinMapByXY>({})

//Map Set
export const mapTilesGuardAreaSetAtom = atom<TMapTilesGuardAreaSet>(new Set<string>())
export const mapTilesMovementPathSetAtom = atom<TMapTilesMovementPathSet>(new Set<string>())

//City
export const clickedCityTileAtom = atom<TClickeCityTile>()
export const joinedCityAtom = atom<TJoinCityByXY>({})

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
export const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})
// export const buildingsAtom = atom<TBuildingsBuildingsRecordByCityTileXCityTileY>({})
// export const districtsAtom = atom<TDistrictsDistrictsRecordByMapTileXMapTileY>({})
// export const citiesAtom = atom<TCitiesCitiesRecordByMapTileXMapTileY>({})
// export const mapTilesAtom = atom<TWorldMapTilesRecordByXY>({})
// export const cityTilesAtom = atom<TCitiesCityTilesRecordByXY>({})
// export const itemStatsAtom = atom<TItemsItemStatsRecordByItemId>({})
// export const itemsAtom = atom<TItemsItemsRecordById>({})
// export const districtTypesAtom = atom<TDistrictsDistrictTypesRecordById>({})
// export const buildingTypesAtom = atom<TBuildingsBuildingTypesRecordById>({})
// export const statsAtom = atom<TAttributesStatsRecordById>({})
// export const skillsAtom = atom<TAttributesSkillsRecordById>({})
// export const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})
// export const terrainTypesAtom = atom<TWorldTerrainTypesRecordById>({})
// export const mapsAtom = atom<TWorldMapsRecordById>({})
// export const landscapeTypesAtom = atom<TWorldLandscapeTypesRecordById>({})
// export const mapTilesPlayersPositionsAtom = atom<TWorldMapTilesPlayersPositionsRecordByMapIdMapTileXMapTileY>({})

//Functions
// export const getPlayerInventoryAtom = atom<TGetPlayerInventoryRecordBySlotId>({})
// export const playerSkillsAtom = atom<TPlayerSkillsRecordByPlayerId>({})
// export const playerAbilitiesAtom = atom<TPlayerAbilitiesRecordByPlayerId>({})
// export const movementActionInProcessAtom = atom<TMovementActionInProcessRecordByScheduledAt>({})
// export const playerVisibleMapDataAtom = atom<TPlayerVisibleMapDataRecordByMapTileXMapTileY>({})
