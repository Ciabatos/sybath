"use client"

export default function MapTileLayerGuardAreaAction() {
  return (
    <>
      <svg
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ position: "absolute", top: 0, left: 0, width: "100%", height: "100%" }}>
        <rect
          width="100%"
          height="100%"
          fill="yellow"
          opacity={0.3333}
        />
      </svg>
    </>
  )
}
