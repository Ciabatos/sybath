import getIcon from "@/methods/functions/icons/getIcon"
import { TCombinedResourcesOnMap } from "@/methods/hooks/world/composite/useResourcesLayer"
import ResourcesLayer from "./ResourcesLayer"
import styles from "./styles/TileLayerResources.module.css"

type TProps = {
  resources?: TCombinedResourcesOnMap[string]
  /** true = aktywna warstwa szczegółowa. false = sam licznik. */
  showDetail: boolean
}

/** Ile ikon mieści się na kafelku. Reszta to "+N". */
const MAX_DETAIL_ICONS = 3

/**
 * Zasoby na kafelku.
 *
 * Warstwa wyłączona → zwykły licznik (`ResourcesLayer`, dokładnie jak wcześniej).
 * Warstwa włączona → jeden kafelek ikony na zasób, ułożony w kolumnę.
 */
export default function TileLayerResources({ resources, showDetail }: TProps) {
  const items = resources?.itemIds ?? []

  if (items.length === 0) return null

  if (!showDetail) {
    return <ResourcesLayer knownMapTilesResourcesOnMap={resources} />
  }

  const shown = items.slice(0, MAX_DETAIL_ICONS)
  const hidden = items.length - shown.length

  return (
    <div className={styles.stack}>
      {shown.map((item) => (
        <span
          key={item.itemId}
          className={styles.item}
          title={item.name}
        >
          {getIcon(item.image) ?? <span className={styles.fallback} />}
        </span>
      ))}

      {hidden > 0 && <span className={styles.more}>+{hidden}</span>}
    </div>
  )
}