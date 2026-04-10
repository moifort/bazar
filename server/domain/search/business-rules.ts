import type { SearchEntry } from './types'

export const normalize = (text: string) =>
  text
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim()
    .replace(/\s+/g, ' ')

export const fuzzyScore = (query: string, text: string) => {
  const q = normalize(query)
  const t = normalize(text)

  if (q.length === 0) return 0
  if (t === q) return 100
  if (t.startsWith(q)) return 80

  const words = t.split(' ')
  if (words.some((word) => word.startsWith(q))) return 60
  if (t.includes(q)) return 40

  if (q.length >= 3 && levenshtein(q, t.slice(0, q.length + 2)) <= 2) return 20

  return 0
}

export const searchEntries = (entries: SearchEntry[], query: string, limit: number) => {
  const normalizedQuery = normalize(query)
  if (normalizedQuery.length === 0) return []

  return entries
    .map((entry) => ({ entry, score: fuzzyScore(query, entry.text) }))
    .filter(({ score }) => score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map(({ entry }) => entry)
}

const levenshtein = (a: string, b: string) => {
  const m = a.length
  const n = b.length
  const dp: number[][] = Array.from({ length: m + 1 }, (_, i) =>
    Array.from({ length: n + 1 }, (_, j) => (i === 0 ? j : j === 0 ? i : 0)),
  )

  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      dp[i][j] =
        a[i - 1] === b[j - 1]
          ? dp[i - 1][j - 1]
          : 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1])
    }
  }

  return dp[m][n]
}
