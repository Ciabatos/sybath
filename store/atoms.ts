"use client"

import { TActionTaskInProcess } from "@/app/api/map-tiles/action-task-in-process/route"
import { TAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TAbilityRequirements } from "@/db/postgresMainDatabase/schemas/attributes/abilityRequirements"
import { TSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { TInventorySlots } from "@/db/postgresMainDatabase/schemas/items/inventories"
import { TCityBuildingsByCoordinates } from "@/db/postgresMainDatabase/schemas/map/buildings"
import { TCitiesByCoordinates } from "@/db/postgresMainDatabase/schemas/map/cities"
import { TCityTiles } from "@/db/postgresMainDatabase/schemas/map/cityTiles"
import { TDistrictsByCoordinates } from "@/db/postgresMainDatabase/schemas/map/districts"
import { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/mapTiles"
import { TPlayerVisibleMapData, TPlayerVisibleMapDataByCoordinates } from "@/db/postgresMainDatabase/schemas/map/playerVisibleMapData"
import { TPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/playerAbilities"
import { TPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/playerSkills"
import { TJoinedCityTiles, TJoinedCityTilesByCoordinates } from "@/methods/functions/joinCityTiles"
import { TJoinedMapTile, TJoinedMapTileByCoordinates } from "@/methods/functions/joinMapTiles"
import { TMovementPath } from "@/methods/hooks/mapTiles/core/useMapTilesPath"

import { ECityTilesActionStatus } from "@/types/enumeration/CityTilesActionStatusEnum"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"

import { atom } from "jotai"

//Map
export const clickedTileAtom = atom<TJoinedMapTile>()
export const mapTilesAtom = atom<TMapTiles[]>([])
export const joinedMapTilesAtom = atom<TJoinedMapTileByCoordinates>({})
export const citiesAtom = atom<TCitiesByCoordinates>({})
export const districtsAtom = atom<TDistrictsByCoordinates>({})
export const mapTilesActionStatusAtom = atom<EMapTilesActionStatus>(EMapTilesActionStatus.Inactive)
export const playerVisibleMapDataAtom = atom<TPlayerVisibleMapDataByCoordinates>({})
export const mapTilesMovementPathAtom = atom<TMovementPath[]>([])
export const mapTilesGuardAreaAtom = atom<TJoinedMapTile[]>([])
//Map Set
export const mapTilesGuardAreaSetAtom = atom<Set<string>>(new Set<string>())
export const mapTilesMovementPathSetAtom = atom<Set<string>>(new Set<string>())

//City
export const clickedCityTileAtom = atom<TJoinedCityTiles>()
export const cityTilesAtom = atom<TCityTiles[]>([])
export const buildingsAtom = atom<TCityBuildingsByCoordinates>({})
export const cityTilesActionStatusAtom = atom<ECityTilesActionStatus>(ECityTilesActionStatus.Inactive)
export const joinedCityTilesAtom = atom<TJoinedCityTilesByCoordinates>({})

//Player
export const playerPositionMapTileAtom = atom<TPlayerVisibleMapData>()
export const playerInventorySlotsAtom = atom<TInventorySlots[]>([])
export const playerSkillsAtom = atom<TPlayerSkills[]>([])
export const playerAbilitiesAtom = atom<TPlayerAbilities[]>([])

//Attributes
export const selectedAbilityIdAtom = atom<number>()
export const skillsAtom = atom<TSkills[]>([])
export const abilitiesAtom = atom<TAbilities[]>([])
export const abilityRequirementsAtom = atom<TAbilityRequirements[]>([])

//Districts
export const districtInventorySlotsAtom = atom<TInventorySlots[]>([])

//Buildings
export const buildingInventorySlotsAtom = atom<TInventorySlots[]>([])

//Tasks
export const actionTaskInProcessAtom = atom<TActionTaskInProcess>()
