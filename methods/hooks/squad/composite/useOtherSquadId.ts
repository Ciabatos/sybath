import { clickedOtherSquadIdAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"

export function useOtherSquadId() {
  return useAtomValue(clickedOtherSquadIdAtom)
}

export function useSetOtherSquadId() {
  return useSetAtom(clickedOtherSquadIdAtom)
}
