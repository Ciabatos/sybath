"use client"

import PlayerTrade from "@/components/GeneratedComponents/PlayerTrade"
import GatherResource from "@/components/items/GatherResource"
import { Button } from "@/components/ui/button"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { usePlayerExploration } from "@/methods/hooks/players/composite/usePlayerExploration"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { TMapTileResource, useMapTileDetail } from "@/methods/hooks/world/composite/useMapTileDetail"
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
  const { exploreClickedTile } = usePlayerExploration()
  const [selectedResource, setSelectedResource] = useState<TMapTileResource | null>(null)

  useEffect(() => {
    setSelectedResource(null)
  }, [clickedMapTile])

  if (!clickedMapTile) {
    return null
  }

  const onClose = () => {
    resetModalRightCenter()
  }

  const [isMoving, setIsMoving] = useState(false)
  const [isExploring, setIsExploring] = useState(false)

  useEffect(() => {
    if (isMoving || isExploring) {
      selectPlayerPathToClickedTile()
    }
  }, [clickedMapTile])

  function handlePlayersListOnTile() {
    openModalTopCenter(EPanelsTopCenter.PanelPlayersOnTile)
  }

  function handleMove() {
    if (!isMoving) {
      setIsMoving(true)
      selectPlayerPathToClickedTile()
    }
  }

  function handleConfirmMove() {
    if (isMoving) {
      setIsMoving(false)
      selectPlayerPathAndMovePlayerToClickedTile()
    }
  }

  function handleCancelMove() {
    setIsMoving(false)
    resetPlayerMovementPlanned()
  }

  function handleExplore() {
    if (!isExploring) {
      setIsExploring(true)
      selectPlayerPathToClickedTile()
    }
  }

  function handleConfirmExplore() {
    if (isExploring) {
      setIsExploring(false)
      exploreClickedTile()
      resetPlayerMovementPlanned()
    }
  }

  function handleCancelExplore() {
    setIsExploring(false)
    resetPlayerMovementPlanned()
  }

  function handleResourceOnTile(resource: TMapTileResource) {
    setSelectedResource(resource)
    // openModalTopCenter(EPanelsTopCenter.PanelGatherResource)
  }

  function handleCloseGather() {
    setSelectedResource(null)
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
    <div className={styles.overlay}>
      <PlayerTrade></PlayerTrade>
      <GatherResource
        isOpen={!!selectedResource}
        onClose={handleCloseGather}
        resource={selectedResource}
      />
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
                    clickedMapTile?.mapTiles.mapId +
                    clickedMapTile?.mapTiles.x +
                    clickedMapTile?.mapTiles.y +
                    "Districts"
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
              {combinedKnownMapTilesResourcesOnTile
                ?.filter((resource) => resource.itemId !== null)
                .map((resource) => (
                  <Button
                    key={resource.mapTilesResourceId + "KnownMapTilesResourcesOnTile"}
                    className={styles.resourceItem}
                    onClick={() => {
                      handleResourceOnTile(resource)
                    }}
                  >
                    <span className={styles.resourceIcon}>📦</span>
                    <span className={styles.resourceName}>{resource.name}</span>
                  </Button>
                ))}

              {combinedKnownMapTilesResourcesOnTile && (
                <div className={styles.resourceStats}>
                  {`${
                    combinedKnownMapTilesResourcesOnTile.length === 0
                      ? 100
                      : Math.round(
                          (combinedKnownMapTilesResourcesOnTile.filter((r) => r.itemId !== null).length /
                            combinedKnownMapTilesResourcesOnTile.length) *
                            100,
                        )
                  }%`}
                </div>
              )}
            </div>
          </section>

          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>Encounters</h3>
            <div className={styles.encounterList}>
              <div
                key={
                  clickedMapTile?.mapTiles.mapId +
                  clickedMapTile?.mapTiles.x +
                  clickedMapTile?.mapTiles.y +
                  "Encounters"
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
              <Button
                className={styles.actionButton}
                variant='outline'
              >
                Set Camp
              </Button>

              {/* Ruch */}
              {isMoving ? (
                <>
                  <Button
                    className={styles.actionButton}
                    variant='outline'
                    onClick={handleConfirmMove}
                  >
                    Confirm Move
                  </Button>
                  <Button
                    className={styles.actionButton}
                    variant='outline'
                    onClick={handleCancelMove}
                  >
                    Cancel Move
                  </Button>
                </>
              ) : !isExploring ? (
                // Pokaż Move Here tylko jeśli NIE eksplorujemy
                <Button
                  className={styles.actionButton}
                  variant='outline'
                  onClick={handleMove}
                >
                  Move Here
                </Button>
              ) : null}

              {/* Eksploracja */}
              {isExploring ? (
                <>
                  <Button
                    className={styles.actionButton}
                    variant='outline'
                    onClick={handleConfirmExplore}
                  >
                    Confirm Explore
                  </Button>
                  <Button
                    className={styles.actionButton}
                    variant='outline'
                    onClick={handleCancelExplore}
                  >
                    Cancel Explore
                  </Button>
                </>
              ) : !isMoving ? (
                // Pokaż Explore Here tylko jeśli NIE ruszamy się
                <Button
                  className={styles.actionButton}
                  variant='outline'
                  onClick={handleExplore}
                >
                  Explore Here
                </Button>
              ) : null}
            </div>
          </section>
        </div>
      </div>
    </div>
  )
}
