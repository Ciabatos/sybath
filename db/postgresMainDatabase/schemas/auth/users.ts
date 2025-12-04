"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"


export async function getUser(email: string) {
  try {
    const result = await query(
      `SELECT 
      T1.name
      ,T1.email
      ,T1.password
      ,T1.id as userId
      ,T2.id as playerId
       FROM auth.users T1 
       JOIN players.players  T2 ON T1.id = T2.user_id
       WHERE email = $1
       ORDER BY T2.id ASC
       LIMIT 1 `,
      [email],
    )
    return result.rows[0]
  } catch (error) {
    console.error(`Error fetching user with ID ${email}:`, error)
    throw new Error("Failed to fetch user")
  }
}
