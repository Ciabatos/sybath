"use client"

import { Button } from "@/components/ui/button"
import { useGatherResourcesOnMapTile } from "@/methods/hooks/items/composite/useGatherResourcesOnMapTile"
import { TMapTileResource } from "@/methods/hooks/world/composite/useMapTileDetail"
import { Package, X } from "lucide-react"
import { useState } from "react"
import { GiCardPickup } from "react-icons/gi"
import styles from "./styles/GatherResource.module.css"

type Props = {
  isOpen: boolean
  onClose: () => void
  resource: TMapTileResource | null
}

export default function GatherResource({ isOpen, onClose, resource }: Props) {
  const [gatherAmount, setGatherAmount] = useState(1)

  const gatherResourcesOnMapTileParams = {
    resource,
    gatherAmount,
  }
  const { gatherClickedResource } = useGatherResourcesOnMapTile(gatherResourcesOnMapTileParams)

  if (!isOpen || !resource) return null

  function handleGather() {
    gatherClickedResource()
  }

  return (
    <div className={styles.panel}>
      <div className={styles.header}>
        <h3 className={styles.title}>Gather Resource</h3>
        <Button
          onClick={() => {
            onClose()
          }}
          className={styles.closeButton}
        >
          <X className={styles.closeIcon} />
        </Button>
      </div>

      <div className={styles.content}>
        <div className={styles.resourceDisplay}>
          <div className={styles.resourceIconWrapper}>
            <Package className={styles.resourceIcon} />
          </div>
          <div className={styles.resourceInfo}>
            <span className={styles.resourceName}>{resource.name}</span>
            <span className={styles.resourceAvailable}>
              Available: <strong>{resource.quantity}</strong>
            </span>
          </div>
        </div>

        <Button
          className={styles.gatherButton}
          onClick={handleGather}
        >
          <GiCardPickup className={styles.gatherIcon} />
          Gather Resource
        </Button>
      </div>
    </div>
  )
}
