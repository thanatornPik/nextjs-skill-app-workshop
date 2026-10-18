---
name : weather-api
description : A skill that provides weather forecasts for a given location.
---
## Setup 
Run this API for weather forecasts

curl https://api.weatherapi.com/v1/current.json?key=REDACTED&q=<LOCATION>&aqi=no 
 
## Output
 Displays the current weather information for the specified location, including temperature, humidity, wind speed, and weather conditions is table format. The output will also include the location name and the time of the forecast and the output will be in Thai language.

Example Output:
 | รายการ | ค่า/รายละเอียด |
| --- | --- |
| 📅 วันที่/เวลา | 18 ต.ค. 2026 เวลา 16:45 น. |
| 🌤 สภาพอากาศ | แดดจ้า ท้องฟ้าโปร่ง (เมฆ 5%) |
| 🌡 อุณหภูมิ | 31.3°C (รู้สึกเหมือน 34.9°C) |
| 💧 ความชื้น | 58% |
| 🌬 ลม | SW 5.8 กม./ชม. |
| ☔ ปริมาณฝน | 0 มม. (โอกาสฝนตก 3%) |
| 👀 ทัศนวิสัย | 10 กม. |
| 🔆 ดัชนี UV | 2.2 (ต่ำ) |
| 📊 เปรียบเทียบ | ต่ำกว่ากรุงเทพฯ ~1.3°C |