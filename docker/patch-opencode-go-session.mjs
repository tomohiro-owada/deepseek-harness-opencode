import { readFile, writeFile } from 'node:fs/promises'

const target = '/usr/local/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-llm-pi-ai/lib/index.js'
const before = 'headers: requestHeaders(profile.headers)'
const after = `headers: requestHeaders({
          ...profile.headers,
          ...options.provider === 'opencode-go' && options.sessionId !== void 0
            ? { 'x-opencode-session': String(options.sessionId) }
            : {},
        })`

const source = await readFile(target, 'utf8')
const matches = source.split(before).length - 1
if (matches !== 1) throw new Error(`OpenCode Go session patch expected one target, found ${matches}`)
await writeFile(target, source.replace(before, after))
