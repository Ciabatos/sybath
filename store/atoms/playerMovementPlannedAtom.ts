import { TPlayerMovementRecordByXY } from "@/methods/functions/map/pathFromPointToPoint"
import { atom } from "jotai"

export const playerMovementPlannedAtom = atom<TPlayerMovementRecordByXY>({})
