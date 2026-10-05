"use client"

import { TradeSlot, TTradeSlot } from "@/components/trade/TradeSlot"
import { MOCK_TRADE, mockRarity, mockSideTotal } from "@/components/trade/tradeMocks"
import getIcon from "@/methods/functions/icons/getIcon"
import styles from "./styles/TradeSide.module.css"

type TProps = {
  side: 1 | 2
  title: string
  subtitle: string
  icon?: string
  inventory: TTradeSlot[]
  selectedKey: string | null
  onSelect: (slot: TTradeSlot) => void
}

export function TradeSide({ side, title, subtitle, icon, inventory, selectedKey, onSelect }: TProps) {
  const total = mockSideTotal(inventory)
  const accentClass = side === 1 ? styles.sideOne : styles.sideTwo
  const filled = inventory.filter((slot) => slot.itemId)
  const preview = filled.slice(0, 4)

  return (
    <section className={`${styles.side} ${accentClass}`}>
      <header className={styles.header}>
        <span className={styles.headerIcon}>{getIcon(icon)}</span>
        <div className={styles.headerText}>
          <h3 className={styles.title}>{title}</h3>
          <p className={styles.subtitle}>{subtitle}</p>
        </div>
        <span className={styles.counter}>
          {total.slotsUsed}/{total.slotsTotal}
        </span>
      </header>

      <div className={styles.grid}>
        {inventory.length === 0 ? <p className={styles.gridEmpty}>{MOCK_TRADE.emptyHint}</p> : null}
        {inventory.map((slot) => {
          const key = `${slot.containerId}-${slot.slotId}`
          const isSelected = selectedKey === key

          return (
            <div
              key={slot.slotId}
              className={`${styles.cell} ${isSelected ? styles.cellSelected : ""}`}
              data-has-item={slot.itemId ? 'true' : 'false'}
              onClick={() => slot.itemId && onSelect(slot)}
              title={slot.itemId ? slot.name : undefined}
            >
              <TradeSlot inventory={slot} />
              {slot.itemId ? (
                <span className={`${styles.cellRarity} ${styles[`tone${mockRarity(slot).tone}`]}`} />
              ) : null}
            </div>
          )
        })}
      </div>

      <footer className={styles.footer}>
        <div className={styles.footerStats}>
          <span className={styles.statLabel}>Sztuk</span>
          <span className={styles.statValue}>{total.units}</span>
        </div>
        <div className={styles.footerStats}>
          <span className={styles.statLabel}>Wartość</span>
          <span className={styles.statValueGold}>{total.value} zł</span>
        </div>
      </footer>

      <ul className={styles.preview}>
        {preview.length === 0 ? (
          <li className={styles.previewEmpty}>Brak przedmiotów w tej ofercie</li>
        ) : (
          preview.map((slot) => (
            <li
              key={`preview-${slot.slotId}`}
              className={styles.previewItem}
            >
              <span className={styles.previewIcon}>{getIcon(slot.image)}</span>
              <span className={styles.previewName}>{slot.name}</span>
              {slot.quantity > 1 ? <span className={styles.previewQty}>×{slot.quantity}</span> : null}
            </li>
          ))
        )}
        {filled.length > preview.length ? (
          <li className={styles.previewMore}>+{filled.length - preview.length}</li>
        ) : null}
      </ul>
    </section>
  )
}
