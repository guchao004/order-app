# 📋 แอปรับออเดอร์อาหาร/เบรค

แอป Flutter สำหรับรับออเดอร์และสร้างข้อความสรุปส่งลูกค้าผ่าน LINE

---

## ✨ ฟีเจอร์หลัก
- กรอกข้อมูลลูกค้า: ชื่อ, เบอร์โทร, วัน/เวลา, สถานที่
- เพิ่มเมนูได้ไม่จำกัด พิมพ์ชื่อเองอิสระ
- คำนวณยอดรวมอัตโนมัติ
- คัดลอกข้อความพร้อมส่ง LINE ได้ทันที
- **กำหนดฟอร์แมตข้อความเองได้** ผ่านหน้า Settings

---

## 🚀 วิธีติดตั้งและ Build APK

### ขั้นตอนที่ 1: ติดตั้ง Flutter
1. ดาวน์โหลด Flutter SDK: https://flutter.dev/docs/get-started/install
2. เพิ่ม `flutter/bin` ใน PATH
3. ตรวจสอบ: `flutter doctor`

### ขั้นตอนที่ 2: ติดตั้ง Android Studio
1. ดาวน์โหลด: https://developer.android.com/studio
2. ติดตั้ง Android SDK (API 33+)
3. ยอมรับ license: `flutter doctor --android-licenses`

### ขั้นตอนที่ 3: Build APK
```bash
# เข้าโฟลเดอร์โปรเจกต์
cd flutter_order_app

# ติดตั้ง dependencies
flutter pub get

# Build APK (debug - ใช้ทดสอบได้เลย)
flutter build apk --debug

# Build APK (release - เร็วกว่า ขนาดเล็กกว่า)
flutter build apk --release

# ไฟล์ APK จะอยู่ที่:
# build/app/outputs/flutter-apk/app-debug.apk
# build/app/outputs/flutter-apk/app-release.apk
```

### ขั้นตอนที่ 4: ติดตั้งบนมือถือ Android
1. เปิด "นักพัฒนา" และ "USB Debugging" บนมือถือ
2. เสียบสาย USB
3. รัน: `flutter install`

หรือโอนไฟล์ `.apk` ไปไว้บนมือถือแล้วแตะติดตั้งตรงๆ ก็ได้

---

## 📝 วิธีใช้ตัวแปรใน Template ข้อความ

| ตัวแปร | ความหมาย |
|--------|----------|
| `{ชื่อลูกค้า}` | ชื่อลูกค้าที่กรอก |
| `{เบอร์โทร}` | เบอร์โทรศัพท์ |
| `{วันเวลา}` | วัน/เวลาส่ง |
| `{สถานที่}` | สถานที่ส่ง |
| `{รายการ}` | รายการเมนูทั้งหมดพร้อมราคา |
| `{ยอดรวม}` | ยอดรวมอาหาร |
| `{ค่าส่ง}` | ค่าส่ง |
| `{ยอดทั้งหมด}` | ยอดรวมทั้งหมด |
| `{หมายเหตุ}` | หมายเหตุ |

### ตัวอย่าง Template แบบสั้น:
```
ออเดอร์: {ชื่อลูกค้า} ({เบอร์โทร})
ส่ง: {วันเวลา} - {สถานที่}
{รายการ}
รวม: {ยอดทั้งหมด} บาท
```

---

## 📁 โครงสร้างโค้ด
```
lib/
├── main.dart                  # Entry point
├── models/
│   └── order_item.dart        # Model รายการเมนู
├── screens/
│   ├── order_screen.dart      # หน้าหลัก
│   └── format_screen.dart     # หน้าตั้งค่า template
└── widgets/
    ├── order_item_card.dart   # การ์ดเมนูแต่ละรายการ
    └── summary_card.dart      # การ์ดสรุปยอด
```
