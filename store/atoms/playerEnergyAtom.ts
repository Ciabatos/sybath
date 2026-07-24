import { TPlayerEnergyRecordByLastRegeneratedAt } from "@/db/postgresMainDatabase/schemas/attributes/playerEnergy"
import { atom } from "jotai"

export const playerEnergyAtom = atom<TPlayerEnergyRecordByLastRegeneratedAt>({})
