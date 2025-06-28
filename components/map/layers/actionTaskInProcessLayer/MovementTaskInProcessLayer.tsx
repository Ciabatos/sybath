"use client"

import { TMovementActionTaskInProcess } from "@/db/postgresMainDatabase/schemas/map/movementActionInProcess"

interface Props {
  movementActionTask: TMovementActionTaskInProcess
}

export default function MovementTaskInProcessLayer({ movementActionTask }: Props) {
  return (
    <>
      <p>{movementActionTask?.scheduled_at?.toString()}</p>
      <svg
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ position: "absolute", top: 0, left: 0, width: "100%", height: "100%" }}>
        <rect
          width="100%"
          height="100%"
          fill="red"
          opacity={0.5}
        />
      </svg>
    </>
  )
}
