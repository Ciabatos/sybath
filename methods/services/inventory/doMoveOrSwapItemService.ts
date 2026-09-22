// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoMoveOrSwapItemParams, doMoveOrSwapItem } from "@/db/postgresMainDatabase/schemas/inventory/doMoveOrSwapItem"

//MANUAL CODE - START

export type TDoMoveOrSwapItemServiceParams = {
  userId: string
  playerId: number
  fromSlotId: number
  toSlotId: number
  fromInventoryContainerId: number
  toInventoryContainerId: number
}

//MANUAL CODE - END

export async function doMoveOrSwapItemService(params: TDoMoveOrSwapItemServiceParams) {
  try {
    const userId = params.userId
    const playerId = params.playerId

    //MANUAL CODE - START

    const fromSlotId = params.fromSlotId
    const toSlotId = params.toSlotId
    const fromInventoryContainerId = params.fromInventoryContainerId
    const toInventoryContainerId = params.toInventoryContainerId

    if (fromSlotId === toSlotId && fromInventoryContainerId === toInventoryContainerId) {
      return {
        status: false,
        message: "Cannot switch to the same slot",
      }
    }
    //MANUAL CODE - END

    const data: TDoMoveOrSwapItemParams = {
      userId: userId,
      playerId: playerId,
      fromSlotId: fromSlotId,
      toSlotId: toSlotId,
      fromInventoryContainerId: fromInventoryContainerId,
      toInventoryContainerId: toInventoryContainerId,
    }

    const result = await doMoveOrSwapItem(data)
    return result
  } catch (error) {
    console.error("Error doMoveOrSwapItemService :", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    return {
      status: false,
      message: "Unexpected error occurred. Please refresh the page.",
    }
  }
}
