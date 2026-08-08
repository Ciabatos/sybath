// GENERATED CODE - DO EDIT MANUALLY - createButton.hbs

"use client"
import { Button } from "@/components/ui/button"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import styles from "./styles/OpenTrades.module.css"

type TOpenTradesProps = {
  onClose?: () => void
}

export default function OpenTrades({ onClose }: TOpenTradesProps) {
  const { openModalTopCenter } = useModalTopCenter()

  function handleClick() {
    openModalTopCenter(EPanelsTopCenter.Trades)
    onClose?.()
  }

  return (
    <Button
      className={styles.actionButton}
      onClick={handleClick}
    >
      OpenTrades
    </Button>
  )
}
