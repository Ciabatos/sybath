"use client"

import { TActionTaskInProcess } from "@/app/api/map-tiles/action-task-in-process/route"
import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { TBuildingsBuildingsRecordByCityIdCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { TCitiesCitiesRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TCitiesCityTilesRecordByCityIdXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TDistrictsDistrictsRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TItemsItemStatsRecordByItemId } from "@/db/postgresMainDatabase/schemas/items/itemStats"
import { TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"
import { TPlayerAbilitiesRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/players/playerAbilities"
import { TPlayerSkillsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/players/playerSkills"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTilesRecordByMapIdXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TWorldMapTilesPlayersPositionsRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"
import { TWorldMapsRecordById } from "@/db/postgresMainDatabase/schemas/world/maps"
import { TPlayerVisibleMapData, TPlayerVisibleMapDataRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/playerVisibleMapData"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
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
// export const cityTilesActionStatusAtom = atom<ECityTilesActionStatus>(ECityTilesActionStatus.Inactive)

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
export const mapTilesAtom = atom<TWorldMapTilesRecordByMapIdXY>({})
export const itemStatsAtom = atom<TItemsItemStatsRecordByItemId>({})
export const itemsAtom = atom<TItemsItemsRecordById>({})
export const districtsAtom = atom<TDistrictsDistrictsRecordByMapIdMapTileXMapTileY>({})
export const districtTypesAtom = atom<TDistrictsDistrictTypesRecordById>({})
export const cityTilesAtom = atom<TCitiesCityTilesRecordByCityIdXY>({})
export const citiesAtom = atom<TCitiesCitiesRecordByMapIdMapTileXMapTileY>({})
export const buildingsAtom = atom<TBuildingsBuildingsRecordByCityIdCityTileXCityTileY>({})
export const buildingTypesAtom = atom<TBuildingsBuildingTypesRecordById>({})
export const statsAtom = atom<TAttributesStatsRecordById>({})
export const skillsAtom = atom<TAttributesSkillsRecordById>({})
export const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})
export const terrainTypesAtom = atom<TWorldTerrainTypesRecordById>({})
export const mapsAtom = atom<TWorldMapsRecordById>({})
export const landscapeTypesAtom = atom<TWorldLandscapeTypesRecordById>({})
export const mapTilesPlayersPositionsAtom = atom<TWorldMapTilesPlayersPositionsRecordByMapIdMapTileXMapTileY>({})

//Functions
export const playerSkillsAtom = atom<TPlayerSkillsRecordByPlayerId>({})
export const playerAbilitiesAtom = atom<TPlayerAbilitiesRecordByPlayerId>({})
export const movementActionInProcessAtom = atom<TMovementActionInProcessRecordByScheduledAt>({})
export const playerVisibleMapDataAtom = atom<TPlayerVisibleMapDataRecordByMapTileXMapTileY>({})
