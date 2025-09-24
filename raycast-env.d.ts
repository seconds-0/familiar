/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {
  /** Anthropic API Key - Your Anthropic API key from console.anthropic.com */
  "anthropicApiKey": string,
  /** Keyboard Shortcut - Global hotkey to open assistant (e.g., cmd+cmd) */
  "shortcut": string,
  /** Use Mock Claude Responses - Bypass the Claude SDK and return a simulated response (useful for UI debugging) */
  "useMockClaude": boolean
}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `assistant` command */
  export type Assistant = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `assistant` command */
  export type Assistant = {}
}

