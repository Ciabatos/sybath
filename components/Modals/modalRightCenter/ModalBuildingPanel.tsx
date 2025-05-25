"use client"

import { Button } from "@/components/ui/button"
import { Drawer, DrawerClose, DrawerContent, DrawerDescription, DrawerFooter, DrawerHeader, DrawerTitle } from "@/components/ui/drawer"
import { cityTilesActionStatusAtom, clickedCityTileAtom } from "@/store/atoms"
import { ECityTilesActionStatus } from "@/types/enumeration/CityTilesActionStatusEnum"
import { useAtom, useAtomValue } from "jotai"

export function ModalBuildingPanel() {
  const [cityTilesActionStatus, setCityTilesActionStatus] = useAtom(cityTilesActionStatusAtom)
  const clickedCityTile = useAtomValue(clickedCityTileAtom)

  const handleClose = () => {
    setCityTilesActionStatus(ECityTilesActionStatus.Inactive)
  }

  return (
    <Drawer
      direction="right"
      open={cityTilesActionStatus === ECityTilesActionStatus.BuildingActionList}
      onOpenChange={(open) => {
        if (!open) {
          handleClose()
        }
      }}>
      <DrawerContent
        className="\ml-auto"
        style={{ width: "50%", maxWidth: "none" }}>
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
          <DrawerFooter className="mt-auto px-0">
            <Button>Submit</Button>
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
