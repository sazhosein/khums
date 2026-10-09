/** اجرای مهاجرت‌ها */
const knex = require('knex');
const config = require('./knexfile');

const env = process.env.NODE_ENV === 'production' ? 'production' : 'development';
const db = knex(config[env]);

(async () => {
  try {
    console.log('⏳ در حال اجرای مهاجرت‌ها...');
    const [batch, files] = await db.migrate.latest();
    console.log(`✅ مهاجرت‌ها انجام شد (batch ${batch}):`, files);
  } catch (err) {
    console.error('❌ خطا در مهاجرت:', err.message);
    process.exitCode = 1;
  } finally {
    await db.destroy();
  }
})();
