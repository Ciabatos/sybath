import { Client } from "pg"
import dotenv from "dotenv"
import path from "path"

dotenv.config({ path: path.resolve(process.cwd(), ".env.development") })

export class DbClient {
  private config = {
    host: process.env.PG_MAIN_HOST,
    user: process.env.PG_MAIN_USER,
    password: process.env.PG_MAIN_PASSWORD || "",
    database: process.env.PG_MAIN_DATABASE,
    port: process.env.PG_MAIN_PORT ? Number(process.env.PG_MAIN_PORT) : undefined,
  }

  async withConnection<T>(callback: (client: Client) => Promise<T>): Promise<T> {
    const client = new Client(this.config)
    try {
      await client.connect()
      return await callback(client)
    } finally {
      await client.end()
    }
  }
}

export const dbClient = new DbClient()
