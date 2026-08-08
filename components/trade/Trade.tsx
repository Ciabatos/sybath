// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import { Button } from "@/components/ui/button"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useTrade } from "@/methods/hooks/trade/composite/useTrade"
import { X } from "lucide-react"
import styles from "./styles/Trade.module.css"

export default function Trade() {
  const { resetModalRightCenter } = useModalRightCenter()
  const { tradeInventory } = useTrade()

  function closeTrade() {
    resetModalRightCenter()
  }

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <Button
          onClick={closeTrade}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>
        {Object.values(tradeInventory).map((item) => (
          <div key={item.slotId}>
            <div className={styles.itemContainer}>
              <div className={styles.itemName}>{item.name}</div>
              <div className={styles.itemQuantity}>Quantity: {item.quantity}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
