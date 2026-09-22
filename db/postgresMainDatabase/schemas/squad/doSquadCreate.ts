// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelKeys } from "@/methods/functions/util/snakeToCamel"


export type TDoSquadCreateParams = {
  userId: string
  playerId: number
}

export type TDoSquadCreate = {
  status: boolean
  message: string
}

export async function doSquadCreate(params: TDoSquadCreateParams) {
  try {
    const sqlParams = [
      params.userId
      ,
      params.playerId
      
    ]
    const sql = `SELECT * FROM squad.do_squad_create($1, $2);`
    const result = await query(sql, sqlParams)


    return snakeToCamelKeys(result.rows[0]) as TDoSquadCreate
  } catch (error) {
    console.error("Error executing doSquadCreate:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to execute doSquadCreate")
  }
}