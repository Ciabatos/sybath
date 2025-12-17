"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export async function getUser(email: string) {
  try {
    const result = await query(
      `SELECT 
          T1.name,
          T1.email,
          T1.password,
          T1.id as user_id,
          T2.id as player_id
       FROM auth.users T1
       JOIN players.players T2 ON T1.id = T2.user_id
       WHERE T1.email = $1
       ORDER BY T2.is_default DESC, T2.id ASC`,
      [email],
    )
    const data = snakeToCamelRows(result.rows)

    const user = {
      name: data[0].name,
      email: data[0].email,
      password: data[0].password,
      userId: data[0].userId,
      playerIds: data.map((row) => row.playerId),
      playerId: data[0].playerId,
    }

    return user
  } catch (error) {
    console.error(`Error fetching user with email ${email}:`, error)
    throw new Error("Failed to fetch user")
  }
}
