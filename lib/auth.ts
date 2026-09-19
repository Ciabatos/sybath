import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { betterAuth } from "better-auth"
import { nextCookies } from "better-auth/next-js"
import { anonymous } from "better-auth/plugins"
import { Pool } from "pg"

const DATABASE_URL = `postgresql://${process.env.DB_USER}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}?options=-c%20search_path%3Dauth`

export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
  },
  database: new Pool({
    connectionString: DATABASE_URL,
  }),
  plugins: [
    anonymous({
      onLinkAccount: async ({ anonymousUser, newUser }) => {
        console.log(
          "anon id:",
          anonymousUser.user.id,
          "new id:",
          newUser.user.id,
          "--------użyc metody ktora zaktualizuje wszystkie user_id ze starych na nowe",
        )
        const sql = `SELECT auth.replace_user_references($1, $2);`
        await query(sql, [anonymousUser.user.id, newUser.user.id])
      },
    }),
    nextCookies(),
  ],
})
