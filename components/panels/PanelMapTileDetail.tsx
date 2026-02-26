"use client"

import { Button } from "@/components/ui/button"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useMapTileDetail } from "@/methods/hooks/world/composite/useMapTileDetail"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import { X } from "lucide-react"
import { useEffect, useState } from "react"
import styles from "./styles/PanelMapTileDetail.module.css"

export default function PanelMapTileDetail() {
  const { resetModalRightCenter } = useModalRightCenter()
  const { openModalTopCenter } = useModalTopCenter()
  const { clickedMapTile } = useMapTileActions()
  const { combinedKnownMapTilesResourcesOnTile } = useMapTileDetail()
  const { selectPlayerPathToClickedTile, selectPlayerPathAndMovePlayerToClickedTile, resetPlayerMovementPlanned } =
    usePlayerMovement()

  if (!clickedMapTile) {
    return null
  }

  const onClose = () => {
    resetModalRightCenter()
  }

  const [isMoving, setIsMoving] = useState(false)

  useEffect(() => {
    if (isMoving) {
      selectPlayerPathToClickedTile()
    }
  }, [clickedMapTile])

  function handlePlayersListOnTile() {
    openModalTopCenter(EPanelsTopCenter.PanelPlayersOnTile)
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

  const terrainName = clickedMapTile?.terrainTypes?.name

  const terrainTypesMoveCost = clickedMapTile?.terrainTypes?.moveCost
  const landscapeTypesMoveCost = clickedMapTile?.landscapeTypes?.moveCost
  const citiesMoveCost = clickedMapTile?.cities?.moveCost
  const districtTypesMoveCost = clickedMapTile?.districtTypes?.moveCost
  const totalMoveCost =
    (terrainTypesMoveCost || 0) + (landscapeTypesMoveCost || 0) + (citiesMoveCost || 0) + (districtTypesMoveCost || 0)

  const landscapeName = clickedMapTile?.landscapeTypes?.name
  const cityName = clickedMapTile?.cities?.name
  const districtName = clickedMapTile?.districts?.name
  const districtTypeName = clickedMapTile?.districtTypes?.name

  return (
    <div className={styles.panel}>
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>{terrainName}</h2>
          <p className={styles.description}>{landscapeName}</p>

          <span className={styles.coordinates}>
            [{clickedMapTile?.mapTiles.x}, {clickedMapTile?.mapTiles.y}]
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
          <h3 className={styles.sectionTitle}>Movement cost</h3>
          <div
            className={styles.difficultyBadge}
            data-difficulty={totalMoveCost}
          >
            {totalMoveCost}
          </div>
        </section>

        {cityName && (
          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>Settlements</h3>
            <div className={styles.resourceList}>
              <div
                key={
                  clickedMapTile?.mapTiles.mapId +
                  clickedMapTile?.mapTiles.x +
                  clickedMapTile?.mapTiles.y +
                  "Settlements"
                }
                className={styles.resourceItem}
              >
                <span className={styles.resourceIcon}>📦</span>
                <span className={styles.resourceName}>{cityName}</span>
              </div>
            </div>
          </section>
        )}

        {districtName && (
          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>Districts</h3>
            <div className={styles.resourceList}>
              <div
                key={
                  clickedMapTile?.mapTiles.mapId + clickedMapTile?.mapTiles.x + clickedMapTile?.mapTiles.y + "Districts"
                }
                className={styles.resourceItem}
              >
                <span className={styles.resourceIcon}>📦</span>
                <span className={styles.resourceName}>{districtName}</span>
                <span className={styles.resourceName}>{districtTypeName}</span>
              </div>
            </div>
          </section>
        )}

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Resources</h3>
          <div className={styles.resourceList}>
            <div
              key={
                clickedMapTile?.mapTiles.mapId + clickedMapTile?.mapTiles.x + clickedMapTile?.mapTiles.y + "Resources"
              }
              className={styles.resourceItem}
            >
              {combinedKnownMapTilesResourcesOnTile
                ?.filter((resource) => resource.itemId !== null)
                .map((resource) => (
                  <div key={resource.mapTilesResourceId + "KnownMapTilesResourcesOnTile"}>
                    <span className={styles.resourceIcon}>📦</span>
                    <span className={styles.resourceName}>{resource.name}</span>
                  </div>
                ))}
              {combinedKnownMapTilesResourcesOnTile && (
                <div className={styles.resourceStats}>
                  {`${Math.round(
                    (combinedKnownMapTilesResourcesOnTile.filter((r) => r.itemId !== null).length /
                      combinedKnownMapTilesResourcesOnTile.length) *
                      100,
                  )}%`}
                </div>
              )}
            </div>
          </div>
        </section>

        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Encounters</h3>
          <div className={styles.encounterList}>
            <div
              key={
                clickedMapTile?.mapTiles.mapId + clickedMapTile?.mapTiles.x + clickedMapTile?.mapTiles.y + "Encounters"
              }
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
            <div
              key={
                clickedMapTile?.mapTiles.mapId +
                clickedMapTile?.mapTiles.x +
                clickedMapTile?.mapTiles.y +
                "Players list on tile"
              }
              className={styles.encounterItem}
            >
              <Button
                className={styles.actionButton}
                // onClick={() => {
                //   handlePlayersListOnTile()
                // }}
              >
                Squad list on tile
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
