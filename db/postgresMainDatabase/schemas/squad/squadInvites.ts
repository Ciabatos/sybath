// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TSquadInvitesParams = {
  playerId: number
}

export type TSquadInvites = {
  id: number
  description: string
  name: string
  nickname: string
  secondName: string
  createdAt: string
}

export type TSquadInvitesRecordById = Record<string, TSquadInvites>

export async function getSquadInvites(params: TSquadInvitesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM squad.get_squad_invites($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TSquadInvites[]
  } catch (error) {
    console.error("Error fetching getSquadInvites:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getSquadInvites")
  }
}
