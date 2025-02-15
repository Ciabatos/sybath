import { pool } from "@/db/postgresMainDatabase/postgresMainDatabase" 
import PostgresAdapter from "@auth/pg-adapter"
import NextAuth from "next-auth"
import authConfig from "./auth.config"


export const { handlers, signIn, signOut, auth } = NextAuth({
  adapter: PostgresAdapter(pool),
  session: { strategy: "jwt" },
  ...authConfig,
})