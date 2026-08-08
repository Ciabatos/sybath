// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import { Button } from "@/components/ui/button"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useTrade } from "@/methods/hooks/trade/composite/useTrade"
import { X } from "lucide-react"
import styles from "./styles/Trade.module.css"

type TTradeProps = { tradeId: number }

export default function Trade({ tradeId }: TTradeProps) {
  const { resetModalRightCenter } = useModalRightCenter()
  const { tradeInventory } = useTrade({ tradeId })

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
      </div>
    </div>
  )
}
