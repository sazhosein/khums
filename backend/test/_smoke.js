/**
 * اسموک‌تست بک‌اند — بدون نیاز به PostgreSQL
 * بررسی: بارگذاری سرور، مسیر /health، و منطق محاسبه خمس (پورت‌شده مطابق اپ)
 * اجرا: node test/_smoke.js
 */
process.env.DATABASE_URL =
  process.env.DATABASE_URL || 'postgres://x:x@localhost:5432/x';
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test_secret';

const assert = require('assert');
const app = require('../src/server');

let passed = 0;
let failed = 0;

function check(name, fn) {
  try {
    fn();
    console.log(`  ✅ ${name}`);
    passed++;
  } catch (e) {
    console.log(`  ❌ ${name}`);
    console.log(`     ${e.message}`);
    failed++;
  }
}

// ── موتور محاسبه خمس (پورت Dart → JS برای تست منطق) ──
function calculateKhums(rawInput, rules) {
  // مقداردهی پیش‌فرض صفر برای فیلدهای غایب (مثل رفتار اپ)
  const input = {
    food: 0, clothing: 0, housing: 0, medical: 0, education: 0,
    debts: 0, other: 0, trousseau: 0, inheritance: 0, dowry: 0,
    bloodMoney: 0, otherExempt: 0, emergencySavings: 0,
    futureNecessitiesSavings: 0, cashSavings: 0, gold: 0, coins: 0,
    currency: 0, stocks: 0, businessCapital: 0, capitalFromIncome: 0,
    ...rawInput,
  };
  const medical = rules.medicalExpensesDeductible ? input.medical : 0;
  const debts = rules.debtsDeductible ? input.debts : 0;
  let trousseau = 0;
  if (rules.trousseauExempt) trousseau = input.trousseau || 0;
  else if (rules.gradualTrousseauExempt && input.trousseau)
    trousseau = input.trousseau;

  const totalExpenses =
    input.food +
    input.clothing +
    input.housing +
    medical +
    input.education +
    debts +
    input.other +
    trousseau;

  let exemptAssets = input.otherExempt || 0;
  if (rules.inheritanceExempt) exemptAssets += input.inheritance || 0;
  if (rules.dowryExempt) exemptAssets += input.dowry || 0;
  if (rules.bloodMoneyExempt) exemptAssets += input.bloodMoney || 0;

  let savingsExempted = 0;
  if (rules.emergencySavingsExempt) savingsExempted += input.emergencySavings || 0;
  if (rules.futureNecessitiesSavingsExempt)
    savingsExempted += input.futureNecessitiesSavings || 0;

  const capital = rules.capitalBoughtFromUnkhumsedIncome
    ? input.capitalFromIncome || 0
    : 0;

  const assets =
    (input.cashSavings || 0) +
    (input.gold || 0) +
    (input.coins || 0) +
    (input.currency || 0) +
    (input.stocks || 0) +
    (input.businessCapital || 0) +
    capital;

  let surplus =
    input.totalIncome - totalExpenses + assets - savingsExempted - exemptAssets;
  if (surplus < 0) surplus = 0;

  const khumsAmount = surplus * rules.khumsRate;
  return {
    totalExpenses,
    exemptAssets,
    savingsExempted,
    surplus,
    khumsAmount,
    imamShare: khumsAmount * rules.imamShareRatio,
    sayyidShare: khumsAmount * rules.sayyidShareRatio,
  };
}

const RULES = {
  khamenei: {
    medicalExpensesDeductible: true,
    debtsDeductible: true,
    trousseauExempt: false,
    gradualTrousseauExempt: false,
    inheritanceExempt: true,
    dowryExempt: true,
    bloodMoneyExempt: true,
    emergencySavingsExempt: true,
    futureNecessitiesSavingsExempt: false,
    capitalBoughtFromUnkhumsedIncome: true,
    khumsRate: 0.2,
    imamShareRatio: 0.5,
    sayyidShareRatio: 0.5,
  },
  sistani: {
    medicalExpensesDeductible: true,
    debtsDeductible: true,
    trousseauExempt: false,
    gradualTrousseauExempt: false,
    inheritanceExempt: true,
    dowryExempt: true,
    bloodMoneyExempt: true,
    emergencySavingsExempt: false,
    futureNecessitiesSavingsExempt: false,
    capitalBoughtFromUnkhumsedIncome: true,
    khumsRate: 0.2,
    imamShareRatio: 0.5,
    sayyidShareRatio: 0.5,
  },
  makarem: {
    medicalExpensesDeductible: true,
    debtsDeductible: true,
    trousseauExempt: true,
    gradualTrousseauExempt: true,
    inheritanceExempt: true,
    dowryExempt: true,
    bloodMoneyExempt: true,
    emergencySavingsExempt: false,
    futureNecessitiesSavingsExempt: false,
    capitalBoughtFromUnkhumsedIncome: true,
    khumsRate: 0.2,
    imamShareRatio: 0.5,
    sayyidShareRatio: 0.5,
  },
};

