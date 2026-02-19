"use client"

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
import { TInventoryInventorySlotTypesRecordById } from "@/db/postgresMainDatabase/schemas/inventory/inventorySlotTypes"
import { TPlayerGearInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/playerGearInventory"
import { TPlayerInventoryRecordBySlotId } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"
import { TActivePlayerRecordById } from "@/db/postgresMainDatabase/schemas/players/activePlayer"
import { TActivePlayerProfileRecordByName } from "@/db/postgresMainDatabase/schemas/players/activePlayerProfile"
import { TActivePlayerSwitchProfilesRecordById } from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"
import { TKnownMapRegionRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import { TKnownPlayersPositionsRecordByXY } from "@/db/postgresMainDatabase/schemas/world/knownPlayersPositions"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TPlayerMapRecordByMapId } from "@/db/postgresMainDatabase/schemas/world/playerMap"
import { TPlayerMovementRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { TPlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { TPlayersOnTheSameTileRecordByOtherPlayerId } from "@/db/postgresMainDatabase/schemas/world/playersOnTheSameTile"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandlingData"
import { TAreaRecordByXY } from "@/methods/hooks/world/composite/useMapTilesArea"
import { EPanelsBottomCenterBar } from "@/types/enumeration/EPanelsBottomCenterBar"
import { EPanelsLeftCenter } from "@/types/enumeration/EPanelsLeftCenter"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import { EPanelsTopCenterBar } from "@/types/enumeration/EPanelsTopCenterBar"
import { atom } from "jotai"
import { TKnownMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"

//Modals
export const modalBottomCenterBarAtom = atom<EPanelsBottomCenterBar>(EPanelsBottomCenterBar.Inactive)
export const modalLeftTopBarAtom = atom<EPanelsLeftTopBar>(EPanelsLeftTopBar.PanelLeftSidebarPlayerMenu)
export const modalRightCenterAtom = atom<EPanelsRightCenter>(EPanelsRightCenter.Inactive)
export const modalTopCenterAtom = atom<EPanelsTopCenter>(EPanelsTopCenter.Inactive)
export const modalTopCenterBarAtom = atom<EPanelsTopCenterBar>(EPanelsTopCenterBar.Inactive)
export const modalLeftCenterAtom = atom<EPanelsLeftCenter>(EPanelsLeftCenter.Inactive)

//City
export const clickedCityTileAtom = atom<number>(0)

//Map
export const clickedTileAtom = atom<TMapTile>()

//Player
export const playerIdAtom = atom<number>(0)
export const playerMovementPlannedAtom = atom<TPlayerMovementRecordByXY>({})
export const playerMapTilesGuardAreaAtom = atom<TAreaRecordByXY>({})

//Tables
export const mapTilesAtom = atom<TWorldMapTilesRecordByXY>({})
export const inventorySlotTypesAtom = atom<TInventoryInventorySlotTypesRecordById>({})
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
export const landscapeTypesAtom = atom<TWorldLandscapeTypesRecordById>({})

//Functions
export const knownMapTilesAtom = atom<TKnownMapTilesRecordByXY>({})
export const knownMapRegionAtom = atom<TKnownMapRegionRecordByMapTileXMapTileY>({})
export const playersOnTheSameTileAtom = atom<TPlayersOnTheSameTileRecordByOtherPlayerId>({})
export const knownPlayersPositionsAtom = atom<TKnownPlayersPositionsRecordByXY>({})
export const playerMovementAtom = atom<TPlayerMovementRecordByXY>({})
export const playerGearInventoryAtom = atom<TPlayerGearInventoryRecordBySlotId>({})
export const playerStatsAtom = atom<TPlayerStatsRecordByStatId>({})
export const playerSkillsAtom = atom<TPlayerSkillsRecordBySkillId>({})
export const buildingInventoryAtom = atom<TBuildingInventoryRecordBySlotId>({})
export const districtInventoryAtom = atom<TDistrictInventoryRecordBySlotId>({})
export const activePlayerSwitchProfilesAtom = atom<TActivePlayerSwitchProfilesRecordById>({})
export const activePlayerProfileAtom = atom<TActivePlayerProfileRecordByName>({})
export const activePlayerAtom = atom<TActivePlayerRecordById>({})
export const playerCityAtom = atom<TPlayerCityRecordByCityId>({})
export const playerMapAtom = atom<TPlayerMapRecordByMapId>({})
export const playerInventoryAtom = atom<TPlayerInventoryRecordBySlotId>({})
export const playerPositionAtom = atom<TPlayerPositionRecordByXY>({})
export const playerAbilitiesAtom = atom<TPlayerAbilitiesRecordByAbilityId>({})
