"use client"

import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useSetClickedTrade } from "@/methods/hooks/trade/composite/useClickedTrade"
import { useFetchTrades, useTradesState } from "@/methods/hooks/trade/core/useFetchTrades"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"

export function useTrades() {
  const { playerId } = usePlayerId()
  const setClickedTrade = useSetClickedTrade()
  const { openModalRightCenter } = useModalRightCenter()

  useFetchTrades({ playerId })
  const trades = useTradesState()

  function handleClickOnTrade(tradeId: number) {
    setClickedTrade(tradeId)
    openModalRightCenter(EPanelsRightCenter.Trade)
  }

  return { trades, handleClickOnTrade }
}
