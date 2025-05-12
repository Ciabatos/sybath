"use client"

import { TPlayerVisibleMapDataById } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import type { TMapTile } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { TAbilities } from "@/db/postgresMainDatabase/schemas/players/tables/abilities"
import { TAbilityRequirements } from "@/db/postgresMainDatabase/schemas/players/tables/abilityRequirements"
import { TInventorySlots } from "@/db/postgresMainDatabase/schemas/players/tables/inventories"
import { TPlayerAbilities } from "@/db/postgresMainDatabase/schemas/players/tables/playerAbilities"
import { TPlayerSkills } from "@/db/postgresMainDatabase/schemas/players/tables/playerSkills"
import { TSkills } from "@/db/postgresMainDatabase/schemas/players/tables/skills"
import { TJoinedMapTile, TJoinedMapTileById } from "@/methods/functions/joinMapTiles"
import { TTileCoordinates } from "@/methods/hooks/mapTiles/useMapTilesManipulation"
import { TMovmentPath } from "@/methods/hooks/mapTiles/useMapTilesPath"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { atom } from "jotai"

//Map
export const clickedTileAtom = atom<TTileCoordinates | null>(null)
export const mapTilesAtom = atom<TMapTile[]>([])
export const mapTilesActionStatusAtom = atom<EMapTilesActionStatus>(EMapTilesActionStatus.Inactive)
export const mapTilesMovmentPathAtom = atom<TMovmentPath[]>([])
export const mapTilesGuardAreaAtom = atom<TJoinedMapTile[]>([])

//objects
export const joinedMapTilesAtom = atom<TJoinedMapTileById>({})
export const playerVisibleMapDataAtom = atom<TPlayerVisibleMapDataById>({})

//
export const skillsAtom = atom<TSkills[]>([])
export const abilitiesAtom = atom<TAbilities[]>([])
export const abilityRequirementsAtom = atom<TAbilityRequirements[]>([])

//Player
export const playerPositionMapTileAtom = atom<TTileCoordinates>({ x: 0, y: 0 })
export const inventorySlotsAtom = atom<TInventorySlots[]>([])
export const playerSkillsAtom = atom<TPlayerSkills[]>([])
export const playerAbilitiesAtom = atom<TPlayerAbilities[]>([])
export const selectedAbilityIdAtom = atom<number>()
