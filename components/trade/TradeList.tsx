// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import Trade from "@/components/trade/Trade"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useTradeList } from "@/methods/hooks/trade/composite/useTradeList"
import { X } from "lucide-react"
import styles from "./styles/TradeList.module.css"

export default function TradeList() {
  const { resetModalTopCenter } = useModalTopCenter()

  const { trades } = useTradeList()

  function closeTradeList() {
    resetModalTopCenter()
  }

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <Button
          onClick={closeTradeList}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>
        <div>
          {Object.values(trades).map((trade) => (
            <div key={trade.id}>
              <Trade
                icon={getIcon("Trade")}
                status={trade.status}
                createdAt={trade.createdAt}
                updatedAt={trade.updatedAt}
                expiresAt={trade.expiresAt}
              />
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
