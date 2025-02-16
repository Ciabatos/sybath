"use client"
import style from "./styles/Map.module.css"
import { TransformWrapper, TransformComponent } from "react-zoom-pan-pinch"

interface TServerComponentChildrenProps {
  children: React.ReactNode
}

export default function Map({ children }: TServerComponentChildrenProps) {
  return (
    <>
      <div
        id="Map"
        className={`${style.map} `}>
        <TransformWrapper
          minScale={0.4}
          limitToBounds={false}
          doubleClick={{ disabled: true }}>
          <TransformComponent>
            <div
              id="Tiles"
              className={style.Tiles}>
              {children}
            </div>
          </TransformComponent>
        </TransformWrapper>
      </div>
    </>
  )
}
