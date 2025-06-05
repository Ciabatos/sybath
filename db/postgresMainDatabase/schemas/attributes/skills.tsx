"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TSkills = {
  id: number
  name: string
}

export type TSkillsById = Record<number, TSkills>

export async function getSkills() {
  try {
    const result = await query("SELECT * FROM attributes.skills")
    return result.rows as TSkills[]
  } catch (error) {
    console.error("Error fetching getSkills:", error)
    throw new Error("Failed to fetch getSkills")
  }
}
