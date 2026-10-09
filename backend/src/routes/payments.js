const express = require('express');
const { z } = require('zod');
const db = require('../db');
const { requireAuth } = require('../middleware/auth');
const { getGateway } = require('../services/gateways');

const router = express.Router();

const requestSchema = z.object({
  amount: z.number().int().positive(), // ریال
  gateway: z.enum(['zarinpal', 'idpay', 'saman']),
  type: z.enum(['imam', 'sayyid', 'full']).default('full'),
  description: z.string().max(255).optional(),
  callbackUrl: z.string().url().optional(),
});

/**
 * POST /v1/payments/request
 * ایجاد درخواست پرداخت و دریافت لینک درگاه
 */
router.post('/request', requireAuth, async (req, res, next) => {
  try {
    const parsed = requestSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({ error: 'invalid_input' });
    }
    const { amount, gateway, type, description, callbackUrl } = parsed.data;

    const callback =
      callbackUrl || process.env.PAYMENT_CALLBACK_URL;

    const gw = getGateway(gateway);
    const { authority, paymentUrl } = await gw.request({
      amountRial: amount,
      description: description || 'پرداخت خمس',
      callbackUrl: callback,
    });

    await db('payments').insert({
      user_id: req.user.sub,
      gateway,
      authority,
      amount_rial: amount,
      type,
      status: 'pending',
      description: description || 'پرداخت خمس',
    });

    return res.json({ authority, paymentUrl });
  } catch (err) {
    return next(err);
  }
});

/**
 * POST /v1/payments/verify
 * تأیید پرداخت پس از بازگشت از درگاه
 */
router.post('/verify', requireAuth, async (req, res, next) => {
  try {
    const schema = z.object({
      authority: z.string().min(1),
      amount: z.number().int().positive(),
    });
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({ error: 'invalid_input' });
    }
    const { authority, amount } = parsed.data;

    const payment = await db('payments').where({ authority }).first();
    if (!payment) return res.status(404).json({ error: 'not_found' });
    if (payment.status === 'success') {
      return res.json({ verified: true, refId: payment.ref_id });
    }

    const gw = getGateway(payment.gateway);
    const { verified, refId } = await gw.verify({
      authority,
      amountRial: amount,
    });

    await db('payments')
      .where({ id: payment.id })
      .update({
        status: verified ? 'success' : 'failed',
        ref_id: refId,
        paid_at: verified ? db.fn.now() : null,
      });

    return res.json({ verified, refId });
  } catch (err) {
    return next(err);
  }
});

/**
 * GET /v1/payments/callback
 * بازگشت از درگاه (برای درگاه‌هایی که با query برمی‌گردند)
 */
router.get('/callback', async (req, res, next) => {
  try {
    const { Authority, Status } = req.query;
    if (!Authority) return res.status(400).send('missing_authority');

    const payment = await db('payments').where({ authority: Authority }).first();
    if (!payment) return res.status(404).send('not_found');

    if (Status && Status !== 'OK') {
      await db('payments').where({ id: payment.id }).update({ status: 'failed' });
      return res.redirect('khumsyar://payment/failed');
    }

    const gw = getGateway(payment.gateway);
    const { verified, refId } = await gw.verify({
      authority: Authority,
      amountRial: payment.amount_rial,
    });

    await db('payments')
      .where({ id: payment.id })
      .update({
        status: verified ? 'success' : 'failed',
        ref_id: refId,
        paid_at: verified ? db.fn.now() : null,
      });

    return res.redirect(
      verified ? 'khumsyar://payment/success' : 'khumsyar://payment/failed',
    );
  } catch (err) {
    return next(err);
  }
});

/**
 * GET /v1/payments
 * تاریخچه پرداخت‌های کاربر
 */
router.get('/', requireAuth, async (req, res, next) => {
  try {
    const rows = await db('payments')
      .where({ user_id: req.user.sub })
      .orderBy('created_at', 'desc')
      .limit(100);

    return res.json({
      data: rows.map((p) => ({
        id: p.id,
        gateway: p.gateway,
        authority: p.authority,
        amount: p.amount_rial,
        type: p.type,
        status: p.status,
        refId: p.ref_id,
        date: p.created_at,
      })),
    });
  } catch (err) {
    return next(err);
  }
});

module.exports = router;
