const express = require('express');
const { z } = require('zod');
const db = require('../db');
const { signToken } = require('../middleware/auth');
const { generateOtp, hashOtp, sendOtp } = require('../services/sms');

const router = express.Router();

const phoneSchema = z.string().regex(/^09\d{9}$/, 'invalid_phone');
const requestSchema = z.object({ phone: phoneSchema });
const verifySchema = z.object({
  phone: phoneSchema,
  code: z.string().regex(/^\d{4,6}$/, 'invalid_code'),
});

/** نرمال‌سازی شماره موبایل ایرانی (تبدیل ۰۹... و +۹۸...) */
function normalizePhone(phone) {
  let p = String(phone).replace(/[^\d+]/g, '');
  if (p.startsWith('+98')) p = '0' + p.slice(3);
  if (p.startsWith('98') && p.length === 12) p = '0' + p.slice(2);
  if (p.startsWith('9') && p.length === 10) p = '0' + p;
  return p;
}

/**
 * POST /v1/auth/otp/request
 * درخواست کد یک‌بارمصرف پیامکی
 */
router.post('/otp/request', async (req, res, next) => {
  try {
    const parsed = requestSchema.safeParse({
      phone: normalizePhone(req.body.phone),
    });
    if (!parsed.success) {
      return res.status(400).json({ error: 'invalid_phone' });
    }
    const { phone } = parsed.data;

    // محدودسازی: حداکثر یک کد فعال در دقیقه
    const recent = await db('otp_codes')
      .where({ phone })
      .andWhere('created_at', '>', db.raw("now() - interval '60 seconds'"))
      .first();
    if (recent) {
      return res.status(429).json({ error: 'too_many_requests' });
    }

    const code = generateOtp(Number(process.env.OTP_LENGTH || 5));
    const ttl = Number(process.env.OTP_TTL_SECONDS || 120);

    await db('otp_codes').insert({
      phone,
      code_hash: hashOtp(code),
      expires_at: db.raw(`now() + interval '${ttl} seconds'`),
    });

    await sendOtp(phone, code);

    return res.json({ ok: true, expiresIn: ttl });
  } catch (err) {
    return next(err);
  }
});

/**
 * POST /v1/auth/otp/verify
 * بررسی کد و صدور توکن
 */
router.post('/otp/verify', async (req, res, next) => {
  try {
    const parsed = verifySchema.safeParse({
      phone: normalizePhone(req.body.phone),
      code: String(req.body.code),
    });
    if (!parsed.success) {
      return res.status(400).json({ error: 'invalid_input' });
    }
    const { phone, code } = parsed.data;

    const record = await db('otp_codes')
      .where({ phone, consumed: false })
      .andWhere('expires_at', '>', db.fn.now())
      .orderBy('created_at', 'desc')
      .first();

    if (!record) {
      return res.status(400).json({ error: 'code_expired' });
    }

    if (record.attempts >= 5) {
      return res.status(429).json({ error: 'too_many_attempts' });
    }

    if (record.code_hash !== hashOtp(code)) {
      await db('otp_codes').where({ id: record.id }).increment('attempts', 1);
      return res.status(400).json({ error: 'wrong_code' });
    }

    await db('otp_codes').where({ id: record.id }).update({ consumed: true });

    // ساخت یا یافتن کاربر
    let user = await db('users').where({ phone }).first();
    if (!user) {
      const inserted = await db('users')
        .insert({ phone, phone_verified: true })
        .returning('*');
      user = Array.isArray(inserted) ? inserted[0] : inserted;
    } else if (!user.phone_verified) {
      await db('users').where({ id: user.id }).update({ phone_verified: true });
    }

    const token = signToken(user);
    return res.json({ token, user: { id: user.id, phone: user.phone } });
  } catch (err) {
    return next(err);
  }
});

module.exports = router;
