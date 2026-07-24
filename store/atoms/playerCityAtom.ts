import { TPlayerCityRecordByCityId } from "@/db/postgresMainDatabase/schemas/cities/playerCity"
import { atom } from "jotai"

export const playerCityAtom = atom<TPlayerCityRecordByCityId>({})
