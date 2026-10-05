"use client"

import { MOCK_TRADE } from "@/components/trade/tradeMocks"
import { Button } from "@/components/ui/button"
import { Check, Clock, Handshake, ScrollText, ShieldCheck } from "lucide-react"
import { useEffect, useState } from "react"
import styles from "./styles/TradeFooter.module.css"

type TProps = {
  valueOne: number
  valueTwo: number
  slotsOne: number
  slotsTwo: number
  confirmed: boolean
  onAccept: () => void
}

const [START_MINUTES, START_SECONDS] = MOCK_TRADE.expiresIn.split(":").map(Number)
const START_TOTAL_SECONDS = START_MINUTES * 60 + START_SECONDS

export function TradeFooter({ valueOne, valueTwo, slotsOne, slotsTwo, confirmed, onAccept }: TProps) {
  const [secondsLeft, setSecondsLeft] = useState(START_TOTAL_SECONDS)

  // MOCK — odliczanie do końca oferty, w przyszłości czas przyjdzie z API
  useEffect(() => {
    if (confirmed) return

    const timer = setInterval(() => {
      setSecondsLeft((value) => (value > 0 ? value - 1 : START_TOTAL_SECONDS))
    }, 1000)

    return () => clearInterval(timer)
  }, [confirmed])

  const diff = valueOne - valueTwo
  const balanced = diff === 0
  const ready = slotsOne > 0 && slotsTwo > 0

  const balanceLabel = balanced
    ? "Oferta wyrównana"
    : diff > 0
      ? `Przewaga kontrahenta: ${Math.abs(diff)} zł`
      : `Przewaga twojej strony: ${Math.abs(diff)} zł`

  const timerLabel = `${String(Math.floor(secondsLeft / 60)).padStart(2, "0")}:${String(secondsLeft % 60).padStart(2, "0")}`
  const timerCritical = secondsLeft <= 30

  return (
    <footer className={styles.footer}>
      {confirmed ? (
        <div className={styles.confirmedBanner}>
          <Check className={styles.confirmedIcon} />
          <div className={styles.confirmedText}>
            <span className={styles.confirmedTitle}>Umowa zawarta</span>
            <span className={styles.confirmedHint}>
              Oba ekwipunki przeniesiono, {MOCK_TRADE.partnerName} zabrał swoją część.
            </span>
          </div>
          <span className={styles.confirmedSeal}>
            <ScrollText className={styles.confirmedSealIcon} />
            {MOCK_TRADE.id}
          </span>
        </div>
      ) : null}

      <div className={styles.balanceRow}>
        <span className={styles.balanceLabel}>Bilans</span>
        <span className={`${styles.balanceValue} ${balanced ? styles.balanceOk : styles.balanceWarn}`}>
          {balanceLabel}
        </span>
      </div>

      <div className={styles.actionsRow}>
        <div className={styles.status}>
          <span className={styles.statusText}>
            {confirmed ? "Rozliczono" : slotsOne > 0 && slotsTwo > 0 ? "Obie strony gotowe" : MOCK_TRADE.status}
          </span>
          <span className={styles.statusHint}>
            <Clock className={`${styles.statusIcon} ${timerCritical && !confirmed ? styles.timerCritical : ""}`} />
            {timerLabel}
          </span>
          <span className={styles.statusHint}>
            <ShieldCheck className={styles.statusIcon} />
            prowizja {MOCK_TRADE.feePercent}%
          </span>
        </div>

        <Button
          className={`${styles.acceptButton} ${ready && !confirmed ? styles.acceptReady : ""}`}
          onClick={onAccept}
          disabled={!ready || confirmed}
        >
          <Handshake className={styles.acceptIcon} />
          {confirmed ? "Zawarto umowę" : "Zawrzyj umowę"}
          <Check className={styles.acceptCheck} />
        </Button>
      </div>
    </footer>
  )
}
