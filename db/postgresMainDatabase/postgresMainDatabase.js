import pg from "pg"
const { Pool } = pg

export const pool = new Pool({
  host: process.env.PG_MAIN_HOST,
  user: process.env.PG_MAIN_USER,
  password: process.env.PG_MAIN_PASSWORD,
  port: process.env.PG_MAIN_PORT,
  database: process.env.PG_MAIN_DATABASE,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
})
