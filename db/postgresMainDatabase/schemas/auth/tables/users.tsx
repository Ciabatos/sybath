"use server"
import { pool } from "@/db/postgresMainDatabase/postgresMainDatabase"

export const getUsers = async () => {
  try {
    const result = await pool.query("SELECT * FROM auth.users")
    return result.rows
  } catch (error) {
    console.error("Error fetching users:", error)
    throw new Error("Failed to fetch users")
  }
}

export const getUserById = async (email: string) => {
  try {
    const result = await pool.query("SELECT name,email,password FROM auth.users WHERE email = $1", [email])
    return result.rows[0]
  } catch (error) {
    console.error(`Error fetching user with ID ${email}:`, error)
    throw new Error("Failed to fetch user")
  }
}
