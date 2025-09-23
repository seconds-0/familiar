import { LocalStorage } from "@raycast/api";
import type { SessionData } from "./types";

// Debounced session persistence to avoid excessive LocalStorage writes
let saveTimer: NodeJS.Timeout | null = null;

/**
 * Save session data with debouncing to prevent excessive disk writes
 * during streaming updates. Default delay is 300ms.
 */
export function saveSessionDebounced(key: string, data: SessionData, delay = 300): void {
  if (saveTimer) {
    clearTimeout(saveTimer);
  }

  saveTimer = setTimeout(() => {
    void LocalStorage.setItem(key, JSON.stringify(data)).catch((error) => {
      console.error("Failed to save session:", error);
    });
    saveTimer = null;
  }, delay);
}

/**
 * Immediately save session data without debouncing
 * Use this for final saves or critical updates
 */
export function saveSessionImmediate(key: string, data: SessionData): Promise<void> {
  // Cancel any pending debounced saves
  if (saveTimer) {
    clearTimeout(saveTimer);
    saveTimer = null;
  }

  return LocalStorage.setItem(key, JSON.stringify(data));
}

/**
 * Load session data from LocalStorage
 */
export async function loadSession(key: string): Promise<SessionData | null> {
  try {
    const stored = await LocalStorage.getItem<string>(key);
    if (stored) {
      return JSON.parse(stored) as SessionData;
    }
  } catch (error) {
    console.error("Failed to load session:", error);
  }
  return null;
}

/**
 * Clear session data from LocalStorage
 */
export async function clearSession(key: string): Promise<void> {
  // Cancel any pending saves
  if (saveTimer) {
    clearTimeout(saveTimer);
    saveTimer = null;
  }

  await LocalStorage.removeItem(key);
}

/**
 * Get session key for current working directory
 */
export function getSessionKey(workingDirectory: string): string {
  // Create a safe key from the working directory path
  const safePath = workingDirectory.replace(/[^a-zA-Z0-9]/g, "_");
  return `session_${safePath}`;
}
