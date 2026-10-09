const express = require('express');
const db = require('../db');

const router = express.Router();

/**
 * GET /v1/faqs?marjaId=&locale=fa
 * سوالات متداول — عمومی + مخصوص مرجع
 */
router.get('/', async (req, res, next) => {
  try {
    const { marjaId, locale = 'fa' } = req.query;

    const query = db('faqs').where({ locale }).where(function () {
      this.whereNull('marja_id');
      if (marjaId) this.orWhere({ marja_id: marjaId });
    });

    const rows = await query.orderBy('sort_order', 'asc');

    return res.json({
      data: rows.map((r) => ({
        id: r.id,
        marjaId: r.marja_id,
        question: r.question,
        answer: r.answer,
      })),
    });
  } catch (err) {
    return next(err);
  }
});

module.exports = router;
