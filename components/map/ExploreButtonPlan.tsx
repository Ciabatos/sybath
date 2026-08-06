// GENERATED CODE - DO EDIT MANUALLY - createButton.hbs

"use client"
import { Button } from "@/components/ui/button"
import { usePlayerExploration } from "@/methods/hooks/players/composite/usePlayerExploration"
import styles from "./styles/ExploreButtonPlan.module.css"

type TExploreButtonPlanProps = {
  onClose?: () => void
}

export default function ExploreButtonPlan({ onClose }: TExploreButtonPlanProps) {
  const { exploreClickedTilePlan } = usePlayerExploration()

  function handleClick() {
    exploreClickedTilePlan()
    onClose?.()
  }

  return (
    <Button
      className={styles.actionButton}
      onClick={handleClick}
    >
      ExploreButtonPlan
    </Button>
  )
}
