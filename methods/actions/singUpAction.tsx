"use server"

import { insertUser } from "@/db/postgresMainDatabase/schemas/auth/functions/insertUser"
import { redirect } from "next/navigation"

export async function singUpAction(formData: FormData) {
  const email = formData.get("email") as string
  const password = formData.get("password") as string

  try {
    await insertUser(email, password)
  } catch (error) {
    console.error("Error singUpAction:", error)
    throw new Error("Failed to sing up")
  } finally {
    redirect("/error")
  }
}
