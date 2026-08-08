// GENERATED CODE - DO NOT EDIT MANUALLY - atomCreateAtomClientSingleton.hbs

import { clickedTradeAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"

export function useClickedTrade() {
  return useAtomValue(clickedTradeAtom)
}

export function useSetClickedTrade() {
  return useSetAtom(clickedTradeAtom)
}
