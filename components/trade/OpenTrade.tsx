// GENERATED CODE - DO EDIT MANUALLY - createButton.hbs

"use client"
import { Button } from "@/components/ui/button"
import { useOpenTrade } from "@/methods/hooks/trade/composite/useOpenTrade"
import styles from "./styles/OpenTrade.module.css"

type TOpenTradeProps = {
  onClose?: () => void
}

export default function OpenTrade({ onClose }: TOpenTradeProps) {
  const { openTrade } = useOpenTrade()

  function handleClick() {
    openTrade()
    onClose?.()
  }

  return (
    <Button
      className={styles.actionButton}
      onClick={handleClick}
    >
      OpenTrade
    </Button>
  )
}
