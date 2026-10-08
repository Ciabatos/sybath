import { TCombinedResourcesOnMap } from "@/methods/hooks/world/composite/useResourcesLayer"
import { Package } from "lucide-react"
import styles from "./styles/ResourcesLayer.module.css"

type TProps = {
  knownMapTilesResourcesOnMap?: TCombinedResourcesOnMap[string]
}

/**
 * Licznik zasobów na kafelku — jeden znacznik na kafelek, nie jeden na zasób.
 * Wcześniej renderował tekst `res_{itemId}` w kontenerze z `z-index: 999999999`.
 */
export default function ResourcesLayer({ knownMapTilesResourcesOnMap }: TProps) {
  const count = knownMapTilesResourcesOnMap?.itemIds.length ?? 0

  if (count === 0) return null

  return (
    <span
      className={styles.badge}
      title={`${count} ${count === 1 ? "resource" : "resources"}`}
    >
      <Package className={styles.icon} />
      {count}
    </span>
  )
}