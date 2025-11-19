"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TTasks<P> = {
  playerId: number
  methodName: string
  parameters: P //Record<string, unknown>
}

export async function insertTasks<P>({ playerId, methodName, parameters }: TTasks<P>) {
  try {
    const result = await query(`SELECT tasks.insert_task($1, $2, $3)`, [playerId, methodName, JSON.stringify(parameters)])
    return result
  } catch (error) {
    console.error("Error postTasks:", error)
    throw new Error("Failed to postTasks")
  }
}

export async function cancelTasks<P>({ playerId, methodName }: Omit<TTasks<P>, "parameters">) {
  try {
    const result = await query(`SELECT tasks.cancel_task($1, $2)`, [playerId, methodName])
    return result
  } catch (error) {
    console.error("Error cancelTasks:", error)
    throw new Error("Failed to cancelTasks")
  }
}
