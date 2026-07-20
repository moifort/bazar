/**
 * Architecture unit tests — the conventions of docs/ made executable.
 * This file is intentionally at the server root and self-excluded from the
 * co-location rule.
 */
import { describe, expect, test } from 'bun:test'
import { globSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { basename, dirname, join } from 'node:path'

const SERVER_DIR = join(import.meta.dir)
const DOMAIN_DIR = join(SERVER_DIR, 'domain')
const ROOT = join(SERVER_DIR, '..')

const domains = readdirSync(DOMAIN_DIR).filter((d) => statSync(join(DOMAIN_DIR, d)).isDirectory())

const readFile = (path: string) => readFileSync(join(ROOT, path), 'utf-8')

const glob = (pattern: string) => globSync(pattern, { cwd: ROOT })

const linesOf = (file: string) => readFile(file).split('\n')

describe('architecture', () => {
  describe('each domain has a types.ts', () => {
    for (const domain of domains) {
      test(domain, () => {
        expect(statSync(join(DOMAIN_DIR, domain, 'types.ts')).isFile()).toBe(true)
      })
    }
  })

  describe('primitives.ts imports ts-brand and zod', () => {
    // Pure re-export files carry no constructor of their own — nothing to brand.
    const ownPrimitives = glob('server/domain/*/primitives.ts').filter((file) =>
      linesOf(file).some((line) => line.trim() !== '' && !line.startsWith('export ')),
    )

    for (const file of ownPrimitives) {
      test(basename(dirname(file)), () => {
        const content = readFile(file)
        expect(content).toContain('ts-brand')
        expect(content).toContain('zod')
      })
    }
  })

  test('no console.log/error/warn in server code', () => {
    const serverFiles = glob('server/**/*.ts').filter(
      (f) => !f.includes('test/') && !f.endsWith('.test.ts'),
    )
    const violations: string[] = []
    for (const file of serverFiles) {
      linesOf(file).forEach((line, i) => {
        if (/console\.(log|error|warn)/.test(line))
          violations.push(`${file}:${i + 1}: ${line.trim()}`)
      })
    }
    expect(violations).toEqual([])
  })

  test('no cross-domain repository imports', () => {
    const domainFiles = glob('server/domain/**/*.ts').filter((f) => !f.endsWith('.test.ts'))
    const violations: string[] = []
    for (const file of domainFiles) {
      const currentDomain = file.split('/')[2]
      linesOf(file).forEach((line, i) => {
        const match = line.match(/from\s+['"]~\/domain\/(\w+)\/infrastructure\/repository['"]/)
        if (match && match[1] !== currentDomain) {
          violations.push(`${file}:${i + 1}: imports ${match[1]}/infrastructure/repository`)
        }
      })
    }
    expect(violations).toEqual([])
  })

  describe('tests are co-located with source files', () => {
    const testFiles = glob('server/**/*.test.ts').filter(
      (f) => f !== 'server/architecture.unit.test.ts',
    )
    const validSuffixes = ['.unit.test.ts', '.int.test.ts', '.feat.test.ts']

    test('each test file uses a valid suffix', () => {
      expect(testFiles.filter((f) => !validSuffixes.some((s) => f.endsWith(s)))).toEqual([])
    })

    test('each test file sits next to a source file', () => {
      const violations = testFiles.filter((testFile) => {
        const siblings = readdirSync(dirname(join(ROOT, testFile)))
        return !siblings.some((f) => f.endsWith('.ts') && !f.endsWith('.test.ts'))
      })
      expect(violations).toEqual([])
    })
  })

  describe('query.ts and command.ts name the business concept, not the technical pattern', () => {
    // Exported names must carry intent, never a getX/computeX/handleX scaffold.
    // Reads read as `all`, `byId`, `view`; writes as the business action (`add`,
    // `move`). `findAll`/`findBy` stay — repository idiom.
    const banned = /export const (get|compute|handle|process|manage|perform|fetch)[A-Z]/

    for (const file of glob('server/domain/*/{query,command,business-rules}.ts')) {
      test(`${basename(dirname(file))}/${basename(file)}`, () => {
        const violations: string[] = []
        linesOf(file).forEach((line, i) => {
          if (banned.test(line)) violations.push(`${file}:${i + 1}: ${line.trim()}`)
        })
        expect(violations).toEqual([])
      })
    }
  })

  describe('business-rules.ts is pure (no IO, no clock, synchronous)', () => {
    for (const file of glob('server/domain/*/business-rules.ts')) {
      test(basename(dirname(file)), () => {
        const violations: string[] = []
        linesOf(file).forEach((line, i) => {
          if (/\basync\b/.test(line))
            violations.push(`${file}:${i + 1}: async (must be synchronous)`)
          if (/\bdb\(\)|useStorage/.test(line)) violations.push(`${file}:${i + 1}: touches storage`)
        })
        expect(violations).toEqual([])
      })
    }
  })

  describe('use-case.ts goes through commands and queries, never a repository', () => {
    for (const file of glob('server/domain/*/use-case.ts')) {
      test(basename(dirname(file)), () => {
        const violations: string[] = []
        linesOf(file).forEach((line, i) => {
          const match = line.match(/from\s+['"][^'"]*infrastructure\/repository['"]/)
          if (match) violations.push(`${file}:${i + 1}: imports a repository`)
        })
        expect(violations).toEqual([])
      })
    }
  })

  describe('no throw in domain query.ts and command.ts — absence and errors are sentinels', () => {
    for (const file of glob('server/domain/*/{query,command}.ts')) {
      test(`${basename(dirname(file))}/${basename(file)}`, () => {
        const violations: string[] = []
        linesOf(file).forEach((line, i) => {
          if (/throw\s+new\s+Error/.test(line)) violations.push(`${file}:${i + 1}: ${line.trim()}`)
        })
        expect(violations).toEqual([])
      })
    }
  })

  // Absence in the domain is a missing field, never null. Null survives only at
  // the GraphQL and Firestore boundaries, so the domain models are the check.
  test('no null in the domain models', () => {
    const violations: string[] = []
    for (const file of glob('server/domain/*/types.ts')) {
      linesOf(file).forEach((line, i) => {
        if (/\bnull\b/.test(line)) violations.push(`${file}:${i + 1}: ${line.trim()}`)
      })
    }
    expect(violations).toEqual([])
  })
})
