module.exports = {
  testEnvironment: 'node',
  setupFiles: ['dotenv/config'],
  moduleNameMapper: {
    '^dotenv/config$': '<rootDir>/.env.test',
  },
  testMatch: ['**/tests/**/*.?(spec|test).[jt]s?(x)'],
};
