// GENERATED CODE - DO EDIT MANUALLY - createButton.hbs

"use client"
import { Button } from "@/components/ui/button"
import { usePlayerExploration } from "@/methods/hooks/players/composite/usePlayerExploration"
import styles from "./styles/ExploreButtonConfirm.module.css"

type TExploreButtonConfirmProps = {
  onClose?: () => void
}

export default function ExploreButtonConfirm({ onClose }: TExploreButtonConfirmProps) {
  const { exploreClickedTileConfirm } = usePlayerExploration()

  function handleClick() {
    exploreClickedTileConfirm()
    onClose?.()
  }

  return (
    <Button
      className={styles.actionButton}
      onClick={handleClick}
    >
      ExploreButtonConfirm
    </Button>
  )
}
