"use client"

import { Button } from "@/components/ui/button"
import { Slider } from "@/components/ui/slider"
import { TMapTileResource } from "@/methods/hooks/world/composite/useMapTileDetail"
import { Package, Pickaxe, X } from "lucide-react"
import { useEffect, useState } from "react"
import styles from "./styles/GatherResource.module.css"

type Props = {
  isOpen: boolean
  onClose: () => void
  resource: TMapTileResource | null
}

export default function GatherResource({ isOpen, onClose, resource }: Props) {
  const [gatherAmount, setGatherAmount] = useState(1)

  useEffect(() => {
    if (resource) {
      setGatherAmount(1)
    }
  }, [resource])

  if (!isOpen || !resource) return null

  const maxAmount = resource.quantity

  const handleGather = () => {
    // onGather?.(gatherAmount)
  }

  const handleSliderChange = (value: number[]) => {
    setGatherAmount(value[0])
  }

  return (
    <div className={styles.panel}>
      <div className={styles.header}>
        <h3 className={styles.title}>Gather Resource</h3>
        <Button
          onClick={onClose}
          variant='ghost'
          size='icon'
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

        <div className={styles.sliderSection}>
          <label className={styles.sliderLabel}>
            Amount to gather:
            <span className={styles.sliderValue}>{gatherAmount}</span>
          </label>
          <Slider
            defaultValue={[1]}
            min={1}
            max={maxAmount}
            step={1}
            value={[gatherAmount]}
            onValueChange={handleSliderChange}
            className={styles.slider}
          />
          <div className={styles.sliderRange}>
            <span>1</span>
            <span>{maxAmount}</span>
          </div>
        </div>

        <div className={styles.summary}>
          <div className={styles.summaryRow}>
            <span className={styles.summaryLabel}>Gathering</span>
            <span className={styles.summaryValue}>
              {gatherAmount}x {resource.name}
            </span>
          </div>
          <div className={styles.summaryRow}>
            <span className={styles.summaryLabel}>Remaining</span>
            <span className={styles.summaryValue}>{maxAmount - gatherAmount}</span>
          </div>
        </div>

        <Button
          className={styles.gatherButton}
          onClick={handleGather}
        >
          <Pickaxe className={styles.gatherIcon} />
          Gather Resources
        </Button>
      </div>
    </div>
  )
}
