"use server"

import { insertUser } from "@/db/postgresMainDatabase/schemas/auth/functions/insertUser"

export async function signUpAction(state: string | null | undefined, formData: FormData) {
  const email = formData.get("email") as string
  const password = formData.get("password") as string

  try {
    await insertUser(email, password)
  } catch (error) {
    console.error("Error signUpAction :", error)
    // throw new Error("Failed to sing up")
    return "Failed to sing up"
  }
}
