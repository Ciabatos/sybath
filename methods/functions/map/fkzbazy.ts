import { Pool } from "pg"

const pool = new Pool({
  /* konfiguracja bazy */
})

export type ForeignKeyInfo<TMain> = {
  mainColumn: keyof TMain | (keyof TMain)[]
  foreignTable: string
  foreignColumn?: string | string[]
}

export async function getForeignKeys<TMain>(tableName: string): Promise<ForeignKeyInfo<TMain>[]> {
  const query = `
    SELECT
      kcu.column_name AS main_column,
      ccu.table_name AS foreign_table,
      ccu.column_name AS foreign_column
    FROM
      information_schema.table_constraints AS tc
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
      JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
    WHERE
      tc.constraint_type = 'FOREIGN KEY'
      AND kcu.table_name = $1
  `
  const res = await pool.query(query, [tableName])

  return res.rows.map((row) => ({
    mainColumn: row.main_column as keyof TMain,
    foreignTable: row.foreign_table,
    foreignColumn: row.foreign_column,
  }))
}

//dodac do hooka i gettera fettchera forgein keye i tyle, kluczy glownych nie trzeba znac bo jak mam forgein key table i klucz to juz wiem do czego sie laczyc i tylko w [] wpisuje polaczony klucz
