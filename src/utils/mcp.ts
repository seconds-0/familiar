import { showToast, Toast, environment, getSelectedFinderItems, LocalStorage } from "@raycast/api";
import type { McpServerConfig } from "./types";

/**
 * Resolve the working directory for MCP servers
 * Priority: 1) Selected Finder items 2) Stored preference 3) process.cwd()
 */
export async function resolveWorkingPath(): Promise<string> {
  try {
    // Check for selected Finder items
    const selected = await getSelectedFinderItems().catch(() => []);
    if (selected.length > 0) {
      const firstPath = selected[0].path;
      // If it's a file, use its directory
      if (firstPath.includes(".")) {
        return firstPath.substring(0, firstPath.lastIndexOf("/"));
      }
      return firstPath;
    }
  } catch {
    // Finder selection not available
  }

  // Check for stored preference
  try {
    const stored = await LocalStorage.getItem<string>("preferred_project_root");
    if (stored) {
      return stored;
    }
  } catch {
    // No stored preference
  }

  // Fallback to current working directory
  return process.cwd();
}

/**
 * Get filesystem MCP server configuration
 * IMPORTANT: This assumes @modelcontextprotocol/server-filesystem is installed
 * In production, this should be bundled or use a deterministic binary path
 */
export function getFilesystemMcpServer(allowedPath: string): McpServerConfig {
  // For now, we'll use the node_modules path if available
  // In production, this should be a bundled binary or installed dependency
  const serverCommand = "node";
  const serverPath = `${process.cwd()}/node_modules/@modelcontextprotocol/server-filesystem/dist/index.js`;

  return {
    type: "stdio" as const, // CRITICAL: Must specify type for stdio servers
    command: serverCommand,
    args: [serverPath],
    env: {
      ALLOWED_PATHS: allowedPath,
      NODE_ENV: environment.isDevelopment ? "development" : "production",
    },
  };
}

/**
 * Get all configured MCP servers for the current environment
 */
export async function getMcpServers(): Promise<Record<string, McpServerConfig>> {
  const workingPath = await resolveWorkingPath();

  try {
    const servers: Record<string, McpServerConfig> = {
      filesystem: getFilesystemMcpServer(workingPath),
    };

    return servers;
  } catch (error) {
    // Log error in development
    if (environment.isDevelopment) {
      console.error("Failed to configure MCP servers:", error);
    }

    // Return empty config on error - operate in degraded mode
    return {};
  }
}

/**
 * Check if MCP filesystem server is available
 * This helps provide better error messages to users
 */
export async function checkMcpAvailability(): Promise<boolean> {
  try {
    // Check if the server module exists
    await import("@modelcontextprotocol/server-filesystem");
    return true;
  } catch {
    await showToast({
      style: Toast.Style.Failure,
      title: "MCP Server Not Found",
      message: "Install with: npm install @modelcontextprotocol/server-filesystem",
    });
    return false;
  }
}

/**
 * Development logging utility
 */
export function debugLog(...args: unknown[]): void {
  if (environment.isDevelopment) {
    console.log("[AI Assistant]", ...args);
  }
}
