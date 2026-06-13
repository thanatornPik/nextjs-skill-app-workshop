---
name: project-onboarding
description: Use this skill when a developer asks how to set up, run, or understand this Next.js project. Use for onboarding questions such as "โปรเจกต์นี้ตั้งค่าอย่างไร", "เริ่มรันยังไง", "ใช้ stack อะไร", or Docker/Prisma setup questions from someone new to the codebase.
compatibility: Node.js 22+, npm, Git, MariaDB
license: MIT
metadata:
  author: Akenarin Komkoon
  version: "1.0.0"
---

# Project Onboarding Skill

ช่วย developer ใหม่เข้าใจ project นี้จาก clone ไปจนรัน local ได้ โดยต้องอ้างอิงจากไฟล์จริงใน repo ก่อนตอบ

## Mandatory rules

- ห้ามเดา script ที่ไม่มีใน `package.json`
- ห้ามใช้คำสั่ง database destructive ระหว่าง onboarding เช่น `prisma db push`, `migrate deploy`, `migrate dev`
- ถ้าพูดถึง Docker ต้องตรวจทั้ง `Dockerfile` และ `next.config.ts`

## Setup Step

ก่อนที่จะ setup ให้อ่านไฟล์นี้ เพื่อสร้างฐานข้อมูล ตาราง และข้อมูลเริ่มต้นเสมอ `references/database-setup.md`

เสร็จแล้วให้ตรวจความถูกต้องของโปรเจกต์ด้วยคำสั่งนี้:

```bash
npm run lint
npm run dev
```

## Project gotchas

อ่านรายละเอียดเพิ่มที่ `references/project-notes.md`

- Next.js App Router + TypeScript
- Prisma ใช้ custom output ไปที่ `generated/prisma`
- Prisma Client import จาก generated path ไม่ใช่ `@prisma/client`
- Dockerfile อาจใช้ `.next/standalone`; ต้องมี `output: "standalone"` ใน `next.config.ts`
- UI หลักเป็นภาษาไทย

## Output format

ถ้าถามเกี่ยวกับ setup หรือตั้งค่าโปรเจกต์ ให้ใช้ template ใน `assets/templates/setup-table.md` เท่านั้น

ต้องมีอย่างน้อย:
- ภาพรวมสั้น ๆ
- ตารางขั้นตอน setup
- คำสั่งที่ต้องรัน
- ข้อควรระวังของ repo นี้
