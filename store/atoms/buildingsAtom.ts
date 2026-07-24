import { TBuildingsBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { atom } from "jotai"

export const buildingsAtom = atom<TBuildingsBuildingsRecordByCityTileXCityTileY>({})
