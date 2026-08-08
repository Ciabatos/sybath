"use client"

import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchTrades, useTradesState } from "@/methods/hooks/trade/core/useFetchTrades"
import { clickedTradeAtom } from "@/store/atoms"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { useAtom } from "jotai"

export function useTrades() {
  const { playerId } = usePlayerId()
  const [clickedTrade, setClickedTrade] = useAtom(clickedTradeAtom)
  const { openModalRightCenter } = useModalRightCenter()

  useFetchTrades({ playerId })
  const trades = useTradesState()

  function handleClickOnTrade(tradeId: number) {
    setClickedTrade(tradeId)
    openModalRightCenter(EPanelsRightCenter.Trade)
  }

  return { trades, clickedTrade, handleClickOnTrade }
}
