"use client"

import { TActionTaskInProcess } from "@/app/api/deprecated/map-tiles/action-task-in-process/route"
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
import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TAttributesPlayerAbilitiesRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { TAttributesPlayerSkillsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { TAttributesPlayerStatsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { TBuildingsBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TWorldMapsRecordById } from "@/db/postgresMainDatabase/schemas/world/maps"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TWorldMapTilesPlayersPositionsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"
import { TGetPlayerInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/getPlayerInventory"
import { TGetPlayerInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/getPlayerInventory"

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
export const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})
export const statsAtom = atom<TAttributesStatsRecordById>({})
export const skillsAtom = atom<TAttributesSkillsRecordById>({})
export const playerStatsAtom = atom<TAttributesPlayerStatsRecordByPlayerId>({})
export const playerSkillsAtom = atom<TAttributesPlayerSkillsRecordByPlayerId>({})
export const playerAbilitiesAtom = atom<TAttributesPlayerAbilitiesRecordByPlayerId>({})
export const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})
export const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})
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
export const getPlayerInventoryAtom = atom<TGetPlayerInventoryRecordBySlotId>({})
export const getPlayerInventoryAtom = atom<TGetPlayerInventoryRecordBySlotId>({})
// export const getPlayerInventoryAtom = atom<TGetPlayerInventoryRecordBySlotId>({})
// export const playerSkillsAtom = atom<TPlayerSkillsRecordByPlayerId>({})
// export const playerAbilitiesAtom = atom<TPlayerAbilitiesRecordByPlayerId>({})
// export const movementActionInProcessAtom = atom<TMovementActionInProcessRecordByScheduledAt>({})
// export const playerVisibleMapDataAtom = atom<TPlayerVisibleMapDataRecordByMapTileXMapTileY>({})
