"use client"

import { TradeDetail } from "@/components/trade/TradeDetail"
import { TradeFooter } from "@/components/trade/TradeFooter"
import { TradeSide } from "@/components/trade/TradeSide"
import { TTradeSlot } from "@/components/trade/TradeSlot"
import { MOCK_TRADE, mockSideTotal } from "@/components/trade/tradeMocks"
import { Button } from "@/components/ui/button"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useTrade } from "@/methods/hooks/trade/composite/useTrade"
import { Scale, Swords, X } from "lucide-react"
import { useState } from "react"
import styles from "./styles/Trade.module.css"

export default function Trade() {
  const { resetModalRightCenter } = useModalRightCenter()
  const { combinedTradeInventory } = useTrade()

  const [selected, setSelected] = useState<TTradeSlot | null>(null)
  const [confirmed, setConfirmed] = useState(false)

  function closeTrade() {
    resetModalRightCenter()
  }

  function acceptTrade() {
    // MOCK — brak wywołania API, umowa potwierdza się tylko po stronie UI
    setConfirmed(true)
    setSelected(null)
  }

  const side1Inventory = combinedTradeInventory.filter((tradeInventory) => tradeInventory.side === 1)
  const side2Inventory = combinedTradeInventory.filter((tradeInventory) => tradeInventory.side === 2)

  const totalOne = mockSideTotal(side1Inventory)
  const totalTwo = mockSideTotal(side2Inventory)

  const selectedKey = selected ? `${selected.containerId}-${selected.slotId}` : null

  return (
    <div className={styles.panelsContainer}>
      <div className={styles.panel}>
        <Button
          onClick={closeTrade}
          variant='ghost'
          size='icon'
          className={styles.closeButton}
        >
          <X />
        </Button>

        <header className={styles.header}>
          <span className={styles.headerIcon}>
            <Swords className={styles.headerIconGlyph} />
          </span>
          <div className={styles.headerText}>
            <h2 className={styles.title}>Niebiski Most</h2>
            <p className={styles.subtitle}>Umowa #{MOCK_TRADE.id}</p>
          </div>
          <div className={styles.partner}>
            <span className={styles.partnerName}>{MOCK_TRADE.partnerName}</span>
            <span className={styles.partnerMeta}>
              {MOCK_TRADE.partnerTitle} · Poz. {MOCK_TRADE.partnerLevel} · {MOCK_TRADE.partnerStanding} renomy
            </span>
            <span className={styles.partnerMood}>{MOCK_TRADE.partnerMood}</span>
          </div>
        </header>

        <div className={styles.statusBanner}>
          <Scale className={styles.statusBannerIcon} />
          <span>{MOCK_TRADE.statusHint}</span>
        </div>

        <div className={styles.mainContent}>
          <div className={styles.sides}>
            <TradeSide
              side={1}
              title={MOCK_TRADE.partnerName}
              subtitle={MOCK_TRADE.partnerTitle}
              icon={MOCK_TRADE.partnerIcon}
              inventory={side1Inventory}
              selectedKey={selectedKey}
              onSelect={setSelected}
            />

            <div className={styles.divider}>
              <span className={styles.dividerLine} />
              <span className={styles.dividerBadge}>WYMIEŃ</span>
              <span className={styles.dividerLine} />
            </div>

            <TradeSide
              side={2}
              title='Twoja oferta'
              subtitle='Przeciągnij przedmioty z ekwipunku'
              icon='Belt'
              inventory={side2Inventory}
              selectedKey={selectedKey}
              onSelect={setSelected}
            />
          </div>

          <TradeDetail selected={selected} />
        </div>

        <TradeFooter
          valueOne={totalOne.value}
          valueTwo={totalTwo.value}
          slotsOne={totalOne.slotsUsed}
          slotsTwo={totalTwo.slotsUsed}
          confirmed={confirmed}
          onAccept={acceptTrade}
        />
      </div>
    </div>
  )
}

