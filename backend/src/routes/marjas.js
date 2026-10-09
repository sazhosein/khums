const express = require('express');
const db = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

/** تبدیل رکورد دیتابیس به شکل مورد انتظار کلاینت (camelCase) */
function toClient(row) {
  return {
    id: row.id,
    name: row.name,
    nameAr: row.name_ar,
    nameEn: row.name_en,
    websiteUrl: row.website_url,
    officePhone: row.office_phone,
    offices: row.offices || [],
    rules: row.rules || {},
    rulesVersion: row.rules_version,
    verifiedByOffice: row.verified_by_office,
  };
}

/**
 * GET /v1/marjas
 * لیست مراجع و قواعد فقهی (برای به‌روزرسانی قواعد در اپ)
 */
router.get('/', async (req, res, next) => {
  try {
    const rows = await db('marjas').orderBy('name', 'asc');
    return res.json({ data: rows.map(toClient) });
  } catch (err) {
    return next(err);
  }
});

/**
 * GET /v1/marjas/:id
 * جزئیات یک مرجع
 */
router.get('/:id', async (req, res, next) => {
  try {
    const row = await db('marjas').where({ id: req.params.id }).first();
    if (!row) return res.status(404).json({ error: 'not_found' });
    return res.json({ data: toClient(row) });
  } catch (err) {
    return next(err);
  }
});

/**
 * GET /v1/marjas/version
 * آخرین نسخه قواعد — برای بررسی نیاز به به‌روزرسانی در اپ
 */
router.get('/meta/version', async (req, res, next) => {
  try {
    const row = await db('marjas').max('rules_version as version').first();
    return res.json({ version: row?.version || 0 });
  } catch (err) {
    return next(err);
  }
});

module.exports = router;
