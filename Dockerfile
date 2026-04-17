# 1. ใช้ Node.js เป็นฐาน (เลือกเวอร์ชันที่เบาและปลอดภัย)
FROM node:20-alpine

# 2. สร้างโฟลเดอร์สำหรับทำงานใน Container
WORKDIR /app

# 3. ก๊อปปี้ไฟล์จัดการ Library เข้าไปก่อน (เพื่อทำ Cache)
COPY package*.json ./
COPY yarn.lock* ./

# 4. ติดตั้ง Dependencies
RUN npm install

# 5. ก๊อปปี้โค้ดทั้งหมดตามเข้าไป
COPY . .

# 6. ถ้าเป็น TypeScript ต้อง Build ก่อนรัน (ถ้าคุณเซ็ต build script ไว้)
# RUN npm run build

# 7. เปิด Port ตามที่แอปคุณใช้ (เช่น 4000)
EXPOSE 4000

# 8. สั่งรันแอป
CMD ["npm", "start"]