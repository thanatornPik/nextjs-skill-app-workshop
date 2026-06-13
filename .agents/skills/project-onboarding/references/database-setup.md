# Database Setup

สร้างฐานข้อมูลใหม่ ชื่อว่า ecommerce หรือใช้ฐานข้อมูลเดิมในไฟล์ .env.example ถ้ามีอยู่แล้ว และเพิ่มข้อมูลตัวอย่างไปที่ตาราง (ใช้เฉพาะการตั้งค่าครั้งแรกเท่านั้้น)

## Setup Step

```bash
npm install
cp .env.example .env.development
npx prisma db push
npx prisma generate
```

ถ้าผ่านแล้วให้รันคำสั่ง sql นี้ เพื่อเพิ่มข้อมูลเริ่มต้น `assets/insert_data_example.sql`