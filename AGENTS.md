<!-- BEGIN:nextjs-agent-rules -->
# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->

# Project notes

## Stack (verify before assuming defaults)

- Next.js 16.2.6 (App Router), React 19.2.4, TypeScript 5, Tailwind v4
- Prisma 7.8 with **driver adapter** (`@prisma/adapter-mariadb`), MySQL
- better-auth 1.6 with Prisma adapter
- shadcn (style `radix-luma`, baseColor `mist`, iconLibrary `remixicon`)
- zustand 5 for client cart state (persisted to `localStorage`)

## Scripts

- `npm run dev` / `build` / `start` / `lint` — only these are defined
- No `test` or `typecheck` script. Don't invent one; ask before adding

## Path alias

`@/*` → `./src/*` (set in `tsconfig.json` and mirrored in `components.json`)

## Prisma 7 quirks (non-default, easy to miss)

- Custom generator output: `prisma/schema.prisma` writes to `../generated/prisma` (not `node_modules/.prisma/client`)
- Client import must use the custom path: `import { PrismaClient } from "../../generated/prisma/client"` (see `src/lib/prisma.ts`)
- The client is instantiated via a **driver adapter**, not the default engine: `new PrismaClient({ adapter: new PrismaMariaDb(process.env.DATABASE_URL!) })`
- `prisma.config.ts` loads env via `import "dotenv/config"` — required for `npx prisma` commands
- `generated/prisma` is gitignored. Run `npx prisma generate` after `npm install` and after any schema change
- Better-auth tables map to **lowercase** DB names via `@@map`: `user`, `session`, `account`, `verification` — don't rename or Prisma + better-auth will desync

## Next.js 16 conventions in use here

- `cacheComponents: true` is set in `next.config.ts` — server components are dynamic by default; caching must be opted in
- Dynamic route signal: server components that need fresh data use
  `import { connection } from "next/server"; await connection();`
  (see `src/app/(front)/product/page.tsx`)
- Prisma `Decimal` columns are not serializable to client components — convert to `number` on the server before passing down
- Catch-all auth handler: `src/app/api/auth/[...all]/route.ts` re-exports `toNextJsHandler(auth)` from `better-auth/next-js`

## UI / components

- shadcn primitives live in `src/components/ui/`. Add new ones via the `shadcn` CLI, not by hand
- Use `cn(...)` from `@/lib/utils` for className merging (clsx + tailwind-merge)
- Feature components: `src/components/*.tsx` (shared), `src/app/(front)/components/*.tsx` (front-route-only)
- Default language is Thai (`<html lang="th">`); UI strings and metadata are Thai
- Form pattern: `react-hook-form` via `Controller` + `zod` resolver, using shadcn's `Field`/`FieldGroup`/`FieldLabel`/`FieldError` components (see `src/app/(auth)/login/page.tsx`)
- Two icon libraries: `@remixicon/react` (shadcn default per `components.json`) and `lucide-react` (used in navbar) — prefer remixicon for shadcn-generated code
- `@tailwindcss/postcss` plugin (Tailwind v4), not the classic `tailwindcss` PostCSS plugin

## State

- Cart store: `useCartStore` from `src/lib/cart-store.ts`, persisted under localStorage key `skill-cart`
- Auth state on the server: `await auth.api.getSession({ headers: await headers() })` — see `src/components/navbar.tsx`

## Docker gotcha

`Dockerfile` copies `.next/standalone` and `.next/static`, but `next.config.ts` does **not** set `output: "standalone"`. The container build will fail or skip standalone output until that is added. If you touch one, touch the other.

## Secrets

- `.env.example` is checked in and contains a real-looking `DATABASE_URL` password. Treat that value as compromised — do not reuse it anywhere
- Required env vars: `DATABASE_URL`, `BETTER_AUTH_SECRET`, `BETTER_AUTH_URL` (see `.env.example`)
