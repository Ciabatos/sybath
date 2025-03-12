import { getUserById } from "@/db/postgresMainDatabase/schemas/auth/tables/users"
import bcrypt from "bcrypt"
import type { NextAuthConfig } from "next-auth"
import Credentials from "next-auth/providers/credentials"

export default {
  providers: [
    Credentials({
      name: "Sign in",
      credentials: {
        email: {
          label: "Email",
          type: "email",
          placeholder: "example@example.com",
        },
        password: { label: "Password", type: "password" },
      },

      async authorize(credentials) {
        try {
          const email: unknown = credentials.email
          const password: unknown = credentials.password
          // const hashedPassword = await bcrypt.hash(password as string, 10)
          const user = await getUserById(email as string)
          const isPasswordValid = await bcrypt.compare(password as string, user.password)

          if (!isPasswordValid) {
            return null
          }
          const returnedData = {
            email: user.email,
            name: user.name,
            role: user.role,
          }

          return returnedData
        } catch (error) {
          console.error("Error during authentication:", error)
          throw new Error("Authentication failed.")
        }
      },
    }),
  ],
  callbacks: {
    jwt({ token, user }) {
      if (user) {
        // User is available during sign-in and this return token to session who take it and assign role
        token.role = user.role
      }
      return token
    },
    session({ session, token }) {
      session.user.role = token.role as string
      return session
    },
  },
} satisfies NextAuthConfig
