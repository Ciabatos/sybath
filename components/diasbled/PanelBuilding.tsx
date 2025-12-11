"use client"

import { Button } from "@/components/ui/button"
import Inventory from "@/components/ui/custom/Inventory"
import {
  Drawer,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerFooter,
  DrawerHeader,
  DrawerTitle,
} from "@/components/ui/drawer"
import { useFetchBuildingInventorySlots } from "@/methods/hooks/buildingInventory/core/useFetchBuildingInventorySlots"
import { useCityTilesActionStatus } from "@/methods/hooks/cities/composite/useCityTilesActionStatus"
import { useCityTilesActions } from "@/methods/hooks/cities/composite/useCityTilesActions"

export function PanelBuilding() {
  const { resetNewCityTilesActionStatus, actualCityTileStatus } = useCityTilesActionStatus()
  const { getClickedCityTile } = useCityTilesActions()
  const { buildingInventorySlots } = useFetchBuildingInventorySlots(getClickedCityTile()?.buildings?.id)

  const handleClose = () => {
    resetNewCityTilesActionStatus()
  }

  return (
    <Drawer
      direction='right'
      open={actualCityTileStatus.BuildingActionList}
      onOpenChange={(open) => {
        if (!open) {
          handleClose()
        }
      }}
    >
      <DrawerContent
        className='\ml-auto'
        style={{ width: "40%", maxWidth: "none" }}
      >
        <div className='flex h-full flex-col p-6'>
          <DrawerHeader className='px-0'>
            <DrawerTitle>{getClickedCityTile()?.buildings?.type_name}</DrawerTitle>
            <DrawerDescription>{getClickedCityTile()?.buildings?.name}</DrawerDescription>
          </DrawerHeader>
          <div className='flex-1 py-4'>
            <div>
              {getClickedCityTile()?.buildings?.city_tile_x} {getClickedCityTile()?.buildings?.city_tile_y}
            </div>
          </div>
          <Inventory inventorySlots={buildingInventorySlots}></Inventory>
          <DrawerFooter className='mt-auto px-0'>
            <DrawerClose asChild>
              <Button
                variant='outline'
                onClick={handleClose}
              >
                Cancel
              </Button>
            </DrawerClose>
          </DrawerFooter>
        </div>
      </DrawerContent>
    </Drawer>
  )
}
