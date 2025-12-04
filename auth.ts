import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import PostgresAdapter from "@auth/pg-adapter"
import NextAuth, { type DefaultSession } from "next-auth"
import { Adapter } from "next-auth/adapters"
import authConfig from "./auth.config"

//I have to changes types to get role from database
declare module "next-auth" {
  /**
   * Returned by `useSession`, `getSession` and received as a prop on the `SessionProvider` React Context
   */
  interface Session {
    user: {
      /** The user's role. */
      userId: number
      playerId: number
    } & DefaultSession["user"]
  }
  interface User {
    userId: number
    playerId: number
  }
}

export const { handlers, signIn, signOut, auth } = NextAuth({
  adapter: PostgresAdapter(query) as Adapter,
  session: { strategy: "jwt" },
  ...authConfig,
})
