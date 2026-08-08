"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchTradeInventory, useTradeInventoryState } from "@/methods/hooks/trade/core/useFetchTradeInventory"

type TTradeParams = {
  tradeId: number
}

export function useTrade(params: TTradeParams) {
  const { playerId } = usePlayerId()

  useFetchTradeInventory({ playerId, tradeId: params.tradeId })
  const tradeInventory = useTradeInventoryState()

  return { tradeInventory }
}
