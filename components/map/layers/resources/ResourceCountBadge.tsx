import { Package } from "lucide-react"
import { TCombinedResourcesOnMap } from "@/methods/hooks/world/composite/useResourcesLayer"
import styles from "./styles/ResourceCountBadge.module.css"

type TProps = {
  resources?: TCombinedResourcesOnMap[string]
}

/**
 * Sam zlicznik zasobów — bez ikon poszczególnych przedmiotów.
 *
 * Wywoływany przez `ResourcesLayer` tylko wtedy, gdy warstwa szczegółowa jest
 * wyłączona. Osobna nazwa, bo `ResourcesLayer` i `ResourceCountBadge` to dwa
 * różne warianty tego samego rysunku, nie dwie warstwy.
 */
export default function ResourceCountBadge({ resources }: TProps) {
  const count = resources?.itemIds.length ?? 0

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