"use client"

import GatherResource from "@/components/items/GatherResource"
import { Button } from "@/components/ui/button"
import { Field, FieldLabel } from "@/components/ui/field"
import { Progress } from "@/components/ui/progress"
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

  // ── MOVEMENT LOGIC  ──────────────────────────────────────────
  const { selectPlayerPathToClickedTile, selectPlayerPathAndMovePlayerToClickedTile, resetPlayerMovementPlanned } =
    usePlayerMovement()
  const [isMoving, setIsMoving] = useState(false)

  // ── EXPLORATION LOGIC  ──────────────────────────────────────────
  const { exploreClickedTile } = usePlayerExploration()
  const [isExploring, setIsExploring] = useState(false)

  // ── GATHER LOGIC  ──────────────────────────────────────────
  const { combinedKnownMapTilesResourcesOnTile } = useMapTileDetail()
  const [clickedResource, setClickedResource] = useState<TMapTileResource | null>(null)

  if (!clickedMapTile) {
    return null
  }

  useEffect(() => {
    setClickedResource(null)
    if (isMoving || isExploring) {
      selectPlayerPathToClickedTile()
    }
  }, [clickedMapTile])

  const onClose = () => {
    resetModalRightCenter()
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

  function handlePlayersListOnTile() {
    openModalTopCenter(EPanelsTopCenter.PanelPlayersOnTile)
  }

  function handleResourceOnTile(resource: TMapTileResource) {
    setClickedResource(resource)
    // openModalTopCenter(EPanelsTopCenter.PanelGatherResource)
  }

  function handleCloseGather() {
    setClickedResource(null)
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
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
      <GatherResource
        isOpen={!!clickedResource}
        onClose={handleCloseGather}
        resource={clickedResource}
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
                  <Field className='w-full max-w-sm'>
                    <FieldLabel htmlFor='progress-upload'>
                      <span>Exploration progress</span>
                      <span className='ml-auto'>{`${
                        combinedKnownMapTilesResourcesOnTile.length === 0
                          ? 100
                          : Math.round(
                              (combinedKnownMapTilesResourcesOnTile.filter((r) => r.itemId !== null).length /
                                combinedKnownMapTilesResourcesOnTile.length) *
                                100,
                            )
                      }%`}</span>
                    </FieldLabel>
                    <Progress
                      value={
                        combinedKnownMapTilesResourcesOnTile.length === 0
                          ? 100
                          : Math.round(
                              (combinedKnownMapTilesResourcesOnTile.filter((r) => r.itemId !== null).length /
                                combinedKnownMapTilesResourcesOnTile.length) *
                                100,
                            )
                      }
                      id='progress-upload'
                    />
                  </Field>
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
              <Button className={styles.actionButton}>Set Camp</Button>

              {/*  MOVEMENT LOGIC */}
              {!isMoving ? (
                <Button
                  className={styles.actionButton}
                  onClick={handleMove}
                >
                  Move
                </Button>
              ) : (
                <>
                  <Button
                    className={styles.actionButton}
                    onClick={handleConfirmMove}
                  >
                    Confirm Move
                  </Button>

                  <Button
                    className={styles.actionButton}
                    onClick={handleCancelMove}
                  >
                    Cancel Move
                  </Button>
                </>
              )}

              {/*  HUNT LOGIC */}
              <Button className={styles.actionButton}>Hunt</Button>

              {/*  EXPLORATION LOGIC */}
              {!isExploring ? (
                <Button
                  className={styles.actionButton}
                  onClick={handleExplore}
                >
                  Explore
                </Button>
              ) : (
                <>
                  <Button
                    className={styles.actionButton}
                    onClick={handleConfirmExplore}
                  >
                    Confirm Exploration
                  </Button>

                  <Button
                    className={styles.actionButton}
                    onClick={handleCancelExplore}
                  >
                    Cancel Exploration
                  </Button>
                </>
              )}

              <Button className={styles.actionButton}>Gather</Button>
            </div>
          </section>
        </div>
      </div>
    </div>
  )
}
