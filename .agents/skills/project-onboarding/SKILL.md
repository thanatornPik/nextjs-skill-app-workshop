---
name: project-onboarding
description: Help a developer get set up and oriented in this Next.js 16 App Router + TypeScript Project. Use when someone is new to the repo, asks how to set up the project or "โปรเจกต์นี้ตั้งค่าอย่างไร" or "โปรเจกต์นี้ทำงานอย่างไร"
license: Proprietary
compatibility: Required Node.js 22+, npm, git and MariaDB
metadata:
  version: "1.0"
  author: thanatornPik
---

# Project Onboarding

Get a new Developer from clone to first running change. Confirm each step before next.

## Setup sequence

```bash
# 1. Install deps (this repo use npm)
npm install

# 2. Environment
cp .env.example .env.development

# 3. Generate the Prisma client
npx prisma generate

```

## First task check list

Hand this to a new developer on day one. Tick each box

- [ ] `npm run lint` pass