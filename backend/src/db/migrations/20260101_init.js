/**
 * مهاجرت اولیه — ساخت جداول پایه
 */

exports.up = async function up(knex) {
  // کاربران (احراز هویت OTP پیامکی)
  await knex.schema.createTable('users', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.string('phone', 20).notNullable().unique();
    t.boolean('phone_verified').notNullable().defaultTo(false);
    t.string('marja_id', 64).nullable();
    t.string('locale', 8).notNullable().defaultTo('fa');
    t.boolean('dark_mode').notNullable().defaultTo(false);
    t.timestamp('khums_year_start').nullable();
    t.timestamps(true, true);
  });

  // کدهای یک‌بارمصرف
  await knex.schema.createTable('otp_codes', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.string('phone', 20).notNullable().index();
    t.string('code_hash', 128).notNullable();
    t.integer('attempts').notNullable().defaultTo(0);
    t.timestamp('expires_at').notNullable();
    t.boolean('consumed').notNullable().defaultTo(false);
    t.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
  });

  // مراجع و قواعد فقهی (نسخه‌بندی‌شده، قابل به‌روزرسانی از سرور)
  await knex.schema.createTable('marjas', (t) => {
    t.string('id', 64).primary();
    t.string('name').notNullable();
    t.string('name_ar').nullable();
    t.string('name_en').nullable();
    t.string('website_url').nullable();
    t.string('office_phone', 32).nullable();
    t.jsonb('offices').notNullable().defaultTo('[]');
    t.jsonb('rules').notNullable().defaultTo('{}');
    t.integer('rules_version').notNullable().defaultTo(1);
    t.boolean('verified_by_office').notNullable().defaultTo(false);
    t.timestamp('approved_at').nullable();
    t.timestamps(true, true);
  });

  // سوابق محاسبه (اختیاری — فقط اگر کاربر بخواهد همگام کند)
  await knex.schema.createTable('calculations', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
    t.string('marja_id', 64).notNullable();
    t.jsonb('input').notNullable();
    t.jsonb('result').notNullable();
    t.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
  });

  // پرداخت‌ها
  await knex.schema.createTable('payments', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('user_id').references('id').inTable('users').onDelete('SET NULL');
    t.string('gateway', 32).notNullable();
    t.string('authority', 128).nullable().index();
    t.bigInteger('amount_rial').notNullable();
    t.string('type', 16).notNullable(); // imam | sayyid | full
    t.string('status', 16).notNullable().defaultTo('pending');
    t.string('ref_id', 64).nullable();
    t.string('description').nullable();
    t.timestamp('paid_at').nullable();
    t.timestamps(true, true);
  });

  // سوالات متداول (بر اساس مرجع)
  await knex.schema.createTable('faqs', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.string('marja_id', 64).nullable().index();
    t.string('locale', 8).notNullable().defaultTo('fa');
    t.text('question').notNullable();
    t.text('answer').notNullable();
    t.integer('sort_order').notNullable().defaultTo(0);
    t.timestamps(true, true);
  });

  // ثبت کمک‌های خیریه از سهم امام (با اجازه)
  await knex.schema.createTable('charity_records', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('user_id').references('id').inTable('users').onDelete('SET NULL');
    t.bigInteger('amount_rial').notNullable();
    t.string('permission_ref').nullable(); // ارجاع به اجازه مرجع
    t.string('beneficiary').notNullable();
    t.text('note').nullable();
    t.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
  });
};

exports.down = async function down(knex) {
  await knex.schema.dropTableIfExists('charity_records');
  await knex.schema.dropTableIfExists('faqs');
  await knex.schema.dropTableIfExists('payments');
  await knex.schema.dropTableIfExists('calculations');
  await knex.schema.dropTableIfExists('marjas');
  await knex.schema.dropTableIfExists('otp_codes');
  await knex.schema.dropTableIfExists('users');
};
