import { clickedOtherPlayerMaskedIdAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"

export function useOtherPlayerId() {
  return useAtomValue(clickedOtherPlayerMaskedIdAtom)
}

export function useSetOtherPlayerId() {
  return useSetAtom(clickedOtherPlayerMaskedIdAtom)
}
