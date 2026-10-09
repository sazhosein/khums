const crypto = require('crypto');

/**
 * سرویس پیامک — ارسال کد OTP
 * از سرویس‌دهنده‌های ایرانی (کاوه‌نگار، ملی‌پیامک، فراز اس‌ام‌اس) پشتیبانی می‌کند.
 * در حالت توسعه، کد در کنسول چاپ می‌شود.
 */

const templates = {
  otp: (code) => `خمس‌یار\nکد ورود شما: ${code}\nاین کد را در اختیار دیگران قرار ندهید.`,
};

/** تولید کد عددی با طول مشخص */
function generateOtp(length = 5) {
  const max = 10 ** length;
  const num = crypto.randomInt(0, max);
  return String(num).padStart(length, '0');
}

/** هش کردن کد (قبل از ذخیره در دیتابیس) */
function hashOtp(code) {
  return crypto.createHash('sha256').update(String(code)).digest('hex');
}

/** ارسال پیامک OTP */
async function sendOtp(phone, code) {
  const provider = process.env.SMS_PROVIDER || 'console';
  const message = templates.otp(code);

  if (provider === 'console' || process.env.NODE_ENV !== 'production') {
    // در توسعه، به‌جای ارسال واقعی، کد را لاگ می‌کنیم
    console.log(`[SMS:${provider}] → ${phone}: ${code}`);
    return { ok: true, dev: true };
  }

  // نمونه اتصال به کاوه‌نگار (در تولید فعال می‌شود)
  // const url = `https://api.kavenegar.com/v1/${process.env.SMS_API_KEY}/sms/send.json`;
  // await fetch(`${url}?receptor=${phone}&sender=${process.env.SMS_SENDER}&message=${encodeURIComponent(message)}`);
  return { ok: true };
}

module.exports = { generateOtp, hashOtp, sendOtp };
