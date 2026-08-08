// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import TradesElement from "@/components/trade/TradesElement"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useTrades } from "@/methods/hooks/trade/composite/useTrades"
import { X } from "lucide-react"
import styles from "./styles/Trades.module.css"

export default function Trades() {
  const { resetModalTopCenter } = useModalTopCenter()

  const { trades } = useTrades()

  function closeTrades() {
    resetModalTopCenter()
  }

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <Button
          onClick={closeTrades}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>
        <div>
          {Object.values(trades).map((trade) => (
            <div key={trade.id}>
              <TradesElement
                icon={getIcon("Trade")}
                id={trade.id}
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
