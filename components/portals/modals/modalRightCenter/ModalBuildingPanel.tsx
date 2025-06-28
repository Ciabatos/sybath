"use client"

import { Button } from "@/components/ui/button"
import Inventory from "@/components/ui/custom/Inventory"
import { Drawer, DrawerClose, DrawerContent, DrawerDescription, DrawerFooter, DrawerHeader, DrawerTitle } from "@/components/ui/drawer"
import { useFetchBuildingInventorySlots } from "@/methods/hooks/buildingInventory/core/useFetchBuildingInventorySlots"
import { useCityTilesManipulation } from "@/methods/hooks/cityTiles/composite/useCityTilesManipulation"
import { useCityTilesActionStatus } from "@/methods/hooks/cityTiles/core/useCityTilesActionStatus"

export function ModalBuildingPanel() {
  const { resetNewCityTilesActionStatus, actualCityTileStatus } = useCityTilesActionStatus()
  const { clickedCityTile } = useCityTilesManipulation()
  const { buildingInventorySlots } = useFetchBuildingInventorySlots(clickedCityTile?.buildings?.id)

  const handleClose = () => {
    resetNewCityTilesActionStatus()
  }

  return (
    <Drawer
      direction="right"
      open={actualCityTileStatus.BuildingActionList}
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
            <DrawerTitle>{clickedCityTile?.buildings?.type_name}</DrawerTitle>
            <DrawerDescription>{clickedCityTile?.buildings?.name}</DrawerDescription>
          </DrawerHeader>
          <div className="flex-1 py-4">
            <div>
              {clickedCityTile?.buildings?.city_tile_x} {clickedCityTile?.buildings?.city_tile_y}
            </div>
          </div>
          <Inventory inventorySlots={buildingInventorySlots}></Inventory>
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
