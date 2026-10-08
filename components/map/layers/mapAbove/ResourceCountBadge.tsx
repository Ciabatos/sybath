import { Package } from "lucide-react"
import { TCombinedResourcesOnMap } from "@/methods/hooks/world/composite/useResourcesLayer"
import styles from "./styles/ResourceCountBadge.module.css"

type TProps = {
  resources?: TCombinedResourcesOnMap[string]
}

/**
 * Sam zlicznik zasobów na kafelku — bez ikon poszczególnych przedmiotów.
 *
 * Wywoływany przez `TileLayerResources` tylko wtedy, gdy warstwa szczegółowa jest
 * wyłączona. Dawniej nazywał się `ResourcesLayer`, co myliło się z
 * `TileLayerResources` — obie rzeczy są „warstwą zasobów", ale tylko jedna
 * przełącza widok.
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