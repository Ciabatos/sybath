// GENERATED CODE - DO EDIT MANUALLY - createListPanels.hbs
"use client"

import { formatCountdown, formatRelativeAge, isExpired } from "@/components/trade/tradeTime"
import { Button } from "@/components/ui/button"
import { useTrades } from "@/methods/hooks/trade/composite/useTrades"
import { Clock, ScrollText } from "lucide-react"
import { useEffect, useState } from "react"
import styles from "./styles/TradesElement.module.css"

interface TTradesElementProps {
  icon: React.ReactNode
  id: number
  status: number
  createdAt: string
  expiresAt: string
}

export default function TradesElement({ icon, id, status, createdAt, expiresAt }: TTradesElementProps) {
  const { handleClickOnTrade } = useTrades()

  // `null` do pierwszego efektu: `Date.now()` na serwerze i w przeglądarce
  // różni się o sekundy, a tekst zależny od czasu przy pierwszym renderze
  // dałby hydration mismatch.
  const [now, setNow] = useState<number | null>(null)

  useEffect(() => {
    const current = Date.now()
    setNow(current)

    // Wygasła oferta nie potrzebuje interwału.
    if (isExpired(expiresAt, current)) return

    const timer = setInterval(() => setNow(Date.now()), 1000)
    return () => clearInterval(timer)
  }, [expiresAt])

  const expired = now !== null && isExpired(expiresAt, now)

  return (
    <Button
      onClick={() => handleClickOnTrade(id)}
      className={`${styles.listItem} ${expired ? styles.listItemExpired : ""}`}
    >
      <span className={styles.listItemIcon}>{icon}</span>

      <span className={styles.listItemContent}>
        <span className={styles.listItemHeader}>
          <span className={styles.listItemName}>Trade #{id}</span>
          {/* W projekcie nie ma enuma statusu — pokazujemy surową wartość. */}
          <span className={styles.listItemStatus}>Status {status}</span>
        </span>

        <span className={styles.listItemMeta}>
          <span className={styles.metaItem}>
            <ScrollText className={styles.metaIcon} />
            {now === null ? "opening…" : `opened ${formatRelativeAge(createdAt, now)}`}
          </span>

          <span className={styles.metaItem}>
            <Clock className={`${styles.metaIcon} ${expired ? styles.metaIconExpired : ""}`} />
            {now === null ? "—" : expired ? "expired" : `expires in ${formatCountdown(expiresAt, now)}`}
          </span>
        </span>
      </span>
    </Button>
  )
}