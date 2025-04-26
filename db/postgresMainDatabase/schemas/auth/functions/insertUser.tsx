"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import bcrypt from "bcrypt"

export async function insertUser(email: string, password: string) {
  const hashedPassword = await bcrypt.hash(password as string, 10)

  try {
    const result = await query("SELECT auth.insert_user($1, $2)", [email, hashedPassword])
    return result.rows[0]
  } catch (error) {
    console.error(`Error inserting user with email ${email}:`, error)
    throw new Error("Failed to insert user")
  }
}
