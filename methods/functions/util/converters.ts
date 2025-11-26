// export function arrayToObjectKeyId<T extends Record<K, number>, K extends keyof T>(
//   key: K, // The key property name (e.g., 'id')
//   arr: T[], // The array of objects
// ): { [key: number]: T } {
//   return arr.reduce(
//     (acc, item) => {
//       acc[item[key]] = item // Use the provided key to access the value
//       return acc
//     },
//     {} as { [key: number]: T },
//   )
// }

// export function arrayToObjectKey<T extends Record<K1 | K2, number>, K1 extends keyof T, K2 extends keyof T>(
//   key1: K1, // Pierwsza właściwość klucza
//   key2: K2, // Druga właściwość klucza
//   arr: T[], // Tablica obiektów
// ): { [key: string]: T } {
//   // Używamy string jako klucza, ponieważ łączymy dwie wartości
//   return arr.reduce(
//     (acc, item) => {
//       const compositeKey = `${item[key1]},${item[key2]}` // Tworzymy klucz z dwóch właściwości
//       acc[compositeKey] = item // Przypisujemy obiekt do klucza
//       return acc
//     },
//     {} as { [key: string]: T },
//   )
// }


export function arrayToObjectKey<T extends Record<string, any>, K extends keyof T>(
  keys: K[],
  arr: T[],
): { [key: string]: T } {
  return arr.reduce((acc, item) => {
    const compositeKey = keys.map(k => item[k]).join(',');
    acc[compositeKey] = item;
    return acc;
  }, {} as { [key: string]: T });
}