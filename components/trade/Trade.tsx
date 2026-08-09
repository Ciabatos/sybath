// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import { TradeSlot } from "@/components/trade/TradeSlot"
import { Button } from "@/components/ui/button"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useTrade } from "@/methods/hooks/trade/composite/useTrade"
import { X } from "lucide-react"
import styles from "./styles/Trade.module.css"

export default function Trade() {
  const { resetModalRightCenter } = useModalRightCenter()
  const { combinedTradeInventory } = useTrade()

  function closeTrade() {
    resetModalRightCenter()
  }

  const side1Inventory = combinedTradeInventory.filter((tradeInventory) => tradeInventory.side === 1)

  const side2Inventory = combinedTradeInventory.filter((tradeInventory) => tradeInventory.side === 2)

  return (
    <div className={styles.panelsContainer}>
      <div className={styles.panel}>
        <Button
          onClick={closeTrade}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>
        <div className={styles.grid}>
          {side1Inventory.map((tradeInventory) => (
            <TradeSlot
              key={tradeInventory.slotId}
              inventory={tradeInventory}
            />
          ))}
        </div>
        <div className={styles.grid}>
          {side2Inventory.map((tradeInventory) => (
            <TradeSlot
              key={tradeInventory.slotId}
              inventory={tradeInventory}
            />
          ))}
        </div>
      </div>
    </div>
  )
}
