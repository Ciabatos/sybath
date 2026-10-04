export type TradeRarity = "common" | "uncommon" | "rare" | "epic" | "legendary"

export type TradeItem = {
  id: number
  name: string
  description?: string
  quantity: number
  icon?: React.ReactNode
  rarity?: TradeRarity
  price?: number
  maxStack?: number
  slotId?: number
}

export type TradeParticipant = {
  id: number
  name: string
  level?: number
  avatar?: string
  gold: number
  inventory: TradeItem[]
}

export type TradeOfferSlot = {
  item: TradeItem
  quantity: number
} | null

export type TradeSideState = {
  gold: number
  slots: TradeOfferSlot[]
  confirmed: boolean
}

export type TradeBoardState = {
  1: TradeSideState
  2: TradeSideState
}

export type TradeChangePayload = {
  board: TradeBoardState
}
