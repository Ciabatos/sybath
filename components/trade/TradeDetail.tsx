"use client"

import { TTradeSlot } from "@/components/trade/TradeSlot"
import { MOCK_TRADE, mockItemValue, mockRarity } from "@/components/trade/tradeMocks"
import getIcon from "@/methods/functions/icons/getIcon"
import { Sparkles } from "lucide-react"
import styles from "./styles/TradeDetail.module.css"

type TProps = {
  selected: TTradeSlot | null
}

export function TradeDetail({ selected }: TProps) {
  if (!selected) {
    return (
      <div className={`${styles.detail} ${styles.detailEmpty}`}>
        <p className={styles.emptyText}>{MOCK_TRADE.detailHint}</p>
      </div>
    )
  }

  const rarity = mockRarity(selected)

  return (
    <div className={styles.detail}>
      <div className={styles.detailIcon}>{getIcon(selected.image)}</div>
      <div className={styles.detailBody}>
        <div className={styles.detailTitleRow}>
          <h4 className={styles.detailName}>{selected.name}</h4>
          <span className={`${styles.detailRarity} ${styles[`tone${rarity.tone}`]}`}>
            <Sparkles className={styles.detailRarityIcon} />
            {rarity.label}
          </span>
        </div>
        <p className={styles.detailDescription}>
          {selected.description ?? "Ten przedmiot nie ma opisu w kronikach."}
        </p>
        <dl className={styles.detailMeta}>
          <div className={styles.metaItem}>
            <dt>Ilość</dt>
            <dd>{selected.quantity}</dd>
          </div>
          <div className={styles.metaItem}>
            <dt>Wartość</dt>
            <dd className={styles.metaGold}>{mockItemValue(selected)} zł</dd>
          </div>
          <div className={styles.metaItem}>
            <dt>Strona</dt>
            <dd>{selected.side === 1 ? MOCK_TRADE.partnerName : "Ty"}</dd>
          </div>
          <div className={styles.metaItem}>
            <dt>Slot</dt>
            <dd>#{selected.slotId}</dd>
          </div>
        </dl>
      </div>
    </div>
  )
}
