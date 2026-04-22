import dotenv from "dotenv"
import path from "path"
import { Client } from "pg"

dotenv.config({ path: path.resolve(process.cwd(), ".env.development") })

export const createClient = () =>
  new Client({
    host:     process.env.DB_HOST,
    user:     process.env.DB_USER,
    password: process.env.DB_PASSWORD ?? "",
    database: process.env.DB_NAME,
    port:     process.env.DB_PORT ? Number(process.env.DB_PORT) : undefined,
  })
