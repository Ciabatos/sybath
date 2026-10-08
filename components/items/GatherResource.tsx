// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs

"use client"

import { useGatherResourcesOnMapTile } from "@/methods/hooks/items/composite/useGatherResourcesOnMapTile"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { gatherResourceAtom } from "@/store/atoms"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import { useAtom } from "jotai"
import { MapPin, Package, X } from "lucide-react"
import styles from "./styles/GatherResource.module.css"

/** Ikona zastępcza, gdy getIcon nie zna klucza obrazu przedmiotu. */
const FALLBACK_ICON = "📦"

export default function GatherResource() {
  const { resetModalTopCenter } = useModalTopCenter()
  const { clickedMapTile } = useMapTileActions()
  const [resource, setResource] = useAtom(gatherResourceAtom)

  // Bez suwaka — serwer i hook i tak przyjmują 1 sztukę.
  const { gatherClickedResource } = useGatherResourcesOnMapTile({ resource, gatherAmount: 1 })

  function closeGatherResource() {
    setResource(null)
    resetModalTopCenter()
  }

  // Wyniku nie da się użyć: `gatherClickedResource` zwraca `toast.error(...)`
  // (obiekt, czyli truthy) przy błędzie i `undefined` przy sukcesie — odwrotnie,
  // czego sugeruje nazwa. Nie zgadujemy więc, czy się udało: zostawiamy panel
  // otwarty, a stan czyścimy przy zamknięciu. Zasób znika z kafelka
  // po odświeżeniu SWR.
  function handleGather() {
    gatherClickedResource()
  }

  const terrainName = clickedMapTile?.terrainTypes?.name
  const coordinates = clickedMapTile ? `${clickedMapTile.mapTiles.x}, ${clickedMapTile.mapTiles.y}` : null

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <header className={styles.header}>
          <span className={styles.headerEmblem}>
            <Package className={styles.headerEmblemIcon} />
          </span>

          <div className={styles.headerInfo}>
            <h2 className={styles.title}>Gather</h2>
            {terrainName && (
              <span className={styles.headerSubtitle}>
                {terrainName}
                {coordinates && (
                  <>
                    <MapPin className={styles.headerSubtitleIcon} />
                    {coordinates}
                  </>
                )}
              </span>
            )}
          </div>

          <Button
            onClick={closeGatherResource}
            variant='ghost'
            size='icon'
            className={styles.closeButton}
            aria-label='Close'
          >
            <X className={styles.closeIcon} />
          </Button>
        </header>

        <div className={styles.content}>
          {!resource ? (
            <p className={styles.emptyText}>Nothing selected to gather.</p>
          ) : (
            <>
              <div className={styles.resourceCard}>
                <span className={styles.resourceIcon}>{getIcon(resource.image) ?? FALLBACK_ICON}</span>

                <div className={styles.resourceInfo}>
                  <span className={styles.resourceName}>{resource.name}</span>
                  {resource.description && <p className={styles.resourceDescription}>{resource.description}</p>}
                </div>
              </div>

              <Button
                onClick={handleGather}
                className={styles.gatherButton}
              >
                <Package className={styles.gatherIcon} />
                Gather 1
              </Button>
            </>
          )}
        </div>
      </div>
    </div>
  )
}