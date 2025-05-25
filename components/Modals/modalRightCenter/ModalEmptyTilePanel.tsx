"use client"

import { Button } from "@/components/ui/button"
import { Drawer, DrawerClose, DrawerContent, DrawerDescription, DrawerFooter, DrawerHeader, DrawerTitle } from "@/components/ui/drawer"
import { clickedTileAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtom, useAtomValue } from "jotai"

export function ModalEmptyTilePanel() {
  const [mapTilesActionStatus, setMapTilesActionStatus] = useAtom(mapTilesActionStatusAtom)
  const clickedTile = useAtomValue(clickedTileAtom)

  const handleClose = () => {
    setMapTilesActionStatus(EMapTilesActionStatus.Inactive)
  }

  return (
    <Drawer
      direction="right"
      open={mapTilesActionStatus === EMapTilesActionStatus.EmptyTileActionList}
      onOpenChange={(open) => {
        if (!open) {
          handleClose()
        }
      }}>
      <DrawerContent
        className="\ml-auto"
        style={{ width: "40%", maxWidth: "none" }}>
        <div className="flex h-full flex-col p-6">
          <DrawerHeader className="px-0">
            <DrawerTitle>{clickedTile?.terrainTypes?.name}</DrawerTitle>
            <DrawerDescription>{clickedTile?.landscapeTypes?.name}</DrawerDescription>
          </DrawerHeader>
          <div className="flex-1 py-4">
            <div>
              {clickedTile?.moveCost} {clickedTile?.mapTile.x} {clickedTile?.mapTile.y}
            </div>
          </div>
          <DrawerFooter className="mt-auto px-0">
            <DrawerClose asChild>
              <Button
                variant="outline"
                onClick={handleClose}>
                Cancel
              </Button>
            </DrawerClose>
          </DrawerFooter>
        </div>
      </DrawerContent>
    </Drawer>
  )
}
