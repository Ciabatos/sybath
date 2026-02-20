"use client"

import { Button } from "@/components/ui/button"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { X } from "lucide-react"
import { useEffect, useState } from "react"
import styles from "./styles/PanelMapTileDetail.module.css"

export default function PanelMapTileDetail() {
  const { openModalRightCenter, resetModalRightCenter } = useModalRightCenter()
  const { clickedTile } = useMapTileActions()
  const { selectPlayerPathToClickedTile, selectPlayerPathAndMovePlayerToClickedTile, resetPlayerMovementPlanned } =
    usePlayerMovement()

  const onClose = () => {
    resetModalRightCenter()
  }

  const [isMoving, setIsMoving] = useState(false)

  useEffect(() => {
    if (isMoving) {
      selectPlayerPathToClickedTile()
    }
  }, [clickedTile])

  function handlePlayersListOnTile() {
    openModalRightCenter(EPanelsRightCenter.PanelPlayersOnTile)
  }

  function handleMove() {
    if (!isMoving) {
      selectPlayerPathToClickedTile()
      setIsMoving(true)
    }
  }

  function handleConfirmMove() {
    if (isMoving) {
      selectPlayerPathAndMovePlayerToClickedTile()
      setIsMoving(false)
    }
  }

  function handleCancelMove() {
    resetPlayerMovementPlanned()
    setIsMoving(false)
  }

  const terrainName = clickedTile?.terrainTypes?.name

  const terrainTypesMoveCost = clickedTile?.terrainTypes?.moveCost
  const landscapeTypesMoveCost = clickedTile?.landscapeTypes?.moveCost
  const citiesMoveCost = clickedTile?.cities?.moveCost
  const districtTypesMoveCost = clickedTile?.districtTypes?.moveCost
  const totalMoveCost =
    (terrainTypesMoveCost || 0) + (landscapeTypesMoveCost || 0) + (citiesMoveCost || 0) + (districtTypesMoveCost || 0)

  const landscapeName = clickedTile?.landscapeTypes?.name
  const cityName = clickedTile?.cities?.name
  const districtName = clickedTile?.districts?.name
  const districtTypeName = clickedTile?.districtTypes?.name

  return (
    <div className={styles.panel}>
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>{terrainName}</h2>
          <p className={styles.description}>{landscapeName}</p>

          <span className={styles.coordinates}>
            [{clickedTile?.mapTiles.x}, {clickedTile?.mapTiles.y}]
          </span>
        </div>
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
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Description</h3>
          <p className={styles.description}>
            {
              "A small village where travelers can rest, trade, and gather information. The locals are friendly but wary of strangers."
            }
          </p>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Settlements</h3>
          <div className={styles.resourceList}>
            <div
              key={1}
              className={styles.resourceItem}
            >
              <span className={styles.resourceIcon}>📦</span>
              <span className={styles.resourceName}>{cityName}</span>
            </div>
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Districts</h3>
          <div className={styles.resourceList}>
            <div
              key={1}
              className={styles.resourceItem}
            >
              <span className={styles.resourceIcon}>📦</span>
              <span className={styles.resourceName}>{districtName}</span>
              <span className={styles.resourceName}>{districtTypeName}</span>
            </div>
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Move cost</h3>
          <div
            className={styles.difficultyBadge}
            data-difficulty={totalMoveCost}
          >
            {totalMoveCost}
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Available Resources</h3>
          <div className={styles.resourceList}>
            <div
              key={1}
              className={styles.resourceItem}
            >
              <span className={styles.resourceIcon}>📦</span>
              <span className={styles.resourceName}>{`resource`}</span>
            </div>
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Possible Encounters</h3>
          <div className={styles.encounterList}>
            <div
              key={12}
              className={styles.encounterItem}
            >
              <Button
                className={styles.actionButton}
                onClick={() => {
                  handlePlayersListOnTile()
                }}
              >
                Players list on tile
              </Button>
            </div>
          </div>
        </section>
        <section className={styles.section}>
          <div className={styles.actionButtons}>
            <Button className={styles.actionButton}>Explore</Button>
            <Button
              className={styles.actionButton}
              variant='outline'
            >
              Set Camp
            </Button>
            {!isMoving ? (
              <Button
                className={styles.actionButton}
                variant='outline'
                onClick={() => {
                  handleMove()
                }}
              >
                Move Here
              </Button>
            ) : (
              <>
                <Button
                  className={styles.actionButton}
                  variant='outline'
                  onClick={() => {
                    handleConfirmMove()
                  }}
                >
                  Confirm Move
                </Button>
                <Button
                  className={styles.actionButton}
                  variant='outline'
                  onClick={() => {
                    handleCancelMove()
                  }}
                >
                  Cancel Move
                </Button>
              </>
            )}
          </div>
        </section>
      </div>
    </div>
  )
}
