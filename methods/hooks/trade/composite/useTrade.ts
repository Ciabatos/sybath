"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useClickedTrade } from "@/methods/hooks/trade/composite/useClickedTrade"
import { useFetchTradeInventory, useTradeInventoryState } from "@/methods/hooks/trade/core/useFetchTradeInventory"

export function useTrade() {
  const { playerId } = usePlayerId()
  const clickedTrade = useClickedTrade()

  useFetchTradeInventory({ playerId, tradeId: clickedTrade })
  const tradeInventory = useTradeInventoryState()

  return { tradeInventory }
}
