import dotenv from "dotenv"
import path from "path"
import { Client } from "pg"

dotenv.config({ path: path.resolve(process.cwd(), ".env.development") })

export function createClient() {
  return new Client({
    host: process.env.PG_MAIN_HOST,
    user: process.env.PG_MAIN_USER,
    password: process.env.PG_MAIN_PASSWORD ?? "",
    database: process.env.PG_MAIN_DATABASE,
    port: process.env.PG_MAIN_PORT ? Number(process.env.PG_MAIN_PORT) : undefined,
  })
}
