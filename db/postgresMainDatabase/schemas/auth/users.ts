"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export async function getUser(email: string) {
  try {
    const result = await query(
      `SELECT 
          T1.name,
          T1.email,
          T1.password,
          T1.id as userId,
          T2.id as playerId
       FROM auth.users T1
       JOIN players.players T2 ON T1.id = T2.user_id
       WHERE T1.email = $1
       ORDER BY T1.is_default DESC, T2.id ASC`,
      [email],
    )

    const user = {
      name: result.rows[0].name,
      email: result.rows[0].email,
      password: result.rows[0].password,
      userId: result.rows[0].userId,
      playerIds: result.rows.map((row) => row.playerId),
      playerId: result.rows[0].playerId,
    }

    return user
  } catch (error) {
    console.error(`Error fetching user with email ${email}:`, error)
    throw new Error("Failed to fetch user")
  }
}
