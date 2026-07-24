import { TPlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { atom } from "jotai"

export const playerPositionAtom = atom<TPlayerPositionRecordByXY>({})
