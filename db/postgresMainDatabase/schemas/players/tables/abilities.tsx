"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TAbilities = {
  id: number
  name: string
}

export type TAbilitiesById = Record<number, TAbilities>

export async function getAbilities() {
  try {
    const result = await query("SELECT * FROM players.abilities")
    return result.rows as TAbilities[]
  } catch (error) {
    console.error("Error fetching getAbilities:", error)
    throw new Error("Failed to fetch getAbilities")
  }
}
