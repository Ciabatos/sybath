// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoTradeOpenParams = {
  playerId: number
  invitedPlayerId: string
}

export type TDoTradeOpen = {
  status: boolean
  message: string
}

export async function doTradeOpen(params: TDoTradeOpenParams) {
  try {
    const sqlParams = [params.playerId, params.invitedPlayerId]
    const sql = `SELECT * FROM trade.do_trade_open($1, $2);`
    const result = await query(sql, sqlParams)

    return result.rows[0] as TDoTradeOpen
  } catch (error) {
    console.error("Error executing doTradeOpen:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doTradeOpen")
  }
}
