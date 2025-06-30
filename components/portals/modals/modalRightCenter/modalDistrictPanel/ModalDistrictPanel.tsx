"use client"

import { Button } from "@/components/ui/button"
import Inventory from "@/components/ui/custom/Inventory"
import { Drawer, DrawerClose, DrawerContent, DrawerDescription, DrawerFooter, DrawerHeader, DrawerTitle } from "@/components/ui/drawer"
import { useFetchDistrictInventorySlots } from "@/methods/hooks/districtInventory/core/useFetchDistrictInventorySlots"
import { useMapTileActions } from "@/methods/hooks/mapTiles/composite/useMapTileActions"

import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"

export function ModalDistrictPanel() {
  const { actualMapTilesActionStatus, resetMapTilesActionStatus } = useMapTilesActionStatus()
  const { clickedTile } = useMapTileActions()

  const { districtInventorySlots } = useFetchDistrictInventorySlots(clickedTile?.districts?.id)

  const handleClose = () => {
    resetMapTilesActionStatus()
  }

  return (
    <Drawer
      direction="right"
      open={actualMapTilesActionStatus.DistrictActionList}
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
            <DrawerTitle>{clickedTile?.districts?.type_name}</DrawerTitle>
            <DrawerDescription>{clickedTile?.districts?.name}</DrawerDescription>
          </DrawerHeader>
          <div className="flex-1 py-4">
            <div>
              {clickedTile?.districts?.map_tile_x} {clickedTile?.districts?.map_tile_y}
              <p>Zalożenie, że dystrykt produkuje co jakis interwał produky </p>
              <p>Pracuje tu full dostepnych ludzi z miasta</p>
              <p>Gracz moze uzyc opcji aby tu pracowac</p>
              <p>Zakładka dla Ownera</p>
              <p>Owner moze manipulowac stawkami wynagrodzenia</p>
              <p>Owner moze sprawdzac ekwipunek budynku</p>
              <p>Owner moze transportowac ekwipunek</p>
            </div>
          </div>
          <Inventory inventorySlots={districtInventorySlots}></Inventory>
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
