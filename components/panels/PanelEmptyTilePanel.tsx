"use client"

import { Button } from "@/components/ui/button"
import { Drawer, DrawerClose, DrawerContent, DrawerDescription, DrawerFooter, DrawerHeader, DrawerTitle } from "@/components/ui/drawer"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"

import { useModal } from "@/methods/hooks/modals/useModal"

export function PanelEmptyTilePanel() {
  const { actualMapTilesActionStatus, resetMapTilesActionStatus } = useModal()
  const { getClickedMapTile } = useMapTileActions()

  const handleClose = () => {
    resetMapTilesActionStatus()
  }

  return (
    <Drawer
      direction="right"
      open={actualMapTilesActionStatus.EmptyTileActionList}
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
            <DrawerTitle>{getClickedMapTile()?.terrainTypes?.name}</DrawerTitle>
            <DrawerDescription>{getClickedMapTile()?.landscapeTypes?.name}</DrawerDescription>
          </DrawerHeader>
          <div className="flex-1 py-4">
            <div>
              {getClickedMapTile()?.moveCost} {getClickedMapTile()?.tiles.x} {getClickedMapTile()?.tiles.y}
              <p>Zalożenie, że Tile mozna odkrywac i wtedy eventy sie pojawiaja np walka </p>
              <p>Mozna po odkryciu cos tu wybudowac miasto/dystrykt w celu wydobycia surowca</p>
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
