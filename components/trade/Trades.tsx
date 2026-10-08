// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import TradesElement from "@/components/trade/TradesElement"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useTrades } from "@/methods/hooks/trade/composite/useTrades"
import { Handshake, X } from "lucide-react"
import styles from "./styles/Trades.module.css"

export default function Trades() {
  const { resetModalTopCenter } = useModalTopCenter()

  const { trades } = useTrades()

  function closeTrades() {
    resetModalTopCenter()
  }

  const tradeList = Object.values(trades)

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <header className={styles.header}>
          <span className={styles.headerEmblem}>
            <Handshake className={styles.headerEmblemIcon} />
          </span>

          <div className={styles.headerInfo}>
            <h2 className={styles.title}>Trades</h2>
            <p className={styles.subtitle}>
              {tradeList.length === 0
                ? "No offers on the board"
                : `${tradeList.length} ${tradeList.length === 1 ? "offer" : "offers"} on the board`}
            </p>
          </div>

          <Button
            onClick={closeTrades}
            variant='ghost'
            size='icon'
            className={styles.closeButton}
            aria-label='Close'
          >
            <X className={styles.closeIcon} />
          </Button>
        </header>

        {tradeList.length === 0 ? (
          <div className={styles.empty}>
            <Handshake className={styles.emptyIcon} />
            <p className={styles.emptyText}>Nobody has offered you anything yet.</p>
          </div>
        ) : (
          <div className={styles.list}>
            {tradeList.map((trade) => (
              <TradesElement
                key={trade.id}
                icon={getIcon("Trade")}
                id={trade.id}
                status={trade.status}
                createdAt={trade.createdAt}
                expiresAt={trade.expiresAt}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}