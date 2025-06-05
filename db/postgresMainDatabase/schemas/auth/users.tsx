"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export async function getUsers() {
  try {
    const result = await query(
      `SELECT 
      T1.name
      ,T1.email
      ,T1.password
      ,T2.id
       FROM auth.users T1 
       JOIN players.players  T2 ON T1.id = T2.user_id
       `,
    )
    return result.rows
  } catch (error) {
    console.error("Error fetching users:", error)
    throw new Error("Failed to fetch users")
  }
}

export async function getUser(email: string) {
  try {
    const result = await query(
      `SELECT 
      T1.name
      ,T1.email
      ,T1.password
      ,T2.id
       FROM auth.users T1 
       JOIN players.players  T2 ON T1.id = T2.user_id
       WHERE email = $1`,
      [email],
    )
    return result.rows[0]
  } catch (error) {
    console.error(`Error fetching user with ID ${email}:`, error)
    throw new Error("Failed to fetch user")
  }
}
