export default {
  testEnvironment: 'jsdom',
  testMatch: ['**/mosaic_ui/js/**/*.test.js'],
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  collectCoverageFrom: [
    'mosaic_ui/js/**/*.js',
    '!mosaic_ui/js/**/*.test.js',
    '!mosaic_ui/js/**/__tests__/**'
  ],
  coverageThreshold: {
    global: {
      statements: 70,
      branches: 60,
      functions: 70,
      lines: 70
    }
  },
  moduleFileExtensions: ['js', 'json'],
  testTimeout: 10000,
  transform: {}
};
