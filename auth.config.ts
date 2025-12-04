import { getUser } from "@/db/postgresMainDatabase/schemas/auth/users"
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
          const user = await getUser(email as string)
          const isPasswordValid = await bcrypt.compare(password as string, user.password)

          if (!isPasswordValid) {
            return null
          }
          const returnedData = {
            email: user.email,
            name: user.name,
            userId : user.userId,
            playerId: user.playerId,
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
        token.userId = user.userId
        token.playerId = user.playerId
      }
      return token
    },
    session({ session, token }) {
      session.user.userId = token.userId as number
      session.user.playerId = token.playerId as number
      return session
    },
  },
  pages: {
    // signIn: "/auth/signin",
    // signOut: "/auth/signout",
    // error: "/auth/error", // Error code passed in query string as ?error=
    // verifyRequest: "/auth/verify-request", // (used for check email message)
    // newUser: "/auth/new-user", // New users will be directed here on first sign in (leave the property out if not of interest)
  },
} satisfies NextAuthConfig
