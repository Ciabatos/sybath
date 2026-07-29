import { TAreaRecordByXY } from "@/methods/hooks/world/composite/useMapTilesArea"
import { atom } from "jotai"

export const playerMapTilesGuardAreaAtom = atom<TAreaRecordByXY>({})
