// GENERATED CODE - DO EDIT MANUALLY - createButton.hbs

"use client"
import { Button } from "@/components/ui/button"
import { usePlayerExploration } from "@/methods/hooks/players/composite/usePlayerExploration"
import styles from "./styles/MapActionButton.module.css"

type TExploreButtonCancelProps = {
  onClose?: () => void
}

export default function ExploreButtonCancel({ onClose }: TExploreButtonCancelProps) {
  const { closeExplorationPanel } = usePlayerExploration()

  function handleClick() {
    closeExplorationPanel()
    onClose?.()
  }

  return (
    <Button
      className={`${styles.actionButton} ${styles.ghost}`}
      onClick={handleClick}
    >
      Cancel
    </Button>
  )
}