"use client"

import { TAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TAbilityRequirements } from "@/db/postgresMainDatabase/schemas/attributes/abilityRequirements"
import { TSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { TPlayerVisibleMapData, TPlayerVisibleMapDataById } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import { TCityBuildingsMapCoordinates } from "@/db/postgresMainDatabase/schemas/map/tables/buildings"
import { TCitiesByMapCoordinates } from "@/db/postgresMainDatabase/schemas/map/tables/cities"
import { TCityTiles } from "@/db/postgresMainDatabase/schemas/map/tables/cityTiles"
import { TDistrictsByMapCoordinates } from "@/db/postgresMainDatabase/schemas/map/tables/districts"
import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { TInventorySlots } from "@/db/postgresMainDatabase/schemas/players/tables/inventories"
import { TPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/tables/playerAbilities"
import { TPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/tables/playerSkills"
import { TJoinedCityTiles, TJoinedCityTilesById } from "@/methods/functions/joinCityTiles"
import { TJoinedMapTile, TJoinedMapTileById } from "@/methods/functions/joinMapTiles"
import { TMovmentPath } from "@/methods/hooks/mapTiles/useMapTilesPath"
import { ECityTilesActionStatus } from "@/types/enumeration/CityTilesActionStatusEnum"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { atom } from "jotai"

//Map
export const clickedTileAtom = atom<TJoinedMapTile>()
export const mapTilesAtom = atom<TMapTiles[]>([])
export const citiesAtom = atom<TCitiesByMapCoordinates>({})
export const districtsAtom = atom<TDistrictsByMapCoordinates>({})
export const mapTilesActionStatusAtom = atom<EMapTilesActionStatus>(EMapTilesActionStatus.Inactive)
export const mapTilesMovmentPathAtom = atom<TMovmentPath[]>([])
export const mapTilesGuardAreaAtom = atom<TJoinedMapTile[]>([])

//City
export const clickedCityTileAtom = atom<TJoinedCityTiles>()
export const cityTilesAtom = atom<TCityTiles[]>([])
export const buildingsAtom = atom<TCityBuildingsMapCoordinates>({})
export const cityTilesActionStatusAtom = atom<ECityTilesActionStatus>(ECityTilesActionStatus.Inactive)

//objects
export const joinedMapTilesAtom = atom<TJoinedMapTileById>({})
export const joinedCityTilesAtom = atom<TJoinedCityTilesById>({})
export const playerVisibleMapDataAtom = atom<TPlayerVisibleMapDataById>({})

//
export const skillsAtom = atom<TSkills[]>([])
export const abilitiesAtom = atom<TAbilities[]>([])
export const abilityRequirementsAtom = atom<TAbilityRequirements[]>([])

//Player
export const playerPositionMapTileAtom = atom<TPlayerVisibleMapData>()
export const inventorySlotsAtom = atom<TInventorySlots[]>([])
export const playerSkillsAtom = atom<TPlayerSkills[]>([])
export const playerAbilitiesAtom = atom<TPlayerAbilities[]>([])
export const selectedAbilityIdAtom = atom<number>()
