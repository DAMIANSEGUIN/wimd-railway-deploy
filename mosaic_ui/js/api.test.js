// api.test.js - Unit tests for api.js module
import { describe, test, expect, beforeEach, jest } from '@jest/globals';

import { API_BASE, initApi } from './api.js';

describe('api.js', () => {
  beforeEach(() => {
    fetch.mockClear();
  });

  describe('API_BASE', () => {
    test('API_BASE is defined as /wimd', () => {
      expect(API_BASE).toBe('/wimd');
    });
  });

  describe('initApi', () => {
    test('initApi does not throw', () => {
      // Mock fetch for config
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ apiBase: '/wimd' })
      });
      expect(() => initApi()).not.toThrow();
    });
  });
});
