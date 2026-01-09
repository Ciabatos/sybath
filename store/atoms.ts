"use client"

import { TMapTile } from "@/components/map/Map"
import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TPlayerAbilitiesRecordByAbilityId } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { TPlayerSkillsRecordBySkillId } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { TPlayerStatsRecordByStatId } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { TBuildingsBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { TPlayerCityRecordByCityId } from "@/db/postgresMainDatabase/schemas/cities/playerCity"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TBuildingInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import { TDistrictInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"
import { TPlayerInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TPlayerMapRecordByMapId } from "@/db/postgresMainDatabase/schemas/world/playerMap"
import { TPlayerMovementRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { TPlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TAreaRecordByXY } from "@/methods/hooks/world/composite/useMapTilesArea"
import { TMapTilesMovementPathRecordByXY } from "@/methods/hooks/world/composite/useMapTilesPathFromPointToPoint"
import { EPanelsBottomCenterBar } from "@/types/enumeration/EPanelsBottomCenterBar"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import { atom } from "jotai"

//Modals
export const modalBottomCenterBarAtom = atom<EPanelsBottomCenterBar>(EPanelsBottomCenterBar.Inactive)
export const modalLeftTopBarAtom = atom<EPanelsLeftTopBar>(EPanelsLeftTopBar.PanelPlayerPortrait)
export const modalRightCenterAtom = atom<EPanelsRightCenter>(EPanelsRightCenter.Inactive)
export const modalTopCenterAtom = atom<EPanelsTopCenter>(EPanelsTopCenter.Inactive)

//City
export const clickedCityTileAtom = atom<number>(0)

//Map
export const clickedTileAtom = atom<TMapTile>()

//Player
export const playerIdAtom = atom<number>(0)
export const playerMapTilesMovementPathAtom = atom<TMapTilesMovementPathRecordByXY>({})
export const playerMapTilesGuardAreaAtom = atom<TAreaRecordByXY>({})

//Tables
export const itemsAtom = atom<TItemsItemsRecordById>({})
export const districtsAtom = atom<TDistrictsDistrictsRecordByMapTileXMapTileY>({})
export const districtTypesAtom = atom<TDistrictsDistrictTypesRecordById>({})
export const cityTilesAtom = atom<TCitiesCityTilesRecordByXY>({})
export const citiesAtom = atom<TCitiesCitiesRecordByMapTileXMapTileY>({})
export const buildingsAtom = atom<TBuildingsBuildingsRecordByCityTileXCityTileY>({})
export const buildingTypesAtom = atom<TBuildingsBuildingTypesRecordById>({})
export const statsAtom = atom<TAttributesStatsRecordById>({})
export const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})
export const skillsAtom = atom<TAttributesSkillsRecordById>({})
export const terrainTypesAtom = atom<TWorldTerrainTypesRecordById>({})
export const mapTilesAtom = atom<TWorldMapTilesRecordByXY>({})
export const landscapeTypesAtom = atom<TWorldLandscapeTypesRecordById>({})

//Functions
export const playerCityAtom = atom<TPlayerCityRecordByCityId>({})
export const playerMapAtom = atom<TPlayerMapRecordByMapId>({})
export const buildingInventoryAtom = atom<TBuildingInventoryRecordBySlotId>({})
export const districtInventoryAtom = atom<TDistrictInventoryRecordBySlotId>({})
export const playerInventoryAtom = atom<TPlayerInventoryRecordBySlotId>({})
export const playerPositionAtom = atom<TPlayerPositionRecordByXY>({})
export const playerMovementAtom = atom<TPlayerMovementRecordByXY>({})
export const playerStatsAtom = atom<TPlayerStatsRecordByStatId>({})
export const playerSkillsAtom = atom<TPlayerSkillsRecordBySkillId>({})
export const playerAbilitiesAtom = atom<TPlayerAbilitiesRecordByAbilityId>({})
