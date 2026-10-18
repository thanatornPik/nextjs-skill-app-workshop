// src/lib/auth-error.ts
// แปลง error code จาก better-auth เป็นข้อความภาษาไทยสำหรับผู้ใช้

const AUTH_ERROR_MESSAGES: Record<string, string> = {
  INVALID_EMAIL_OR_PASSWORD: "อีเมลหรือรหัสผ่านไม่ถูกต้อง",
  INVALID_PASSWORD: "รหัสผ่านไม่ถูกต้อง",
  USER_ALREADY_EXISTS: "อีเมลนี้ถูกลงทะเบียนแล้ว",
  EMAIL_NOT_VERIFIED: "กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ",
  TOO_MANY_REQUESTS: "พยายามมากเกินไป กรุณารอสักครู่แล้วลองใหม่",
};

export function getAuthErrorMessage(code?: string): string {
  if (code && AUTH_ERROR_MESSAGES[code]) {
    return AUTH_ERROR_MESSAGES[code];
  }
  return "เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง";
}
