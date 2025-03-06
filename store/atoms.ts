"use client"

import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import type { TClickedTile } from "@/methods/hooks/useClickTile"
import { EModalStatus } from "@/types/enumeration/ModalBottomCenterBarEnum"
import { atom } from "jotai"

export const mapTilesAtom = atom<TMapTiles[]>([])
export const joinedMapTilesAtom = atom<Record<string, TjoinedMapTile>>({})
export const clickedTileAtom = atom<TClickedTile>({ x: 1, y: 1 })
export const openModalBottomCenterBarAtom = atom<EModalStatus>(EModalStatus.Inactive)
