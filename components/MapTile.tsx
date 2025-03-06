"use client"

import style from "@/components/styles/MapTile.module.css"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { useClickMapTile } from "@/methods/hooks/useClickTile"
import { useCreateBackgroundImage } from "@/methods/hooks/useCreateBackgroundImage"
import { useCreatePlayerImage } from "@/methods/hooks/useCreatePlayerImage"
import { openModalBottomCenterBarAtom } from "@/store/atoms"
import { EModalStatus } from "@/types/enumeration/ModalBottomCenterBarEnum"
import { useSetAtom } from "jotai"

interface Props {
  tile: TjoinedMapTile
}

export default function MapTile({ tile }: Props) {
  const { setCoordinatesOnClick } = useClickMapTile()
  const setIsModalMapTilesPlayerActionBarOpen = useSetAtom(openModalBottomCenterBarAtom)
  const backgroundImage = useCreateBackgroundImage(tile.image_url)
  const playerImage = useCreatePlayerImage(tile.player_image_url)

  const handleClick = (x: number, y: number) => {
    setCoordinatesOnClick(x, y)
    setIsModalMapTilesPlayerActionBarOpen(EModalStatus.PlayerActionBar)
  }

  return (
    <>
      <div
        className={style.BackgroundImage}
        onClick={() => handleClick(tile.x, tile.y)}
        style={{
          gridColumnStart: tile.x,
          gridRowStart: tile.y,
          backgroundImage: backgroundImage,
        }}>
        <div
          className={style.PlayerImage}
          style={{
            backgroundImage: playerImage,
          }}></div>
        <div>
          {tile.x}, {tile.y}
        </div>
      </div>
    </>
  )
}
