// state.test.js - Unit tests for state.js module
import { describe, test, expect, beforeEach, jest } from '@jest/globals';

import {
  SESSION_KEY,
  USER_DATA_KEY,
  TRIAL_START_KEY,
  TRIAL_DURATION,
  safeLocalStorageGet,
  safeLocalStorageSet,
  setSession,
  getSessionId,
  registerSessionCallback,
  saveUserData,
  getUserData,
  setCurrentUser,
  getCurrentUser,
  isUserAuthenticated,
  startTrial,
  getTrialStartTime,
  checkTrialExpired,
  saveAutoSnapshot,
  loadAutoSnapshot,
  markDirty,
  markClean,
  isDirty,
  wasSavedThisSession,
  initState,
  __resetStateForTesting
} from './state.js';

describe('state.js', () => {
  beforeEach(() => {
    // Reset localStorage and module state before each test
    localStorage.clear();
    __resetStateForTesting();
  });

  describe('safeLocalStorageGet/Set', () => {
    test('safeLocalStorageGet returns default value when key does not exist', () => {
      expect(safeLocalStorageGet('nonexistent', 'default')).toBe('default');
    });

    test('safeLocalStorageGet returns stored value when key exists', () => {
      localStorage.setItem('testKey', 'testValue');
      expect(safeLocalStorageGet('testKey')).toBe('testValue');
    });

    test('safeLocalStorageSet stores value correctly', () => {
      safeLocalStorageSet('newKey', 'newValue');
      expect(localStorage.getItem('newKey')).toBe('newValue');
    });
  });

  describe('Session Management', () => {
    test('setSession stores session ID in localStorage', () => {
      setSession('test-session-123');
      expect(localStorage.getItem(SESSION_KEY)).toBe('test-session-123');
    });

    test('getSessionId returns current session ID', () => {
      setSession('my-session');
      expect(getSessionId()).toBe('my-session');
    });

    test('registerSessionCallback triggers on session change', () => {
      const callback = jest.fn();
      registerSessionCallback(callback);
      setSession('new-session');
      expect(callback).toHaveBeenCalledWith('new-session');
    });

    test('setSession does not set empty ID', () => {
      setSession('');
      expect(localStorage.getItem(SESSION_KEY)).toBeNull();
    });
  });

  describe('User Data Management', () => {
    test('saveUserData stores user data in localStorage', () => {
      saveUserData({ name: 'John', email: 'john@example.com' });
      const stored = JSON.parse(localStorage.getItem(USER_DATA_KEY));
      expect(stored.name).toBe('John');
      expect(stored.email).toBe('john@example.com');
    });

    test('saveUserData merges with existing data', () => {
      saveUserData({ name: 'John' });
      saveUserData({ email: 'john@example.com' });
      const data = getUserData();
      expect(data.name).toBe('John');
      expect(data.email).toBe('john@example.com');
    });

    test('getUserData returns stored user data', () => {
      saveUserData({ test: 'value' });
      expect(getUserData().test).toBe('value');
    });

    test('setCurrentUser and getCurrentUser work correctly', () => {
      const user = { id: '123', email: 'test@test.com' };
      setCurrentUser(user);
      expect(getCurrentUser()).toEqual(user);
    });

    test('isUserAuthenticated returns true when user is set', () => {
      expect(isUserAuthenticated()).toBe(false);
      setCurrentUser({ id: '123' });
      expect(isUserAuthenticated()).toBe(true);
    });

    test('isUserAuthenticated returns false when user is null', () => {
      setCurrentUser(null);
      expect(isUserAuthenticated()).toBe(false);
    });
  });

  describe('Trial Management', () => {
    test('startTrial sets trial start time', () => {
      const before = Date.now();
      startTrial();
      const after = Date.now();
      const trialStart = parseInt(getTrialStartTime(), 10);
      expect(trialStart).toBeGreaterThanOrEqual(before);
      expect(trialStart).toBeLessThanOrEqual(after);
    });

    test('startTrial stores in localStorage', () => {
      startTrial();
      expect(localStorage.getItem(TRIAL_START_KEY)).not.toBeNull();
    });

    test('checkTrialExpired returns false when trial just started', () => {
      startTrial();
      expect(checkTrialExpired()).toBe(false);
    });

    test('checkTrialExpired returns false when no trial exists', () => {
      expect(checkTrialExpired()).toBe(false);
    });

    test('TRIAL_DURATION is defined', () => {
      expect(TRIAL_DURATION).toBeDefined();
      expect(typeof TRIAL_DURATION).toBe('number');
    });
  });

  describe('Auto Snapshot', () => {
    beforeEach(() => {
      setSession('snapshot-test-session');
    });

    test('saveAutoSnapshot stores snapshot in localStorage', () => {
      saveAutoSnapshot({ step: 1, answers: ['test'] });
      const stored = JSON.parse(localStorage.getItem('auto_save'));
      expect(stored.step).toBe(1);
      expect(stored.answers).toEqual(['test']);
    });

    test('saveAutoSnapshot adds timestamp', () => {
      saveAutoSnapshot({ data: 'test' });
      const stored = JSON.parse(localStorage.getItem('auto_save'));
      expect(stored.timestamp).toBeDefined();
    });

    test('loadAutoSnapshot returns saved data for same session', () => {
      saveAutoSnapshot({ myData: 123 });
      const loaded = loadAutoSnapshot();
      expect(loaded.myData).toBe(123);
    });

    test('loadAutoSnapshot returns null for different session', () => {
      saveAutoSnapshot({ myData: 123 });
      setSession('different-session');
      const loaded = loadAutoSnapshot();
      expect(loaded).toBeNull();
    });

    test('saveAutoSnapshot ignores null input', () => {
      saveAutoSnapshot(null);
      expect(localStorage.getItem('auto_save')).toBeNull();
    });
  });

  describe('Dirty State Tracking', () => {
    test('markDirty sets dirty flag', () => {
      markDirty();
      expect(isDirty()).toBe(true);
    });

    test('markClean clears dirty flag', () => {
      markDirty();
      markClean();
      expect(isDirty()).toBe(false);
    });

    test('markClean sets savedThisSession flag', () => {
      markClean();
      expect(wasSavedThisSession()).toBe(true);
    });
  });

  describe('initState', () => {
    test('initState loads session from localStorage', () => {
      localStorage.setItem(SESSION_KEY, 'existing-session');
      initState();
      expect(getSessionId()).toBe('existing-session');
    });

    test('initState loads user data from localStorage', () => {
      localStorage.setItem(USER_DATA_KEY, JSON.stringify({ saved: true }));
      initState();
      expect(getUserData().saved).toBe(true);
    });

    test('initState handles malformed user data gracefully', () => {
      localStorage.setItem(USER_DATA_KEY, 'not valid json');
      expect(() => initState()).not.toThrow();
    });
  });
});
