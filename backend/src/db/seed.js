/** اجرای seed داده‌های اولیه (مراجع، FAQ) */
const knex = require('knex');
const config = require('./knexfile');

const env = process.env.NODE_ENV === 'production' ? 'production' : 'development';
const db = knex(config[env]);

(async () => {
  try {
    console.log('⏳ در حال درج داده‌های اولیه...');
    const [files] = await db.seed.run();
    console.log('✅ داده‌ها درج شد:', files);
  } catch (err) {
    console.error('❌ خطا در seed:', err.message);
    process.exitCode = 1;
  } finally {
    await db.destroy();
  }
})();
