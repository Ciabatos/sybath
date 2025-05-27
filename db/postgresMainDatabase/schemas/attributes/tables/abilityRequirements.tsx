"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TAbilityRequirements = {
  id: number
  ability_id: number
  requirement_type: string
  requirement_id: number
  min_value: number
}

export async function getAbilityRequirements(abilityId: number) {
  if (!abilityId || isNaN(abilityId)) {
    return null
  }

  try {
    const result = await query(`SELECT *	FROM attributes.ability_requirements WHERE ability_id = $1`, [abilityId])
    return result.rows as TAbilityRequirements[]
  } catch (error) {
    console.error("Error fetching getAbilityRequirements:", error)
    throw new Error("Failed to fetch getAbilityRequirements")
  }
}
