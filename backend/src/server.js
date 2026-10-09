require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const authRoutes = require('./routes/auth');
const marjaRoutes = require('./routes/marjas');
const faqRoutes = require('./routes/faqs');
const paymentRoutes = require('./routes/payments');

const app = express();

// ── امنیت پایه ──
app.use(helmet());
app.use(
  cors({
    origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : '*',
    credentials: true,
  }),
);
app.use(express.json({ limit: '256kb' }));

// ── محدودسازی نرخ درخواست ──
app.use(
  '/v1/auth',
  rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 30,
    standardHeaders: true,
    legacyHeaders: false,
  }),
);

// ── سلامت سرویس ──
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'khumsyar-backend', time: new Date() });
});

// ── مسیرهای API ──
app.use('/v1/auth', authRoutes);
app.use('/v1/marjas', marjaRoutes);
app.use('/v1/faqs', faqRoutes);
app.use('/v1/payments', paymentRoutes);

// ── 404 ──
app.use((req, res) => {
  res.status(404).json({ error: 'not_found', path: req.path });
});

// ── مدیریت خطا ──
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error('[error]', err.message);
  res.status(500).json({
    error: 'internal_error',
    message: process.env.NODE_ENV === 'production' ? undefined : err.message,
  });
});

const port = Number(process.env.PORT || 3000);
if (require.main === module) {
  app.listen(port, () => {
    console.log(`✅ خمس‌یار backend running on http://localhost:${port}`);
  });
}

module.exports = app;
