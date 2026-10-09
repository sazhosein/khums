const knex = require('knex');
const config = require('./knexfile');

const env = process.env.NODE_ENV === 'production' ? 'production' : 'development';

/** نمونه اتصال مشترک پایگاه داده */
const db = knex(config[env]);

module.exports = db;