const close = (a, b) => Math.abs(a - b) < 1;

(async () => {
  console.log('\n=== ۱) بارگذاری سرور Express ===');
  check('server module exports an app', () => {
    assert.strictEqual(typeof app, 'function');
  });

  console.log('\n=== ۲) تست زنده /health ===');
  const server = app.listen(0);
  await new Promise((r) => server.once('listening', r));
  const port = server.address().port;

  try {
    const res = await fetch(`http://localhost:${port}/health`);
    const body = await res.json();
    check('GET /health → 200', () => assert.strictEqual(res.status, 200));
    check('body.status === "ok"', () => assert.strictEqual(body.status, 'ok'));
    check('service name correct', () =>
      assert.strictEqual(body.service, 'khumsyar-backend'));
  } catch (e) {
    console.log('  ❌ live /health request failed:', e.message);
    failed++;
  }

  // مسیر ناشناخته باید 404 بدهد
  try {
    const res = await fetch(`http://localhost:${port}/nope`);
    check('unknown route → 404', () => assert.strictEqual(res.status, 404));
  } catch (e) {
    console.log('  ❌ 404 test failed:', e.message);
    failed++;
  }

  // مسیر محافظت‌شده بدون توکن → 401
  try {
    const res = await fetch(`http://localhost:${port}/v1/payments`);
    check('protected route w/o token → 401', () =>
      assert.strictEqual(res.status, 401));
  } catch (e) {
    console.log('  ❌ auth guard test failed:', e.message);
    failed++;
  }

  server.close();

  console.log('\n=== ۳) منطق محاسبه خمس ===');
  check('محاسبه پایه: مازاد=۵۰M، خمس=۱۰M', () => {
    const r = calculateKhums(
      {
        totalIncome: 100000000,
        food: 10000000,
        clothing: 5000000,
        housing: 20000000,
        medical: 3000000,
        education: 2000000,
        debts: 5000000,
        other: 5000000,
      },
      RULES.sistani,
    );
    assert.ok(close(r.surplus, 50000000), `surplus=${r.surplus}`);
    assert.ok(close(r.khumsAmount, 10000000), `khums=${r.khumsAmount}`);
    assert.ok(close(r.imamShare, 5000000), `imam=${r.imamShare}`);
    assert.ok(close(r.sayyidShare, 5000000), `sayyid=${r.sayyidShare}`);
  });

  check('پس‌انداز پیشامدها نزد خامنه‌ای معاف (مازاد=۴۰M)', () => {
    const r = calculateKhums(
      { totalIncome: 100000000, food: 50000000, emergencySavings: 10000000 },
      RULES.khamenei,
    );
    assert.ok(close(r.savingsExempted, 10000000));
    assert.ok(close(r.surplus, 40000000), `surplus=${r.surplus}`);
  });

  check('ارث نزد سیستانی معاف (مازاد=۳۰M)', () => {
    const r = calculateKhums(
      { totalIncome: 100000000, food: 50000000, inheritance: 20000000 },
      RULES.sistani,
    );
    assert.ok(close(r.exemptAssets, 20000000));
    assert.ok(close(r.surplus, 30000000), `surplus=${r.surplus}`);
  });

  check('جهیزیه نزد مکارم معاف (مازاد=۴۰M)', () => {
    const r = calculateKhums(
      { totalIncome: 100000000, food: 50000000, trousseau: 10000000 },
      RULES.makarem,
    );
    assert.ok(close(r.totalExpenses, 60000000), `expenses=${r.totalExpenses}`);
    assert.ok(close(r.surplus, 40000000), `surplus=${r.surplus}`);
  });

  check('مخارج بیش از درآمد → مازاد صفر', () => {
    const r = calculateKhums(
      { totalIncome: 10000000, food: 50000000 },
      RULES.sistani,
    );
    assert.strictEqual(r.surplus, 0);
    assert.strictEqual(r.khumsAmount, 0);
  });

  check('سود تجاری مشمول خمس است', () => {
    const r = calculateKhums(
      { totalIncome: 100000000, food: 50000000, capitalFromIncome: 10000000 },
      RULES.sistani,
    );
    assert.ok(close(r.surplus, 60000000), `surplus=${r.surplus}`);
  });

  console.log(`\n──────── نتیجه ────────`);
  console.log(`  موفق: ${passed}   ناموفق: ${failed}`);
  console.log(`────────────────────────\n`);
  process.exit(failed > 0 ? 1 : 0);
})();
