require('dotenv').config();

/** تنظیمات اتصال به PostgreSQL */
module.exports = {
  development: {
    client: 'pg',
    connection: process.env.DATABASE_URL,
    pool: { min: 2, max: 10 },
    migrations: { directory: __dirname + '/migrations' },
    seeds: { directory: __dirname + '/seeds' },
  },
  production: {
    client: 'pg',
    connection: {
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false },
    },
    pool: { min: 2, max: 20 },
    migrations: { directory: __dirname + '/migrations' },
    seeds: { directory: __dirname + '/seeds' },
  },
};
