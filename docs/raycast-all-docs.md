# Introduction

Welcome, developers! Our docs cover guides, examples, references, and more to help you build extensions and share them with [our community](https://raycast.com/community) and your team.



The Raycast Platform consists of two parts:

- **API:** This allows developers to build rich extensions with React, Node.js, and TypeScript. The docs explain how to use the API to build top-notch experiences.
- **Store:** This lets developers share their extensions with all Raycast users. You'll learn how to publish your extension.

## Key features

Here are a few points that make our ecosystem special:

- **Powerful and familiar tooling:** Extensions are built with TypeScript, React, and Node. Leverage npm's ecosystem to quickly build what you imagine.
- **No-brainer to build UI:** You concentrate on the logic, we push the pixels. Use our built-in UI components to be consistent with all our extensions.
- **Collaborate with our community:** Build your extension, share it with our community, and get inspired by others.
- **Developer experience front and foremost:** A strongly typed API, hot-reloading, and modern tooling that makes it a blast to work with.
- **Easy to start, flexible to scale:** Start with a simple script, add a static UI or use React to go wild. Anything goes.

## Overview

A quick overview about where to find what in our docs:

- **Basics:** Go over this section to learn how to build extensions in our step-by-step guides.
- **Teams:** Build and share extensions with your teammates to speed up common workflows.
- **Examples:** Kickstart your extension by using an open-source example and learn as you go.
- **Information:** Get the background knowledge to master your understanding of our platform.
- **API Reference:** Go into details with the API reference that includes code snippets.
- **Utilities:** A set of utilities to streamline common patterns and operations used in extensions.

Now, let's build 💪


# Create an AI Extension

To turn your regular extension into an AI-powered one, you need to add a set of tools that allow Raycast AI to interact with your extension.

## Add AI Tools

The simplest way to add a tool to your extensions is to open the Manage Extensions command, search for your extension and perform the Add New Tool action via the Action Panel (or press `⌥` `⌘` `T`).



{% hint style="info" %}
Alternatively you can edit the `package.json` file manually and add a new entry to the `tools` array.
{% endhint %}

Give the tool a name, a description, and pick a template. The name and description will show up in the UI as well as the Store. The description is passed to AI to help it understand how to use the tool.

## Build Your AI Extension

Just like with regular extensions, you need to build your AI Extension. After you've added a tool, switch to your terminal and navigate to your extension directory. Run `npm install && npm run dev` to start the extension in development mode.

{% hint style="info" %}
`npm run dev` starts the extension in development mode with hot reloading, error reporting and more.
{% endhint %}

## Use Your AI Extension

Open Raycast, and you'll notice a new list item saying "Ask ..." at the top of the root search. Press `↵` to open it. From there on, you can chat to your AI Extension.



Alternatively, you can open Raycast's AI Chat and start chatting to your AI Extension there. Simply type `@` and start typing the name of your extension.



🎉 Congratulations! You built your first AI extension. Now you can start adding more tools to your extension to make it more powerful.


# Follow Best Practices for AI Extensions

Working with LLMs can be tricky. Here are some best practices to make the most out of your AI Extension.

1. Use Confirmations to keep the human in the loop. You can use them dynamically based on the user's input. For example, you might ask for confirmation if moving a file would overwrite an existing file but not if it would create a new file.
2. Write Evals for common use-cases to test your AI Extension and provide users with suggested prompts.
3. Include information in your tool's input on how to format parameters like IDs or dates. For example, you might mention that a date should be provided in ISO 8601 format.
4. Include information in your tool's input on how to get the required parameters. For example, you want to teach AI how to get a team ID that is required to create a new issue.


# Getting Started

There are two ways to leverage the power of AI inside your extensions.

{% hint style="info" %}
To use AI APIs or AI Extensions, you need to subscribe to [Raycast Pro](https://raycast.com/pro).

AI Extensions aren't available on Windows for now.

{% endhint %}

## AI APIs

Use our AI APIs` as part of it's Quick Capture command to generate a summary of a website.

## AI Extensions

Create an AI Extension allows you to manage your team's issues or check your personal priorities by simply chatting to it.


# Learn Core Concepts of AI Extensions

AI Extensions rely on three core concepts: Tools, Instructions, and Evals. Each of these concepts plays a crucial role in the development of AI Extensions. Let's take a closer look at each of them.

## Tools

To turn a regular extension into an AI extension, you need to add a set of tools that allow Raycast AI to interact with your extension. A tool is a function that takes an input and returns a value.

Here's an example of a simple tool:

```typescript
export default function tool() {
  return "Hello, world!";
}
```

### Inputs

Tools can take an input. For example, a `greet` tool takes a `name` as an input and returns a greeting to the user.

```typescript
type Input = {
  name: string;
};

export default function tool(input: Input) {
  return `Hello, ${input.name}!`;
}
```

Those inputs can be used to provide more context to the tool. For example, you can pass a title, a description, and a due date to a `createTask` tool.

```typescript
type Input = {
  /**
   * The title of the task
   */
  title: string;
  /**
   * The description of the task
   */
  description?: string;
  /**
   * The due date of the task in ISO 8601 format
   */
  dueDate?: string;
};

export default function tool(input: Input) {
  // ... create the task
}
```

{% hint style="info" %}
A tool expects a single object as its input.
{% endhint %}

### Descriptions

To better teach AI how to use your tools, you can add descriptions as JSDoc comments (eg. `/** ... */`) to tools and their inputs. The better you describe your tools, the more likely AI is to use them correctly.

```typescript
type Input = {
  /**
   * The first name of the user to greet
   */
  name: string;
};

/**
 * Greet the user with a friendly message
 */
export default function tool(input: Input) {
  return `Hello, ${input.name}!`;
}
```

### Confirmations

Sometimes you want to keep the human in the loop. For example, you can ask the user to confirm an action before it is executed. For this, you can export a `confirmation` function.

```typescript
import { Tool } from "@raycast/api";

type Input = {
  /**
   * The first name of the user to greet
   */
  name: string;
};

export const confirmation: Tool.Confirmation<Input> = async (input) => {
  return {
    message: `Are you sure you want to greet ${input.name}?`,
  };
};

/**
 * Greet the user with a friendly message
 */
export default function tool(input: Input) {
  return `Hello, ${input.name}!`;
}
```

The `confirmation` function is called before the actual tool is executed. If the user confirms, the tool is executed afterwards. If the user cancels, the tool is not executed.

You can customize the confirmation further by providing details about the action that needs to be confirmed. See Tool Reference for more information.

## Instructions

Sometimes you want to provide additional instructions to the AI that are not specific to a single tool but to the entire AI extension. For example, you can provide a list of do's and don'ts for the AI to follow. Those are defined in the `package.json` file under the `ai` key.

```json
{
  "ai": {
    "instructions": "When you don't know the user's first name, ask for it."
  }
}
```

A user can use multiple AI Extensions in a conversation. Therefore, you should make sure that your instructions don't conflict with the instructions of other AI Extensions. For example, avoid phrases like "You are a ... assistant" because other AI Extensions might provide a different skill set. Instead, you should focus on providing general instructions that describe the specifics of your AI Extension. For example, describe the relationship between issues, projects, and teams for a project management app.

## Evals

Evals are a way to test your AI extension. Think of them as integrations tests. They are defined in the `package.json` file under the `ai` key. They are also used as suggested prompts for the user to learn how to make the most out of your AI Extension.

## Structure

An eval consists of the following parts:

- `input` is a text prompt that you expect from users of your AI Extension. It should include `@` mention the name of your extension (`name` from `package.json`).
- `mocks` – mocked results of tool calls. It is required to give AI the context, i.e. if you write an eval for `@todo-list What are my todos?` you need to provide the actual list in `get-todos` mock.
- `expected` – array of expectations, similar to `expect` statements in unit / integration tests.
- `usedAsExample` – if true, the eval will be used as an example prompt for the user. True by default.

## Expectations

Expectations are used to check if the AI response matches the expected behavior. You have different options to choose from:

- `includes`: Check that AI response includes some substring (case-insensitive), for example `{"includes": "added" }`
- `matches`: Check that AI response matches some regexp, for example check if response contains a Markdown link `{ "matches": "\\[([^\\]]+)\\]\\(([^\\s\\)]+)(?:\\s+\"([^\"]+)\")?\\)" }`
- `meetsCriteria`: Check that AI response meets some plain-text criteria (validated using AI). Useful when AI varies the response and it is hard to match it using `includes` or `matches`. Example: `{ "meetsCriteria": "Tells that label with this name doesn't exist" }`
- `callsTool`: Check that during the request AI called some tool included from your AI extension. There are two forms:
  - Short form to check if AI tool with specific name was called. Example: `{ "callsTool": "get-todos" }`
  - Long form to check tool arguments: `{ callsTool: { name: "name", arguments: { arg1: matcher, arg2: matcher } } }`. Matches could be complex and combine any supported rules:
    - `eq` (used by default for any value that is not object or array)
    - `includes`
    - `matches`
    - `and` (used by default if array is used)
    - `or`
    - `not`

#### Example

{% tabs %}
{% tab title="Simple Expectation" %}

```json
{
  "ai": {
    "evals": [
      {
        "expected": [
          {
            "callsTool": {
              "name": "greet",
              "arguments": {
                "name": "thomas"
              }
            }
          }
        ]
      }
    ]
  }
}
```

{% endtab %}
{% tab title="Nested Expectations" %}

```json
{
  "ai": {
    "evals": [
      {
        "expected": [
          {
            "callsTool": {
              "name": "create-comment",
              "arguments": {
                "issueId": "ISS-1",
                "body": {
                  "includes": "waiting for design"
                }
              }
            }
          }
        ]
      }
    ]
  }
}
```

{% endtab %}
{% tab title="Nested Expectations With Dot Notation" %}

```json
{
  "ai": {
    "evals": [
      {
        "expected": [
          {
            "callsTool": {
              "name": "greet",
              "arguments": {
                "user.name": "thomas"
              }
            }
          }
        ]
      }
    ]
  }
}
```

{% endtab %}
{% tab title="Negative Expectation" %}

```json
{
  "ai": {
    "evals": [
      {
        "expected": [
          {
            "not": {
              "callsTool": "create-issue"
            }
          }
        ]
      }
    ]
  }
}
```

{% endtab %}
{% endtabs %}

## AI File

If your instructions or evals start getting too long and clutter your `package.json` file, you can move them to a separate file. It can be either a `ai.json`, `ai.yaml`, or `ai.json5` file in the root of your extension next to the `package.json` file.

The structure of the AI file is the same as in the `package.json` file.

{% tabs %}
{% tab title="ai.json" %}

```json
{
  "instructions": "When you don't know the user's first name, ask for it."
}
```

{% endtab %}

{% tab title="ai.yaml" %}

```yaml
instructions: |
  When you don't know the user's first name, ask for it.
```

{% endtab %}

{% tab title="ai.json5" %}

```json5
{
  instructions: "When you don't know the user's first name, ask for it.",
}
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
The AI file is optional. If you don't provide it, Raycast will use the instructions and evals from the `package.json` file. We found that [`yaml`](https://yaml.org/) and [`json5`](https://json5.org/) can be more readable for long instructions.
{% endhint %}


# Write Evals For Your AI Extension

We all know that AI is not always reliable. This is why it's important to write evals for your AI Extension. Evals allow you to test your AI Extension and make sure it behaves as expected.

## Add an Eval

The easiest way to add an eval is to first use your AI Extension. Then, once Raycast AI used your tools to finish its response, you can use the Copy Eval action to copy the eval to your clipboard.



You can then paste the eval into the `evals` array in the `package.json` file.

```json
{
  "ai": {
    "evals": [
      {
        "input": "@todo-list what are my open todos",
        "mocks": {
          "get-todos": [
            {
              "id": "Z5lF8F-lSvGCD6e3uZwkL",
              "isCompleted": false,
              "title": "Buy oat milk"
            },
            {
              "id": "69Ag2mfaDakC3IP8XxpXU",
              "isCompleted": false,
              "title": "Play with my cat"
            }
          ]
        },
        "expected": [
          {
            "callsTool": "get-todos"
          }
        ]
      }
    ]
  }
}
```

## Run Your Evals

To run your evals, you can use the `npx ray evals` command. This will run the evals and print the results to the console. You get an overview of the evals that failed and the ones that passed. From here you can start improving the names and descriptions of your tools.

Visit Learn Core Concepts of AI Extensions to learn more about the different types of evals you can write.


# AI

The AI API provides developers with seamless access to AI functionality without requiring API keys, configuration, or extra dependencies.

{% hint style="info" %}

Some users might not have access to this API. If a user doesn't have access to Raycast Pro, they will be asked if they want to get access when your extension calls the AI API. If the user doesn't wish to get access, the API call will throw an error.

You can check if a user has access to the API using `environment.canAccess(AI)`.

{% endhint %}

## API Reference

### AI.ask

Ask AI anything you want. Use this in “no-view” Commands, effects, or callbacks. In a React component, you might want to use the useAI util hook instead.

#### Signature

```typescript
async function ask(prompt: string, options?: AskOptions): Promise<string> & EventEmitter;
```

#### Example

{% tabs %}
{% tab title="Basic Usage" %}

```typescript
import { AI, Clipboard } from "@raycast/api";

export default async function command() {
  const answer = await AI.ask("Suggest 5 jazz songs");

  await Clipboard.copy(answer);
}
```

{% endtab %}
{% tab title="Error handling" %}

```typescript
import { AI, showToast, Toast } from "@raycast/api";

export default async function command() {
  try {
    await AI.ask("Suggest 5 jazz songs");
  } catch (error) {
    // Handle error here, eg: by showing a Toast
    await showToast({
      style: Toast.Style.Failure,
      title: "Failed to generate answer",
    });
  }
}
```

{% endtab %}
{% tab title="Stream answer" %}

```typescript
import { AI, getSelectedFinderItems, showHUD } from "@raycast/api";
import fs from "fs";

export default async function main() {
  let allData = "";
  const [file] = await getSelectedFinderItems();

  const answer = AI.ask("Suggest 5 jazz songs");

  // Listen to "data" event to stream the answer
  answer.on("data", async (data) => {
    allData += data;
    await fs.promises.writeFile(`${file.path}`, allData.trim(), "utf-8");
  });

  await answer;

  await showHUD("Done!");
}
```

{% endtab %}
{% tab title="User Feedback" %}

```typescript
import { AI, getSelectedFinderItems, showHUD } from "@raycast/api";
import fs from "fs";

export default async function main() {
  let allData = "";
  const [file] = await getSelectedFinderItems();

  // If you're doing something that happens in the background
  // Consider showing a HUD or a Toast as the first step
  // To give users feedback about what's happening
  await showHUD("Generating answer...");

  const answer = await AI.ask("Suggest 5 jazz songs");

  await fs.promises.writeFile(`${file.path}`, allData.trim(), "utf-8");

  // Then, when everythig is done, notify the user again
  await showHUD("Done!");
}
```

{% endtab %}
{% tab title="Check for access" %}

```typescript
import { AI, getSelectedFinderItems, showHUD, environment } from "@raycast/api";
import fs from "fs";

export default async function main() {
  if (environment.canAccess(AI)) {
    const answer = await AI.ask("Suggest 5 jazz songs");
    await Clipboard.copy(answer);
  } else {
    await showHUD("You don't have access :(");
  }
}
```

{% endtab %}
{% endtabs %}

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| prompt<mark style="color:red;">*</mark> | The prompt to ask the AI. | <code>string</code> |
| options | Options to control which and how the AI model should behave. | <code>AI.AskOptions</code> |

#### Return

A Promise that resolves with a prompt completion.

## Types

### AI.Creativity

Concrete tasks, such as fixing grammar, require less creativity while open-ended questions, such as generating ideas, require more.

```typescript
type Creativity = "none" | "low" | "medium" | "high" | "maximum" | number;
```

If a number is passed, it needs to be in the range 0-2. For larger values, 2 will be used. For lower values, 0 will be used.

### AI.Model

The AI model to use to answer to the prompt. Defaults to `AI.Model["OpenAI_GPT3.5-turbo"]`.

#### Enumeration members

| Model                                   | Description                                                                            |
| --------------------------------------- | -------------------------------------------------------------------------------------- |
| OpenAI_GPT5-mini                        | OpenAI's latest model, great for well-defined tasks and precise prompts.               |
| OpenAI_GPT5-nano                        | OpenAI's latest model, great for summarization and classification tasks.               |
| OpenAI_GPT4.1                           | OpenAI's flagship model optimized for complex problem solving.                         |
| OpenAI_GPT4.1-mini                      | Balanced GPT-4.1 variant optimized for speed and cost efficiency.                      |
| OpenAI_GPT4.1-nano                      | Fastest and most cost-effective GPT-4.1 variant.                                       |
| OpenAI_GPT4                             | Previous generation GPT-4 model with broad knowledge and complex instruction handling. |
| OpenAI_GPT4-turbo                       | Previous generation GPT-4 with expanded context window.                                |
| OpenAI_GPT4o                            | Advanced OpenAI model optimized for speed and complex problem solving.                 |
| OpenAI_GPT4o-mini                       | Fast and intelligent model for everyday tasks.                                         |
| OpenAI_GPT5                             | OpenAI's latest model, great for coding and agentic tasks across domains.              |
| OpenAI_o3                               | Advanced model excelling in math, science, coding, and visual tasks.                   |
| OpenAI_o4-mini                          | Fast, efficient model optimized for coding and visual tasks.                           |
| OpenAI_o1                               | Advanced reasoning model for complex STEM problems.                                    |
| OpenAI_o3-mini                          | Fast reasoning model optimized for STEM tasks.                                         |
| OpenAI_GPT_OSS_20b                      | OpenAI's first open-source model, 20b variant.                                         |
| OpenAI_GPT_OSS_120b                     | OpenAI's first open-source model, 120b variant.                                        |
| Anthropic_Claude_Haiku                  | Anthropic's fastest model with large context window for code and text analysis.        |
| Anthropic_Claude_Sonnet                 | Enhanced Claude model for complex tasks and visual reasoning.                          |
| Anthropic_Claude_Sonnet_3.7             | Anthropic's most intelligent model.                                                    |
| Anthropic_Claude_4_Sonnet               | Anthropic's most intelligent model.                                                    |
| Anthropic_Claude_4_Opus                 | Anthropic's model for complex tasks with exceptional fluency.                          |
| Anthropic_Claude_4.1_Opus               | Anthropic's model for complex tasks with exceptional fluency.                          |
| Perplexity_Sonar                        | Fast Perplexity model with integrated search capabilities.                             |
| Perplexity_Sonar_Pro                    | Advanced Perplexity model for complex queries with search integration.                 |
| Perplexity_Sonar_Reasoning              | Fast reasoning model powered by DeepSeek R1.                                           |
| Perplexity_Sonar_Reasoning_Pro          | Premium reasoning model with DeepSeek R1 capabilities.                                 |
| Llama4_Scout                            | Advanced 17B parameter multimodal model with 16 experts.                               |
| Llama3.3_70B                            | Meta's state-of-the-art model for reasoning and general knowledge.                     |
| Llama3.1_8B                             | Fast, instruction-optimized open-source model.                                         |
| Llama3.1_405B                           | Meta's flagship model with advanced capabilities across multiple domains.              |
| Mistral_Nemo                            | Small, Apache-licensed model built with NVIDIA.                                        |
| Mistral_Large                           | Top-tier reasoning model with strong multilingual support.                             |
| Mistral_Medium                          | A powerful, cost-effective, frontier-class multimodal model.                           |
| Mistral_Small                           | Latest enterprise-grade small model with improved reasoning.                           |
| Mistral_Codestral                       | Specialized model for code-related tasks and testing.                                  |
| Groq_Kimi_K2_Instruct                   | Kimi K2 is a powerful and versatile AI model designed for a wide range of tasks.       |
| Groq_Qwen3_32B                          | The latest generation of large language models in the Qwen series.                     |
| DeepSeek_R1_Distill_Llama_3.3_70B       | Fine-tuned Llama model with enhanced reasoning capabilities.                           |
| Google_Gemini_2.5_Pro                   | Advanced thinking model for complex problem solving.                                   |
| Google_Gemini_2.5_Flash                 | Fast, well-rounded thinking model.                                                     |
| Google_Gemini_2.5_Flash_Lite            | Fast model optimized for large-scale text output.                                      |
| Google_Gemini_2.0_Flash                 | Low-latency model optimized for agentic experiences.                                   |
| Groq_Qwen3_235B_A22B_Instruct_2507_tput | A varied model with enhanced reasoning.                                                |
| DeepSeek_R1                             | Open-source model matching OpenAI-o1 performance.                                      |
| DeepSeek_V3                             | Advanced Mixture-of-Experts model.                                                     |
| xAI_Grok_4                              | Advanced language model with enhanced reasoning and tool capabilities.                 |
| xAI_Grok_3                              | Enterprise-focused model for data, coding, and summarization tasks.                    |
| xAI_Grok_3_Mini                         | Fast, lightweight model for logic-based tasks.                                         |
| xAI_Grok_2                              | Advanced language model with strong reasoning capabilities.                            |

If a model isn't available to the user (or has been disabled by the user), Raycast will fallback to a similar one.

### AI.AskOptions

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| creativity | Concrete tasks, such as fixing grammar, require less creativity while open-ended questions, such as generating ideas, require more.  If a number is passed, it needs to be in the range 0-2. For larger values, 2 will be used. For lower values, 0 will be used. | <code>AI.Creativity</code> |
| model | The AI model to use to answer to the prompt. | <code>AI.Model</code> |
| signal | Abort signal to cancel the request. | <code>[Date](https://developer.mozilla.org/en-US/docs/Web/API/AbortSignal)</code> |


# Browser Extension

The Browser Extension API provides developers with deeper integration into the user's Browser _via_ a [Browser Extension](https://raycast.com/browser-extension).

{% hint style="info" %}

Some users might not have installed the Browser Extension. If a user doesn't have the Browser Extension installed, they will be asked if they want to install it when your extension calls the Browser Extension API. If the user doesn't wish to install it, the API call will throw an error.

You can check if a user has the Browser Extension installed using `environment.canAccess(BrowserExtension)`.

The API is not accessible on Windows for now.

{% endhint %}

## API Reference

### BrowserExtension.getContent

Get the content of an opened browser tab.

#### Signature

```typescript
async function getContent(options?: {
  cssSelector?: string;
  tabId?: number;
  format?: "html" | "text" | "markdown";
}): Promise<string>;
```

#### Example

{% tabs %}
{% tab title="Basic Usage" %}

```typescript
import { BrowserExtension, Clipboard } from "@raycast/api";

export default async function command() {
  const markdown = await BrowserExtension.getContent({ format: "markdown" });

  await Clipboard.copy(markdown);
}
```

{% endtab %}
{% tab title="CSS Selector" %}

```typescript
import { BrowserExtension, Clipboard } from "@raycast/api";

export default async function command() {
  const title = await BrowserExtension.getContent({ format: "text", cssSelector: "title" });

  await Clipboard.copy(title);
}
```

{% endtab %}
{% endtabs %}

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| options | Options to control which content to get. | <code>Object</code> |
| options.cssSelector | Only returns the content of the element that matches the [CSS selector](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_selectors).    If the selector matches multiple elements, only the first one is returned.  If the selector doesn't match any element, an empty string is returned.    When using a CSS selector, the `format` option can not be `markdown`. | <code>string</code> |
| options.format | The format of the content.    - `html`: `document.documentElement.outerHTML`  - `text`: `document.body.innerText`  - `markdown`: A heuristic to get the "content" of the document and convert it to markdown. Think of it as the "reader mode" of a browser. | <code>"html"</code> or <code>"text"</code> or <code>"markdown"</code> |
| options.tabId | The ID of the tab to get the content from. If not specified, the content of the active tab of the focused window is returned. | <code>number</code> |

#### Return

A Promise that resolves with the content of the tab.

### BrowserExtension.getTabs

Get the list of open browser tabs.

#### Signature

```typescript
async function getTabs(): Promise<Tab[]>;
```

#### Example

```typescript
import { BrowserExtension } from "@raycast/api";

export default async function command() {
  const tabs = await BrowserExtension.getTabs();
  console.log(tabs);
}
```

#### Return

A Promise that resolves with the list of tabs.

## Types

### BrowserExtension.Tab

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| active<mark style="color:red;">*</mark> | Whether the tab is active in its window.  There can only be one active tab per window but if there are multiple browser windows, there can be multiple active tabs. | <code>boolean</code> |
| id<mark style="color:red;">*</mark> | The ID of the tab. Tab IDs are unique within a browser session. | <code>number</code> |
| url<mark style="color:red;">*</mark> | The URL the tab is displaying. | <code>string</code> |
| favicon | The URL of the tab's [favicon](https://developer.mozilla.org/en-US/docs/Glossary/Favicon). It may also be `undefined` if the tab is loading. | <code>string</code> |
| title | The title of the tab. It may also be `undefined` if the tab is loading. | <code>string</code> |


# Caching

Caching abstraction that stores data on disk and supports LRU (least recently used) access. Since extensions can only consume up to a max. heap memory size, the cache only maintains a lightweight index in memory and stores the actual data in separate files on disk in the extension's support directory.

## API Reference

### Cache

The `Cache` class provides CRUD-style methods (get, set, remove) to update and retrieve data synchronously based on a key. The data must be a string and it is up to the client to decide which serialization format to use.
A typical use case would be to use `JSON.stringify` and `JSON.parse`.

By default, the cache is shared between the commands of an extension. Use Cache.Options.

#### Signature

```typescript
constructor(options: Cache.Options): Cache
```

#### Example

```typescript
import { List, Cache } from "@raycast/api";

type Item = { id: string; title: string };
const cache = new Cache();
cache.set("items", JSON.stringify([{ id: "1", title: "Item 1" }]));

export default function Command() {
  const cached = cache.get("items");
  const items: Item[] = cached ? JSON.parse(cached) : [];

  return (
    <List>
      {items.map((item) => (
        <List.Item key={item.id} title={item.title} />
      ))}
    </List>
  );
}
```

#### Properties

| Property                                  | Description                                              | Type                 |
| :---------------------------------------- | :------------------------------------------------------- | :------------------- |
| isEmpty<mark style="color:red;">\*</mark> | Returns `true` if the cache is empty, `false` otherwise. | <code>boolean</code> |

#### Methods

| Method                                                                                       |
| :------------------------------------------------------------------------------------------- |
| <code>get(key: string): string \| undefined</code>                             |
| <code>has(key: string): boolean</code>                                         |
| <code>set(key: string, data: string): void</code>                              |
| <code>remove(key: string): boolean</code>                                   |
| <code>clear(options = { notifySubscribers: true }): void</code>              |
| <code>subscribe(subscriber: Cache.Subscriber): Cache.Subscription</code> |

### Cache#get

Returns the data for the given key. If there is no data for the key, `undefined` is returned.
If you want to just check for the existence of a key, use has.

#### Signature

```typescript
get(key: string): string | undefined
```

#### Parameters

| Name                                  | Description                 | Type                |
| :------------------------------------ | :-------------------------- | :------------------ |
| key<mark style="color:red;">\*</mark> | The key of the Cache entry. | <code>string</code> |

### Cache#has

Returns `true` if data for the key exists, `false` otherwise.
You can use this method to check for entries without affecting the LRU access.

#### Signature

```typescript
has(key: string): boolean
```

#### Parameters

| Name                                  | Description                 | Type                |
| :------------------------------------ | :-------------------------- | :------------------ |
| key<mark style="color:red;">\*</mark> | The key of the Cache entry. | <code>string</code> |

### Cache#set

Sets the data for the given key.
If the data exceeds the configured `capacity`, the least recently used entries are removed.
This also notifies registered subscribers (see subscribe.

#### Signature

```typescript
set(key: string, data: string)
```

#### Parameters

| Name                                   | Description                              | Type                |
| :------------------------------------- | :--------------------------------------- | :------------------ |
| key<mark style="color:red;">\*</mark>  | The key of the Cache entry.              | <code>string</code> |
| data<mark style="color:red;">\*</mark> | The stringified data of the Cache entry. | <code>string</code> |

### Cache#remove

Removes the data for the given key.
This also notifies registered subscribers (see subscribe.
Returns `true` if data for the key was removed, `false` otherwise.

#### Signature

```typescript
remove(key: string): boolean
```

### Cache#clear

Clears all stored data.
This also notifies registered subscribers (see subscribe unless the `notifySubscribers` option is set to `false`.

#### Signature

```typescript
clear((options = { notifySubscribers: true }));
```

#### Parameters

| Name    | Description                                                                                                                | Type                |
| :------ | :------------------------------------------------------------------------------------------------------------------------- | :------------------ |
| options | Options with a `notifySubscribers` property. The default is `true`; set to `false` to disable notification of subscribers. | <code>object</code> |

### Cache#subscribe

Registers a new subscriber that gets notified when cache data is set or removed.
Returns a function that can be called to remove the subscriber.

#### Signature

```typescript
subscribe(subscriber: Cache.Subscriber): Cache.Subscription
```

#### Parameters

| Name       | Description                                                                                                                                                                                               | Type                                               |
| :--------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------- |
| subscriber | A function that is called when the Cache is updated. The function receives two values: the `key` of the Cache entry that was updated or `undefined` when the Cache is cleared, and the associated `data`. | <code>Cache.Subscriber</code> |

## Types

### Cache.Options

The options for creating a new Cache.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| capacity | The capacity in bytes. If the stored data exceeds the capacity, the least recently used data is removed.  The default capacity is 10 MB. | <code>number</code> |
| namespace | If set, the Cache will be namespaced via a subdirectory.  This can be useful to separate the caches for individual commands of an extension.  By default, the cache is shared between the commands of an extension. | <code>string</code> |

### Cache.Subscriber

Function type used as parameter for subscribe.

```typescript
type Subscriber = (key: string | undefined, data: string | undefined) => void;
```

### Cache.Subscription

Function type returned from subscribe.

```typescript
type Subscription = () => void;
```


# Clipboard

Use the Clipboard APIs to work with content from your clipboard. You can write contents to the clipboard through `Clipboard.copy` function inserts text at the current cursor position in your frontmost app.

The action `Action.CopyToClipboard` can be used to insert text in your frontmost app.

## API Reference

### Clipboard.copy

Copies text or a file to the clipboard.

#### Signature

```typescript
async function copy(content: string | number | Content, options?: CopyOptions): Promise<void>;
```

#### Example

```typescript
import { Clipboard } from "@raycast/api";

export default async function Command() {
  // copy some text
  await Clipboard.copy("https://raycast.com");

  const textContent: Clipboard.Content = {
    text: "https://raycast.com",
  };
  await Clipboard.copy(textContent);

  // copy a file
  const file = "/path/to/file.pdf";
  try {
    const fileContent: Clipboard.Content = { file };
    await Clipboard.copy(fileContent);
  } catch (error) {
    console.log(`Could not copy file '${file}'. Reason: ${error}`);
  }

  // copy confidential data
  await Clipboard.copy("my-secret-password", { concealed: true });
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| content<mark style="color:red;">*</mark> | The content to copy to the clipboard. | <code>string</code> or <code>number</code> or <code>Clipboard.Content</code> |
| options | Options for the copy operation. | <code>Clipboard.CopyOptions</code> |

#### Return

A Promise that resolves when the content is copied to the clipboard.

### Clipboard.paste

Pastes text or a file to the current selection of the frontmost application.

#### Signature

```typescript
async function paste(content: string | Content): Promise<void>;
```

#### Example

```typescript
import { Clipboard } from "@raycast/api";

export default async function Command() {
  await Clipboard.paste("I really like Raycast's API");
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| content<mark style="color:red;">*</mark> | The content to insert at the cursor. | <code>string</code> or <code>number</code> or <code>Clipboard.Content</code> |

#### Return

A Promise that resolves when the content is pasted.

### Clipboard.clear

Clears the current clipboard contents.

#### Signature

```typescript
async function clear(): Promise<void>;
```

#### Example

```typescript
import { Clipboard } from "@raycast/api";

export default async function Command() {
  await Clipboard.clear();
}
```

#### Return

A Promise that resolves when the clipboard is cleared.

### Clipboard.read

Reads the clipboard content as plain text, file name, or HTML.

#### Signature

```typescript
async function read(options?: { offset?: number }): Promise<ReadContent>;
```

#### Example

```typescript
import { Clipboard } from "@raycast/api";

export default async () => {
  const { text, file, html } = await Clipboard.read();
  console.log(text);
  console.log(file);
  console.log(html);
};
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| options | Options for the read operation. | <code>Object</code> |
| options.offset | Specify an offset to access the Clipboard History. Minimum value is 0, maximum value is 5. | <code>number</code> |

#### Return

A promise that resolves when the clipboard content was read as plain text, file name, or HTML.

### Clipboard.readText

Reads the clipboard as plain text.

#### Signature

```typescript
async function readText(options?: { offset?: number }): Promise<string | undefined>;
```

#### Example

```typescript
import { Clipboard } from "@raycast/api";

export default async function Command() {
  const text = await Clipboard.readText();
  console.log(text);
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| options | Options for the readText operation. | <code>Object</code> |
| options.offset | Specify an offset to access the Clipboard History. Minimum value is 0, maximum value is 5. | <code>number</code> |

#### Return

A promise that resolves once the clipboard content is read as plain text.

## Types

### Clipboard.Content

Type of content that is copied and pasted to and from the Clipboard

```typescript
type Content =
  | {
      text: string;
    }
  | {
      file: PathLike;
    }
  | {
      html: string;
      text?: string; // The alternative text representation of the content.
    };
```

### Clipboard.ReadContent

Type of content that is read from the Clipboard

```typescript
type Content =
  | {
      text: string;
    }
  | {
      file?: string;
    }
  | {
      html?: string;
    };
```

### Clipboard.CopyOptions

Type of options passed to `Clipboard.copy`.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| concealed | Indicates whether the content be treated as confidential. If `true`, it will not be recorded in the Clipboard History. | <code>boolean</code> |


# Command-related Utilities

This set of utilities to work with Raycast commands.

## API Reference

### launchCommand

Launches another command. If the command does not exist, or if it's not enabled, an error will be thrown.
If the command is part of another extension, the user will be presented with a permission alert.
Use this method if your command needs to open another command based on user interaction,
or when an immediate background refresh should be triggered, for example when a command needs to update an associated menu-bar command.

#### Signature

```typescript
export async function launchCommand(options: LaunchOptions): Promise<void>;
```

#### Example

```typescript
import { launchCommand, LaunchType } from "@raycast/api";

export default async function Command() {
  await launchCommand({ name: "list", type: LaunchType.UserInitiated, context: { foo: "bar" } });
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| options<mark style="color:red;">*</mark> | Options to launch a command within the same extension or in another extension. | <code>LaunchOptions</code> |

#### Return

A Promise that resolves when the command has been launched. (Note that this does not indicate that the launched command has finished executing.)

### updateCommandMetadata

Update the values of properties declared in the manifest of the current command. Note that currently only `subtitle` is supported. Pass `null` to clear the custom subtitle.

{% hint style="info" %}
The actual manifest file is not modified, so the update applies as long as the command remains installed.
{% endhint %}

#### Signature

```typescript
export async function updateCommandMetadata(metadata: { subtitle?: string | null }): Promise<void>;
```

#### Example

```typescript
import { updateCommandMetadata } from "@raycast/api";

async function fetchUnreadNotificationCount() {
  return 10;
}

export default async function Command() {
  const count = await fetchUnreadNotificationCount();
  await updateCommandMetadata({ subtitle: `Unread Notifications: ${count}` });
}
```

#### Return

A Promise that resolves when the command's metadata have been updated.

## Types

### LaunchContext

Represents the passed context object of programmatic command launches.

### LaunchOptions

A parameter object used to decide which command should be launched and what data (arguments, context) it should receive.

#### IntraExtensionLaunchOptions

The options that can be used when launching a command from the same extension.

| Property | Description | Type |
| :--- | :--- | :--- |
| name<mark style="color:red;">*</mark> | Command name as defined in the extension's manifest | <code>string</code> |
| type<mark style="color:red;">*</mark> | LaunchType.UserInitiated or LaunchType.Background | <code>LaunchType</code> |
| arguments | Optional object for the argument properties and values as defined in the extension's manifest, for example: `{ "argument1": "value1" }` | <code>Arguments</code> or <code>null</code> |
| context | Arbitrary object for custom data that should be passed to the command and accessible as LaunchProps; the object must be JSON serializable (Dates and Buffers supported) | <code>LaunchContext</code> or <code>null</code> |
| fallbackText | Optional string to send as fallback text to the command | <code>string</code> or <code>null</code> |

#### InterExtensionLaunchOptions

The options that can be used when launching a command from a different extension.

| Property | Description | Type |
| :--- | :--- | :--- |
| extensionName<mark style="color:red;">*</mark> | When launching command from a different extension, the extension name (as defined in the extension's manifest) is necessary | <code>string</code> |
| name<mark style="color:red;">*</mark> | Command name as defined in the extension's manifest | <code>string</code> |
| ownerOrAuthorName<mark style="color:red;">*</mark> | When launching command from a different extension, the owner or author (as defined in the extension's manifest) is necessary | <code>string</code> |
| type<mark style="color:red;">*</mark> | LaunchType.UserInitiated or LaunchType.Background | <code>LaunchType</code> |
| arguments | Optional object for the argument properties and values as defined in the extension's manifest, for example: `{ "argument1": "value1" }` | <code>Arguments</code> or <code>null</code> |
| context | Arbitrary object for custom data that should be passed to the command and accessible as LaunchProps; the object must be JSON serializable (Dates and Buffers supported) | <code>LaunchContext</code> or <code>null</code> |
| fallbackText | Optional string to send as fallback text to the command | <code>string</code> or <code>null</code> |


# Environment

The Environment APIs are useful to get context about the setup in which your command runs. You can get information about the extension and command itself as well as Raycast. Furthermore, a few paths are injected and are helpful to construct file paths that are related to the command's assets.

## API Reference

### environment

Contains environment values such as the Raycast version, extension info, and paths.

#### Example

```typescript
import { environment } from "@raycast/api";

export default async function Command() {
  console.log(`Raycast version: ${environment.raycastVersion}`);
  console.log(`Owner or Author name: ${environment.ownerOrAuthorName}`);
  console.log(`Extension name: ${environment.extensionName}`);
  console.log(`Command name: ${environment.commandName}`);
  console.log(`Command mode: ${environment.commandMode}`);
  console.log(`Assets path: ${environment.assetsPath}`);
  console.log(`Support path: ${environment.supportPath}`);
  console.log(`Is development mode: ${environment.isDevelopment}`);
  console.log(`Appearance: ${environment.appearance}`);
  console.log(`Text size: ${environment.textSize}`);
  console.log(`LaunchType: ${environment.launchType}`);
}
```

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| appearance<mark style="color:red;">*</mark> | The appearance used by the Raycast application. | <code>"dark"</code> or <code>"light"</code> |
| assetsPath<mark style="color:red;">*</mark> | The absolute path to the assets directory of the extension. | <code>string</code> |
| commandMode<mark style="color:red;">*</mark> | The mode of the launched command, as specified in package.json | <code>"view"</code> or <code>"no-view"</code> or <code>"menu-bar"</code> |
| commandName<mark style="color:red;">*</mark> | The name of the launched command, as specified in package.json | <code>string</code> |
| extensionName<mark style="color:red;">*</mark> | The name of the extension, as specified in package.json | <code>string</code> |
| isDevelopment<mark style="color:red;">*</mark> | Indicates whether the command is a development command (vs. an installed command from the Store). | <code>boolean</code> |
| launchType<mark style="color:red;">*</mark> | The type of launch for the command (user initiated or background). | <code>LaunchType</code> |
| ownerOrAuthorName<mark style="color:red;">*</mark> | The name of the extension owner (if any) or author, as specified in package.json | <code>string</code> |
| raycastVersion<mark style="color:red;">*</mark> | The version of the main Raycast app | <code>string</code> |
| supportPath<mark style="color:red;">*</mark> | The absolute path for the support directory of an extension. Use it to read and write files related to your extension or command. | <code>string</code> |
| textSize<mark style="color:red;">*</mark> | The text size used by the Raycast application. | <code>"medium"</code> or <code>"large"</code> |
| canAccess<mark style="color:red;">*</mark> |  | <code>(api: unknown) => boolean</code> |

### environment.canAccess

Checks whether the user can access a specific API or not.

#### Signature

```typescript
function canAccess(api: any): bool;
```

#### Example

```typescript
import { AI, showHUD, environment } from "@raycast/api";
import fs from "fs";

export default async function main() {
  if (environment.canAccess(AI)) {
    const answer = await AI.ask("Suggest 5 jazz songs");
    await Clipboard.copy(answer);
  } else {
    await showHUD("You don't have access :(");
  }
}
```

#### Return

A Boolean indicating whether the user running the command has access to the API.

### getSelectedFinderItems

Gets the selected items from Finder.

#### Signature

```typescript
async function getSelectedFinderItems(): Promise<FileSystemItem[]>;
```

#### Example

```typescript
import { getSelectedFinderItems, showToast, Toast } from "@raycast/api";

export default async function Command() {
  try {
    const selectedItems = await getSelectedFinderItems();
    console.log(selectedItems);
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: "Cannot copy file path",
      message: String(error),
    });
  }
}
```

#### Return

A Promise that resolves with the selected file system items. If Finder is not the frontmost application, the promise will be rejected.

### getSelectedText

Gets the selected text of the frontmost application.

#### Signature

```typescript
async function getSelectedText(): Promise<string>;
```

#### Example

```typescript
import { getSelectedText, Clipboard, showToast, Toast } from "@raycast/api";

export default async function Command() {
  try {
    const selectedText = await getSelectedText();
    const transformedText = selectedText.toUpperCase();
    await Clipboard.paste(transformedText);
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: "Cannot transform text",
      message: String(error),
    });
  }
}
```

#### Return

A Promise that resolves with the selected text. If no text is selected in the frontmost application, the promise will be rejected.

## Types

### FileSystemItem

Holds data about a File System item. Use the getSelectedFinderItems method to retrieve values.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| path<mark style="color:red;">*</mark> | The path to the item | <code>string</code> |

### LaunchType

Indicates the type of command launch. Use this to detect whether the command has been launched from the background.

#### Enumeration members

| Name          | Description                                                |
| :------------ | :--------------------------------------------------------- |
| UserInitiated | A regular launch through user interaction                  |
| Background    | Scheduled through an interval and launched from background |


# Feedback

Raycast has several ways to provide feedback to the user:

- Toast _- when an asynchronous operation is happening or when an error is thrown_
- HUD _- to confirm an action worked after closing Raycast_
- Alert _- to ask for confirmation before taking an action_




# Alert

When the user takes an important action (for example when irreversibly deleting something), you can ask for confirmation by using `confirmAlert`.



## API Reference

### confirmAlert

Creates and shows a confirmation Alert with the given options.

#### Signature

```typescript
async function confirmAlert(options: Alert.Options): Promise<boolean>;
```

#### Example

```typescript
import { confirmAlert } from "@raycast/api";

export default async function Command() {
  if (await confirmAlert({ title: "Are you sure?" })) {
    console.log("confirmed");
    // do something
  } else {
    console.log("canceled");
  }
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| options<mark style="color:red;">*</mark> | The options used to create the Alert. | <code>Alert.Options</code> |

#### Return

A Promise that resolves to a boolean when the user triggers one of the actions.
It will be `true` for the primary Action, `false` for the dismiss Action.

## Types

### Alert.Options

The options to create an Alert.

#### Example

```typescript
import { Alert, confirmAlert } from "@raycast/api";

export default async function Command() {
  const options: Alert.Options = {
    title: "Finished cooking",
    message: "Delicious pasta for lunch",
    primaryAction: {
      title: "Do something",
      onAction: () => {
        // while you can register a handler for an action, it's more elegant
        // to use the `if (await confirmAlert(...)) { ... }` pattern
        console.log("The alert action has been triggered");
      },
    },
  };
  await confirmAlert(options);
}
```

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The title of an alert. Displayed below the icon. | <code>string</code> |
| dismissAction | The Action to dismiss the alert. There usually shouldn't be any side effects when the user takes this action. | <code>Alert.ActionOptions</code> |
| icon | The icon of an alert to illustrate the action. Displayed on the top. | <code>Image.ImageLike</code> |
| message | An additional message for an Alert. Useful to show more information, e.g. a confirmation message for a destructive action. | <code>string</code> |
| primaryAction | The primary Action the user can take. | <code>Alert.ActionOptions</code> |
| rememberUserChoice | If set to true, the Alert will also display a `Do not show this message again` checkbox. When checked, the answer  is persisted and directly returned to the extension the next time the alert should be shown, without the user  actually seeing the alert. | <code>boolean</code> |

### Alert.ActionOptions

The options to create an Alert Action.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The title of the action. | <code>string</code> |
| onAction | A callback called when the action is triggered. | <code>() => void</code> |
| style | The style of the action. | <code>Alert.ActionStyle</code> |

### Alert.ActionStyle

Defines the visual style of an Action of the Alert.

Use Alert.ActionStyle.Default for confirmations of a positive action.
Use Alert.ActionStyle.Destructive.

#### Enumeration members

| Name        | Value                                                    |
| :---------- | :------------------------------------------------------- |
| Default     |      |
| Destructive |  |
| Cancel      |       |


# HUD

When the user takes an action that has the side effect of closing Raycast (for example when copying something in the Clipboard, you can use a HUD to confirm that the action worked properly.



## API Reference

### showHUD

A HUD will automatically hide the main window and show a compact message at the bottom of the screen.

#### Signature

```typescript
async function showHUD(
  title: string,
  options?: { clearRootSearch?: boolean; popToRootType?: PopToRootType }
): Promise<void>;
```

#### Example

```typescript
import { showHUD } from "@raycast/api";

export default async function Command() {
  await showHUD("Hey there 👋");
}
```

`showHUD` closes the main window when called, so you can use the same options as `closeMainWindow`:

```typescript
import { PopToRootType, showHUD } from "@raycast/api";

export default async function Command() {
  await showHUD("Hey there 👋", { clearRootSearch: true, popToRootType: PopToRootType.Immediate });
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The title that will be displayed in the HUD. | <code>string</code> |
| options | Can be used to control the behaviour after closing the main window. | <code>Object</code> |
| options.clearRootSearch | Clears the text in the root search bar and scrolls to the top | <code>boolean</code> |
| options.popToRootType | Defines the pop to root behavior (PopToRootType); the default is to to respect the user's "Pop to Root Search" preference in Raycast | <code>PopToRootType</code> |

#### Return

A Promise that resolves when the HUD is shown.


# Toast

When an asynchronous operation is happening or when an error is thrown, it's usually a good idea to keep the user informed about it. Toasts are made for that.

Additionally, Toasts can have some actions associated to the action they are about. For example, you could provide a way to cancel an asynchronous operation, undo an action, or copy the stack trace of an error.

{% hint style="info" %}
The `showToast()` will fallback to showHUD() if the Raycast window is closed.
{% endhint %}



## API Reference

### showToast

Creates and shows a Toast with the given options.

#### Signature

```typescript
async function showToast(options: Toast.Options): Promise<Toast>;
```

#### Example

```typescript
import { showToast, Toast } from "@raycast/api";

export default async function Command() {
  const success = false;

  if (success) {
    await showToast({ title: "Dinner is ready", message: "Pizza margherita" });
  } else {
    await showToast({
      style: Toast.Style.Failure,
      title: "Dinner isn't ready",
      message: "Pizza dropped on the floor",
    });
  }
}
```

When showing an animated Toast, you can later on update it:

```typescript
import { showToast, Toast } from "@raycast/api";
import { setTimeout } from "timers/promises";

export default async function Command() {
  const toast = await showToast({
    style: Toast.Style.Animated,
    title: "Uploading image",
  });

  try {
    // upload the image
    await setTimeout(1000);

    toast.style = Toast.Style.Success;
    toast.title = "Uploaded image";
  } catch (err) {
    toast.style = Toast.Style.Failure;
    toast.title = "Failed to upload image";
    if (err instanceof Error) {
      toast.message = err.message;
    }
  }
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| options<mark style="color:red;">*</mark> | The options to customize the Toast. | <code>Alert.Options</code> |

#### Return

A Promise that resolves with the shown Toast. The Toast can be used to change or hide it.

## Types

### Toast

A Toast with a certain style, title, and message.

Use showToast to create and show a Toast.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| message<mark style="color:red;">*</mark> | An additional message for the Toast. Useful to show more information, e.g. an identifier of a newly created asset. | <code>string</code> |
| primaryAction<mark style="color:red;">*</mark> | The primary Action the user can take when hovering on the Toast. | <code>Alert.ActionOptions</code> |
| secondaryAction<mark style="color:red;">*</mark> | The secondary Action the user can take when hovering on the Toast. | <code>Alert.ActionOptions</code> |
| style<mark style="color:red;">*</mark> | The style of a Toast. | <code>Action.Style</code> |
| title<mark style="color:red;">*</mark> | The title of a Toast. Displayed on the top. | <code>string</code> |

#### Methods

| Name | Type                                | Description      |
| :--- | :---------------------------------- | :--------------- |
| hide | <code>() => Promise&lt;void></code> | Hides the Toast. |
| show | <code>() => Promise&lt;void></code> | Shows the Toast. |

### Toast.Options

The options to create a Toast.

#### Example

```typescript
import { showToast, Toast } from "@raycast/api";

export default async function Command() {
  const options: Toast.Options = {
    style: Toast.Style.Success,
    title: "Finished cooking",
    message: "Delicious pasta for lunch",
    primaryAction: {
      title: "Do something",
      onAction: (toast) => {
        console.log("The toast action has been triggered");
        toast.hide();
      },
    },
  };
  await showToast(options);
}
```

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The title of a Toast. Displayed on the top. | <code>string</code> |
| message | An additional message for the Toast. Useful to show more information, e.g. an identifier of a newly created asset. | <code>string</code> |
| primaryAction | The primary Action the user can take when hovering on the Toast. | <code>Alert.ActionOptions</code> |
| secondaryAction | The secondary Action the user can take when hovering on the Toast. | <code>Alert.ActionOptions</code> |
| style | The style of a Toast. | <code>Action.Style</code> |

### Toast.Style

Defines the visual style of the Toast.

Use Toast.Style.Success for displaying errors.
Use Toast.Style.Animated when your Toast should be shown until a process is completed.
You can hide it later by using Toast.hide or update the properties of an existing Toast.

#### Enumeration members

| Name     | Value                                          |
| :------- | :--------------------------------------------- |
| Animated |  |
| Success  |   |
| Failure  |   |

### Toast.ActionOptions

The options to create a Toast Action.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| onAction<mark style="color:red;">*</mark> | A callback called when the action is triggered. | <code>(toast: Toast => void</code> |
| title<mark style="color:red;">*</mark> | The title of the action. | <code>string</code> |
| shortcut | The keyboard shortcut for the action. | <code>Keyboard.Shortcut</code> |


# Keyboard

The Keyboard APIs are useful to make your actions accessible via the keyboard shortcuts. Shortcuts help users to use your command without touching the mouse.

{% hint style="info" %}

Use the Common shortcuts whenever possible to keep a consistent user experience throughout Raycast.

{% endhint %}

## Types

### Keyboard.Shortcut

A keyboard shortcut is defined by one or more modifier keys (command, control, etc.) and a single key equivalent (a character or special key).

See KeyModifier for supported values.

#### Example

```typescript
import { Action, ActionPanel, Detail, Keyboard } from "@raycast/api";

export default function Command() {
  return (
    <Detail
      markdown="Let's play some games 👾"
      actions={
        <ActionPanel title="Game controls">
          <Action title="Up" shortcut={{ modifiers: ["opt"], key: "arrowUp" }} onAction={() => console.log("Go up")} />
          <Action
            title="Down"
            shortcut={{ modifiers: ["opt"], key: "arrowDown" }}
            onAction={() => console.log("Go down")}
          />
          <Action
            title="Left"
            shortcut={{ modifiers: ["opt"], key: "arrowLeft" }}
            onAction={() => console.log("Go left")}
          />
          <Action
            title="Right"
            shortcut={{ modifiers: ["opt"], key: "arrowRight" }}
            onAction={() => console.log("Go right")}
          />
          <Action title="Open" shortcut={Keyboard.Shortcut.Common.Open} onAction={() => console.log("Open")} />
        </ActionPanel>
      }
    />
  );
}
```

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| key<mark style="color:red;">*</mark> | The key of the keyboard shortcut. | <code>Keyboard.KeyEquivalent</code> |
| modifiers<mark style="color:red;">*</mark> | The modifier keys of the keyboard shortcut. | <code>Keyboard.KeyModifier[]</code> |

If the shortcut contains some "ambiguous" modifiers (eg. `ctrl`, or `cmd`, or `windows`), you will need to specify the shortcut for both platforms:

```js
{
  macOS: { modifiers: ["cmd", "shift"], key: "c" },
  Windows: { modifiers: ["ctrl", "shift"], key: "c" },
}
```

### Keyboard.Shortcut.Common

A collection of shortcuts that are commonly used throughout Raycast. Using them should help provide a more consistent experience and preserve muscle memory.

| Name            | macOS     | Windows              |
| --------------- | --------- | -------------------- |
| Copy            | ⌘ + ⇧ + C | `ctrl` + `shift` + C |
| CopyDeeplink    | ⌘ + ⇧ + C | `ctrl` + `shift` + C |
| CopyName        | ⌘ + ⇧ + . | `ctrl` + `alt` + C   |
| CopyPath        | ⌘ + ⇧ + , | `alt` + `shift` + C  |
| Save            | ⌘ + S     | `ctrl` + S           |
| Duplicate       | ⌘ + D     | `ctrl` + `shift` + S |
| Edit            | ⌘ + E     | `ctrl` + E           |
| MoveDown        | ⌘ + ⇧ + ↓ | `ctrl` + `shift` + ↓ |
| MoveUp          | ⌘ + ⇧ + ↑ | `ctrl` + `shift` + ↑ |
| New             | ⌘ + N     | `ctrl` + N           |
| Open            | ⌘ + O     | `ctrl` + O           |
| OpenWith        | ⌘ + ⇧ + O | `ctrl` + `shift` + O |
| Pin             | ⌘ + ⇧ + P | `ctrl` + .           |
| Refresh         | ⌘ + R     | `ctrl` + R           |
| Remove          | ⌃ + X     | `ctrl` + D           |
| RemoveAll       | ⌃ + ⇧ + X | `ctrl` + `shift` + D |
| ToggleQuickLook | ⌘ + Y     | `ctrl` + Y           |

### Keyboard.KeyEquivalent

```typescript
KeyEquivalent: "a" |
  "b" |
  "c" |
  "d" |
  "e" |
  "f" |
  "g" |
  "h" |
  "i" |
  "j" |
  "k" |
  "l" |
  "m" |
  "n" |
  "o" |
  "p" |
  "q" |
  "r" |
  "s" |
  "t" |
  "u" |
  "v" |
  "w" |
  "x" |
  "y" |
  "z" |
  "0" |
  "1" |
  "2" |
  "3" |
  "4" |
  "5" |
  "6" |
  "7" |
  "8" |
  "9" |
  "." |
  "," |
  ";" |
  "=" |
  "+" |
  "-" |
  "[" |
  "]" |
  "{" |
  "}" |
  "«" |
  "»" |
  "(" |
  ")" |
  "/" |
  "\\" |
  "'" |
  "`" |
  "§" |
  "^" |
  "@" |
  "$" |
  "return" |
  "delete" |
  "deleteForward" |
  "tab" |
  "arrowUp" |
  "arrowDown" |
  "arrowLeft" |
  "arrowRight" |
  "pageUp" |
  "pageDown" |
  "home" |
  "end" |
  "space" |
  "escape" |
  "enter" |
  "backspace";
```

KeyEquivalent of a Shortcut

### Keyboard.KeyModifier

```typescript
KeyModifier: "cmd" | "ctrl" | "opt" | "shift" | "alt" | "windows";
```

Modifier of a Shortcut.

Note that `"alt"` and `"opt"` are the same key, they are just named differently on macOS and Windows.


# Menu Bar Commands

The `MenuBarExtra` component can be used to create commands which populate the [extras](https://developer.apple.com/design/human-interface-guidelines/components/system-experiences/the-menu-bar#menu-bar-commands) section of macOS' menu bar.

{% hint style="info" %}

Menubar commands aren't available on Windows.

{% endhint %}

## Getting Started

If you don't have an extension yet, follow the getting started guide and then return to this page.
Now that your extension is ready, let's open its `package.json` file and add a new entry to its `commands` array, ensuring its `mode` property is set to `menu-bar`. For this guide, let's add the following:

```JSON
{
  "name": "github-pull-requests",
  "title": "Pull Requests",
  "subtitle": "GitHub",
  "description": "See your GitHub pull requests at a glance",
  "mode": "menu-bar"
},
```

{% hint style="info" %}
Check out the command properties entry in the manifest file documentation for more detailed information on each of those properties.
{% endhint %}

Create `github-pull-requests.tsx` in your extensions `src/` folder and add the following:

```typescript
import { MenuBarExtra } from "@raycast/api";

export default function Command() {
  return (
    <MenuBarExtra icon="https://github.githubassets.com/favicons/favicon.png" tooltip="Your Pull Requests">
      <MenuBarExtra.Item title="Seen" />
      <MenuBarExtra.Item
        title="Example Seen Pull Request"
        onAction={() => {
          console.log("seen pull request clicked");
        }}
      />
      <MenuBarExtra.Item title="Unseen" />
      <MenuBarExtra.Item
        title="Example Unseen Pull Request"
        onAction={() => {
          console.log("unseen pull request clicked");
        }}
      />
    </MenuBarExtra>
  );
}
```

If your development server is running, the command should appear in your root search, and running the command should result in the `GitHub` icon appearing in your menu bar.



{% hint style="info" %}
macOS has the final say on whether a given menu bar extra is displayed. If you have a lot of items there, it is possible that the command we just ran doesn't show up. If that's the case, try to clear up some space in the menu bar, either by closing some of the items you don't need or by hiding them using [HiddenBar](https://github.com/dwarvesf/hidden), [Bartender](https://www.macbartender.com/), or similar apps.
{% endhint %}

Of course, our pull request command wouldn't be of that much use if we had to tell it to update itself every single time. To add background refresh to our command, we need to open the `package.json` file we modified earlier and add an `interval` key to the command configuration object:

```JSON
{
  "name": "github-pull-requests",
  "title": "Pull Requests",
  "subtitle": "GitHub",
  "description": "See your GitHub pull requests at a glance",
  "mode": "menu-bar",
  "interval": "5m"
}
```

Your root search should look similar to:



Running it once should activate it to:



## Lifecycle

Although `menu-bar` commands can result in items permanently showing up in the macOS menu bar, they are not long-lived processes. Instead, as with other commands, Raycast loads them into memory on demand, executes their code and then tries to unload them at the next convenient time.
There are five distinct events that can result in a `menu-bar`'s item being placed in the menu bar, so let's walk through each one.

### From the root search

Same as any other commands, `menu-bar` commands can be run directly from Raycast's root search. Eventually, they may result in a new item showing up in your menu bar (if you have enough room and if the command returns a `MenuBarExtra`), or in a previous item disappearing, if the command returns `null`. In this case, Raycast will load your command code, execute it, wait for the `MenuBarExtra`'s `isLoading` prop to switch to `false`, and unload the command.

{% hint style="danger" %}
If your command returns a `MenuBarExtra`, it _must_ either not set `isLoading` - in which case Raycast will render and immediately unload the command, or set it to `true` while it's performing an async task (such as an API call) and then set it to `false` once it's done. Same as above, Raycast will load the command code, execute it, wait for `MenuBarExtra`'s `isLoading` prop to switch to `false`, and then unload the command.
{% endhint %}

### At a set interval

If your `menu-bar` command also makes use of background refresh _and_ it has background refresh activated, Raycast will run the command at set intervals. In your command, you can use `environment.launchType` to check whether it is launched in the background or by the user.

{% hint style="info" %}
To ease testing, commands configured to run in the background have an extra action in development mode:\

{% endhint %}

### When the user clicks the command's icon / title in the menu bar

One of the bigger differences to `view` or `no-view` commands is that `menu-bar` commands have an additional entry point: when the user clicks their item in the menu bar. If the item has a menu (i.e. `MenuBarExtra` provides at least one child), Raycast will load the command code, execute it and keep it in memory while the menu is open. When the menu closes (either by the user clicking outside, or by clicking a `MenuBarExtra.Item`), the command is then unloaded.

### When Raycast is restarted

This case assumes that your command has run at least once, resulting in an item being placed in the menu bar. If that's the case, quitting and starting Raycast again should put the same item in your menu bar. However, that item will be restored from Raycast's database - _not_ by loading and executing the command.

### When a menu bar command is re-enabled in preferences

This case should work the same as when Raycast is restarted.

## Best practices

- make generous use of the Cache API in order to provide quick feedback and ensure action handlers work as expected
- make sure you set `isLoading` to false when your command finishes executing
- avoid setting long titles in `MenuBarExtra`, `MenuBarExtra.Submenu` or `MenuBarExtra.Item`
- don't put identical `MenuBarExtra.Item`s at the same level (direct children of `MenuBarExtra` or in the same `Submenu`) as their `onAction` handlers will not be executed correctly

## API Reference

### MenuBarExtra

Adds an item to the menu bar, optionally with a menu attached in case its `children` prop is non-empty.

{% hint style="info" %}
`menu-bar` commands don't always need to return a `MenuBarExtra`. Sometimes it makes sense to remove an item from the menu bar, in which case you can write your command logic to return `null` instead.
{% endhint %}

#### Example

```typescript
import { Icon, MenuBarExtra, open } from "@raycast/api";

const data = {
  archivedBookmarks: [{ name: "Google Search", url: "www.google.com" }],
  newBookmarks: [{ name: "Raycast", url: "www.raycast.com" }],
};

export default function Command() {
  return (
    <MenuBarExtra icon={Icon.Bookmark}>
      <MenuBarExtra.Section title="New">
        {data?.newBookmarks.map((bookmark) => (
          <MenuBarExtra.Item key={bookmark.url} title={bookmark.name} onAction={() => open(bookmark.url)} />
        ))}
      </MenuBarExtra.Section>
      <MenuBarExtra.Section title="Archived">
        {data?.archivedBookmarks.map((bookmark) => (
          <MenuBarExtra.Item key={bookmark.url} title={bookmark.name} onAction={() => open(bookmark.url)} />
        ))}
      </MenuBarExtra.Section>
    </MenuBarExtra>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children | `MenuBarExtra.Item`s, `MenuBarExtra.Submenu`s, `MenuBarExtra.Separator` or a mix of either. | <code>React.ReactNode</code> | - |
| icon | The icon that is displayed in the menu bar. | <code>Image.ImageLike</code> | - |
| isLoading | Indicates to Raycast that it should not unload the command, as it is still executing. If you set make use of `isLoading`, you need to make sure you set it to `false` at the end of the task you are executing (such as an API call), so Raycast can then unload the command. | <code>boolean</code> | - |
| title | The string that is displayed in the menu bar. | <code>string</code> | - |
| tooltip | A tooltip to display when the cursor hovers the item in the menu bar. | <code>string</code> | - |

### MenuBarExtra.Item

An item in the MenuBarExtra.

#### Example

{% tabs %}

{% tab title="ItemWithTitle.tsx" %}

An item that only provides a `title` prop will be rendered as disabled. Use this to create section titles.

```typescript
import { Icon, MenuBarExtra } from "@raycast/api";

export default function Command() {
  return (
    <MenuBarExtra icon={Icon.Bookmark}>
      <MenuBarExtra.Item title="Raycast.com" />
    </MenuBarExtra>
  );
}
```

{% endtab %}

{% tab title="ItemWithTitleAndIcon.tsx" %}

Similarly, an item that provides a `title` and an `icon` prop will also be rendered as disabled.

```typescript
import { Icon, MenuBarExtra } from "@raycast/api";

export default function Command() {
  return (
    <MenuBarExtra icon={Icon.Bookmark}>
      <MenuBarExtra.Item icon="raycast.png" title="Raycast.com" />
    </MenuBarExtra>
  );
}
```

{% endtab %}

{% tab title="ItemWithAction.tsx" %}

An item that provides an `onAction` prop alongside `title` (and optionally `icon`) will _not_ be rendered as disabled. When users click this item in the menu bar, the action handler will be executed.

```typescript
import { Icon, MenuBarExtra, open } from "@raycast/api";

export default function Command() {
  return (
    <MenuBarExtra icon={Icon.Bookmark}>
      <MenuBarExtra.Item icon="raycast.png" title="Raycast.com" onAction={() => open("https://raycast.com")} />
    </MenuBarExtra>
  );
}
```

{% endtab %}

{% tab title="ItemWithAlternate.tsx" %}

If an item provides another `MenuBarEtra.Item` via its `alternate`, prop, the second item will be shown then the user presses the ⌥ (opt) key. There are a few limitation:

1. The `alternate` item may not have a custom shortcut. Instead, it will inherit its parent's shortcut, with the addition of ⌥ (opt) as a modifier.
2. The `alternate` item may not also specify an alternate.
3. A parent item that provides an `alternate` may not use ⌥ (opt) as a modifier.

```typescript
import { Icon, MenuBarExtra, open } from "@raycast/api";

export default function Command() {
  return (
    <MenuBarExtra icon={Icon.Bookmark}>
      <MenuBarExtra.Item
        icon="raycast.png"
        title="Open Raycast Homepage"
        shortcut={{ key: "r", modifiers: ["cmd"] }}
        onAction={() => open("https://raycast.com")}
        alternate={
          <MenuBarExtra.Item
            icon="raycast.png"
            title="Open Raycast Store"
            onAction={() => open("https://raycast.com/store")}
          />
        }
      />
    </MenuBarExtra>
  );
}
```

{% endtab %}

{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The main title displayed for this item. | <code>string</code> | - |
| alternate | A MenuBarExtra.Item to be displayed when a user presses the ⌥ (opt) key. | <code>ReactElement&lt;MenuBarExtra.Item.Props></code> | - |
| icon | An optional icon for this item. | <code>Image.ImageLike</code> | - |
| onAction | An action handler called when the user clicks the item. | <code>(event: MenuBarExtra.ActionEvent => void</code> | - |
| shortcut | A shortcut used to invoke this item when its parent menu is open. | <code>Keyboard.Shortcut</code> | - |
| subtitle | The subtitle displayed for this item. | <code>string</code> | - |
| tooltip | A tooltip to display when the cursor hovers the item. | <code>string</code> | - |

### MenuBarExtra.Submenu

`MenuBarExtra.Submenu`s reveal their items when people interact with them. They're a good way to group items that naturally belong together, but keep in mind that submenus add complexity to your interface - so use them sparingly!

#### Example

{% tabs %}

{% tab title="Bookmarks.tsx" %}

```typescript
import { Icon, MenuBarExtra, open } from "@raycast/api";

export default function Command() {
  return (
    <MenuBarExtra icon={Icon.Bookmark}>
      <MenuBarExtra.Item icon="raycast.png" title="Raycast.com" onAction={() => open("https://raycast.com")} />
      <MenuBarExtra.Submenu icon="github.png" title="GitHub">
        <MenuBarExtra.Item title="Pull Requests" onAction={() => open("https://github.com/pulls")} />
        <MenuBarExtra.Item title="Issues" onAction={() => open("https://github.com/issues")} />
      </MenuBarExtra.Submenu>
      <MenuBarExtra.Submenu title="Disabled"></MenuBarExtra.Submenu>
    </MenuBarExtra>
  );
}
```

{% endtab %}

{% tab title="DisabledSubmenu.tsx" %}

Submenus with no children will show up as disabled.

```typescript
import { Icon, MenuBarExtra, open } from "@raycast/api";

export default function Command() {
  return (
    <MenuBarExtra icon={Icon.Bookmark}>
      <MenuBarExtra.Submenu title="Disabled"></MenuBarExtra.Submenu>
    </MenuBarExtra>
  );
}
```

{% endtab %}

{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The main title displayed for this submenu. | <code>string</code> | - |
| children | `MenuBarExtra.Item`s, `MenuBarExtra.Submenu`s, `MenuBarExtra.Separator` or a mix of either. | <code>React.ReactNode</code> | - |
| icon | An optional icon for this submenu. | <code>Image.ImageLike</code> | - |

### MenuBarExtra.Section

An item to group related menu items. It has an optional title and a separator is added automatically between sections.

#### Example

```typescript
import { Icon, MenuBarExtra, open } from "@raycast/api";

const data = {
  archivedBookmarks: [{ name: "Google Search", url: "www.google.com" }],
  newBookmarks: [{ name: "Raycast", url: "www.raycast.com" }],
};

export default function Command() {
  return (
    <MenuBarExtra icon={Icon.Bookmark}>
      <MenuBarExtra.Section title="New">
        {data?.newBookmarks.map((bookmark) => (
          <MenuBarExtra.Item key={bookmark.url} title={bookmark.name} onAction={() => open(bookmark.url)} />
        ))}
      </MenuBarExtra.Section>
      <MenuBarExtra.Section title="Archived">
        {data?.archivedBookmarks.map((bookmark) => (
          <MenuBarExtra.Item key={bookmark.url} title={bookmark.name} onAction={() => open(bookmark.url)} />
        ))}
      </MenuBarExtra.Section>
    </MenuBarExtra>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children | The item elements of the section. | <code>React.ReactNode</code> | - |
| title | Title displayed above the section | <code>string</code> | - |

## Types

### MenuBarExtra.ActionEvent

An interface describing Action events in callbacks.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| type<mark style="color:red;">*</mark> | A type of the action event    * `left-click` is a left mouse click on the MenuBarExtra.Item or a Keyboard.Shortcut  * `right-click` is a right mouse click on the MenuBarExtra.Item | <code>"left-click"</code> or <code>"right-click"</code> |

#### Example

```typescript
import { MenuBarExtra } from "@raycast/api";

export default function Command() {
  return (
    <MenuBarExtra>
      <MenuBarExtra.Item
        title="Log Action Event Type"
        onAction={(event: MenuBarExtra.ActionEvent) => console.log("Action Event Type", event.type)}
      />
    </MenuBarExtra>
  );
}
```


# OAuth

## Prerequisites

A Raycast extension can use OAuth for authorizing access to a provider's resources on the user's behalf. Since Raycast is a desktop app and the extensions are considered "public", we only support the [PKCE flow](https://datatracker.ietf.org/doc/html/rfc7636) (Proof Key for Code Exchange, pronounced “pixy”). This flow is the official recommendation for native clients that cannot keep a client secret. With PKCE, the client dynamically creates a secret and uses the secret again during code exchange, ensuring that only the client that performed the initial request can exchange the code for the access token (”proof of possession”).

{% hint style="info" %}
Providers such as Google, Twitter, GitLab, Spotify, Zoom, Asana or Dropbox are all PKCE-ready.

However, if your provider doesn't support PKCE, you can use our [PKCE proxy](https://oauth.raycast.com). It allows extensions to securely use an OAuth flow without exposing any secret.
{% endhint %}

## OAuth Flow



The OAuth flow from an extension looks like this:

1. The extension initiates the OAuth flow and starts authorization
2. Raycast shows the OAuth overlay ("Connect to provider…")
3. The user opens the provider's consent page in the web browser
4. After the user consent, the provider redirects back to Raycast
5. Raycast opens the extension where authorization is completed

When the flow is complete, the extension has received an access token from the provider and can perform API calls.
The API provides functions for securely storing and retrieving token sets, so that an extension can check whether the user is already logged in and whether an expired access token needs to be refreshed. Raycast also automatically shows a logout preference.



## OAuth App

You first need to register a new OAuth app with your provider. This is usually done in the provider's developer portal. After registering, you will receive a client ID. You also need to configure a redirect URI, see the next section.

Note: Make sure to choose an app type that supports PKCE. Some providers still show you a client secret, which you don't need and should _not_ hardcode in the extension, or support PKCE only for certain types such as "desktop", "native" or "mobile" app types.

## Authorizing

An extension can initiate the OAuth flow and authorize by using the methods on OAuth.PKCEClient.

You can create a new client and configure it with a provider name, icon and description that will be shown in the OAuth overlay. You can also choose between different redirect methods; depending on which method you choose, you need to configure this value as redirect URI in your provider's registered OAuth app. (See the OAuth.RedirectMethod.

```typescript
import { OAuth } from "@raycast/api";

const client = new OAuth.PKCEClient({
  redirectMethod: OAuth.RedirectMethod.Web,
  providerName: "Twitter",
  providerIcon: "twitter-logo.png",
  description: "Connect your Twitter account…",
});
```

Next you create an authorization request with the authorization endpoint, client ID, and scope values. You receive all values from your provider's docs and when you register a new OAuth app.

The returned AuthorizationRequest if you need to.

```typescript
const authRequest = await client.authorizationRequest({
  endpoint: "https://twitter.com/i/oauth2/authorize",
  clientId: "YourClientId",
  scope: "tweet.read users.read follows.read",
});
```

To get the authorization code needed for the token exchange, you call authorize with the request from the previous step.
This call shows the Raycast OAuth overlay and provides the user with an option to open the consent page in the web browser.
The authorize promise is resolved after the redirect back to Raycast and into the extension:

```typescript
const { authorizationCode } = await client.authorize(authRequest);
```

{% hint style="info" %}
When in development mode, make sure not to trigger auto-reloading (e.g. by saving a file) while you're testing an active OAuth authorization and redirect. This would cause an OAuth state mismatch when you're redirected back into the extension since the client would be reinitialized on reload.
{% endhint %}

Now that you have received the authorization code, you can exchange this code for an access token using your provider's token endpoint. This token exchange (and the following API calls) can be done with your preferred Node HTTP client library. Example using `node-fetch`:

```typescript
async function fetchTokens(authRequest: OAuth.AuthorizationRequest, authCode: string): Promise<OAuth.TokenResponse> {
  const params = new URLSearchParams();
  params.append("client_id", "YourClientId");
  params.append("code", authCode);
  params.append("code_verifier", authRequest.codeVerifier);
  params.append("grant_type", "authorization_code");
  params.append("redirect_uri", authRequest.redirectURI);

  const response = await fetch("https://api.twitter.com/2/oauth2/token", {
    method: "POST",
    body: params,
  });
  if (!response.ok) {
    console.error("fetch tokens error:", await response.text());
    throw new Error(response.statusText);
  }
  return (await response.json()) as OAuth.TokenResponse;
}
```

## Token Storage

The PKCE client exposes methods for storing, retrieving and deleting token sets. A TokenSet:

```typescript
await client.setTokens(tokenResponse);
```

Once the token set is stored, Raycast will automatically show a logout preference for the extension. When the user logs out, the token set gets removed.

The TokenSet also enables you to check whether the user is logged in before starting the authorization flow:

```typescript
const tokenSet = await client.getTokens();
```

## Token Refresh

Since access tokens usually expire, an extension should provide a way to refresh the access token, otherwise users would be logged out or see errors.
Some providers require you to add an offline scope so that you get a refresh token. (Twitter, for example, needs the scope `offline.access` or it only returns an access token.)
A basic refresh flow could look like this:

```typescript
const tokenSet = await client.getTokens();
if (tokenSet?.accessToken) {
  if (tokenSet.refreshToken && tokenSet.isExpired()) {
    await client.setTokens(await refreshTokens(tokenSet.refreshToken));
  }
  return;
}
// authorize...
```

This code would run before starting the authorization flow. It checks the presence of a token set to see whether the user is logged in and then checks whether there is a refresh token and the token set is expired (through the convenience method `isExpired()` on the TokenSet. If it is expired, the token is refreshed and updated in the token set. Example using `node-fetch`:

```typescript
async function refreshTokens(refreshToken: string): Promise<OAuth.TokenResponse> {
  const params = new URLSearchParams();
  params.append("client_id", "YourClientId");
  params.append("refresh_token", refreshToken);
  params.append("grant_type", "refresh_token");

  const response = await fetch("https://api.twitter.com/2/oauth2/token", {
    method: "POST",
    body: params,
  });
  if (!response.ok) {
    console.error("refresh tokens error:", await response.text());
    throw new Error(response.statusText);
  }

  const tokenResponse = (await response.json()) as OAuth.TokenResponse;
  tokenResponse.refresh_token = tokenResponse.refresh_token ?? refreshToken;
  return tokenResponse;
}
```

## Examples

We've provided [OAuth example integrations for Google, Twitter, and Dropbox](https://github.com/raycast/extensions/tree/main/examples/api-examples) that demonstrate the entire flow shown above.

## API Reference

### OAuth.PKCEClient

Use OAuth.PKCEClient.Options to configure what's shown on the OAuth overlay.

#### Signature

```typescript
constructor(options: OAuth.PKCEClient.Options): OAuth.PKCEClient
```

#### Example

```typescript
import { OAuth } from "@raycast/api";

const client = new OAuth.PKCEClient({
  redirectMethod: OAuth.RedirectMethod.Web,
  providerName: "Twitter",
  providerIcon: "twitter-logo.png",
  description: "Connect your Twitter account…",
});
```

#### Methods

| Method                                                                                                                                           |
| :----------------------------------------------------------------------------------------------------------------------------------------------- |
| <code>authorizationRequest(options: AuthorizationRequestOptions): Promise<AuthorizationRequest></code> |
| <code>authorize(options: AuthorizationRequest \| AuthorizationOptions): Promise<AuthorizationResponse></code>     |
| <code>setTokens(options: TokenSetOptions \| TokenResponse): Promise<void></code>                                  |
| <code>getTokens(): Promise<TokenSet \| undefined></code>                                                          |
| <code>removeTokens(): Promise<void></code>                                                                     |

### OAuth.PKCEClient#authorizationRequest

Creates an authorization request for the provided authorization endpoint, client ID, and scopes. You need to first create the authorization request before calling authorize.

The generated code challenge for the PKCE request uses the S256 method.

#### Signature

```typescript
authorizationRequest(options: AuthorizationRequestOptions): Promise<AuthorizationRequest>;
```

#### Example

```typescript
const authRequest = await client.authorizationRequest({
  endpoint: "https://twitter.com/i/oauth2/authorize",
  clientId: "YourClientId",
  scope: "tweet.read users.read follows.read",
});
```

#### Parameters

| Name                                      | Type                                                                           | Description                                           |
| :---------------------------------------- | :----------------------------------------------------------------------------- | :---------------------------------------------------- |
| options<mark style="color:red;">\*</mark> | <code>AuthorizationRequestOptions</code> | The options used to create the authorization request. |

#### Return

A promise for an AuthorizationRequest.

### OAuth.PKCEClient#authorize

Starts the authorization and shows the OAuth overlay in Raycast. As parameter you can either directly use the returned request from authorizationRequest. Eventually the URL will be used to open the authorization page of the provider in the web browser.

#### Signature

```typescript
authorize(options: AuthorizationRequest | AuthorizationOptions): Promise<AuthorizationResponse>;
```

#### Example

```typescript
const { authorizationCode } = await client.authorize(authRequest);
```

#### Parameters

| Name                                      | Type                                                                                                                    | Description                    |
| :---------------------------------------- | :---------------------------------------------------------------------------------------------------------------------- | :----------------------------- |
| options<mark style="color:red;">\*</mark> | <code>AuthorizationRequest</code> | The options used to authorize. |

#### Return

A promise for an AuthorizationResponse, which contains the authorization code needed for the token exchange. The promise is resolved when the user was redirected back from the provider's authorization page to the Raycast extension.

### OAuth.PKCEClient#setTokens

Securely stores a TokenSet.
At a minimum, you need to set the `accessToken`, and typically you also set `refreshToken` and `isExpired`.

Raycast automatically shows a logout preference for the extension when a token set was saved.

If you want to make use of the convenience `isExpired()` method, the property `expiresIn` must be configured.

#### Signature

```typescript
setTokens(options: TokenSetOptions | TokenResponse): Promise<void>;
```

#### Example

```typescript
await client.setTokens(tokenResponse);
```

#### Parameters

| Name                                      | Type                                                                                            | Description                              |
| :---------------------------------------- | :---------------------------------------------------------------------------------------------- | :--------------------------------------- |
| options<mark style="color:red;">\*</mark> | <code>TokenSetOptions</code> | The options used to store the token set. |

#### Return

A promise that resolves when the token set has been stored.

### OAuth.PKCEClient#getTokens

Retrieves the stored TokenSet for the client. You can use this to initially check whether the authorization flow should be initiated or the user is already logged in and you might have to refresh the access token.

#### Signature

```typescript
getTokens(): Promise<TokenSet | undefined>;
```

#### Example

```typescript
const tokenSet = await client.getTokens();
```

#### Return

A promise that resolves when the token set has been retrieved.

### OAuth.PKCEClient#removeTokens

Removes the stored TokenSet for the client.
Raycast automatically shows a logout preference that removes the token set. Use this method only if you need to provide an additional logout option in your extension or you want to remove the token set because of a migration.

#### Signature

```typescript
removeTokens(): Promise<void>;
```

#### Example

```typescript
await client.removeTokens();
```

#### Return

A promise that resolves when the token set has been removed.

## Types

### OAuth.PKCEClient.Options

The options for creating a new PKCEClient.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| providerName<mark style="color:red;">*</mark> | The name of the provider, displayed in the OAuth overlay. | <code>string</code> |
| redirectMethod<mark style="color:red;">*</mark> | The redirect method for the OAuth flow.  Make sure to set this to the correct method for the provider, see OAuth.RedirectMethod for more information. | <code>OAuth.RedirectMethod</code> |
| description | An optional description, shown in the OAuth overlay.  You can use this to customize the message for the end user, for example for handling scope changes or other migrations.  Raycast shows a default message if this is not configured. | <code>string</code> |
| providerIcon | An icon displayed in the OAuth overlay.  Make sure to provide at least a size of 64x64 pixels. | <code>Image.ImageLike</code> |
| providerId | An optional ID for associating the client with a provider.  Only set this if you use multiple different clients in your extension. | <code>string</code> |

### OAuth.RedirectMethod

Defines the supported redirect methods for the OAuth flow. You can choose between web and app-scheme redirect methods, depending on what the provider requires when setting up the OAuth app. For examples on what redirect URI you need to configure, see the docs for each method.

#### Enumeration members

| Name   | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| :----- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Web    | Use this type for a redirect back to the Raycast website, which will then open the extension. In the OAuth app, configure `https://raycast.com/redirect?packageName=Extension`<br>(This is a static redirect URL for all extensions.)<br>If the provider does not accept query parameters in redirect URLs, you can alternatively use `https://raycast.com/redirect/extension` and then customize the AuthorizationRequest via its `extraParameters` property. For example add: `extraParameters: { "redirect_uri": "https://raycast.com/redirect/extension" }` |
| App    | Use this type for an app-scheme based redirect that directly opens Raycast. In the OAuth app, configure `raycast://oauth?package_name=Extension`                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| AppURI | Use this type for a URI-style app scheme that directly opens Raycast. In the OAuth app, configure `com.raycast:/oauth?package_name=Extension`<br>(Note the single slash – Google, for example, would require this flavor for an OAuth app where the Bundle ID is `com.raycast`)                                                                                                                                                                                                                                                                                                                |

### OAuth.AuthorizationRequestOptions

The options for an authorization request via authorizationRequest.

| Property | Description | Type |
| :--- | :--- | :--- |
| clientId<mark style="color:red;">*</mark> | The client ID of the configured OAuth app. | <code>string</code> |
| endpoint<mark style="color:red;">*</mark> | The URL to the authorization endpoint for the OAuth provider. | <code>string</code> |
| scope<mark style="color:red;">*</mark> | A space-delimited list of scopes for identifying the resources to access on the user's behalf.  The scopes are typically shown to the user on the provider's consent screen in the browser.  Note that some providers require the same scopes be configured in the registered OAuth app. | <code>string</code> |
| extraParameters | Optional additional parameters for the authorization request.  Note that some providers require additional parameters, for example to obtain long-lived refresh tokens. | <code>{ [string]: string }</code> |

### OAuth.AuthorizationRequestURLParams

Values of AuthorizationRequest.
The PKCE client automatically generates the values for you and returns them for authorizationRequest

| Property | Description | Type |
| :--- | :--- | :--- |
| codeChallenge<mark style="color:red;">*</mark> | The PKCE `code_challenge` value. | <code>string</code> |
| codeVerifier<mark style="color:red;">*</mark> | The PKCE `code_verifier` value. | <code>string</code> |
| redirectURI<mark style="color:red;">*</mark> | The OAuth `redirect_uri` value. | <code>string</code> |
| state<mark style="color:red;">*</mark> | The OAuth `state` value. | <code>string</code> |

### OAuth.AuthorizationRequest

The request returned by authorizationRequest.
Can be used as direct input to authorize.

| Property | Description | Type |
| :--- | :--- | :--- |
| codeChallenge<mark style="color:red;">*</mark> | The PKCE `code_challenge` value. | <code>string</code> |
| codeVerifier<mark style="color:red;">*</mark> | The PKCE `code_verifier` value. | <code>string</code> |
| redirectURI<mark style="color:red;">*</mark> | The OAuth `redirect_uri` value. | <code>string</code> |
| state<mark style="color:red;">*</mark> | The OAuth `state` value. | <code>string</code> |
| toURL<mark style="color:red;">*</mark> |  | <code>() => string</code> |

#### Methods

| Name    | Type                      | Description                            |
| :------ | :------------------------ | :------------------------------------- |
| toURL() | <code>() => string</code> | Constructs the full authorization URL. |

### OAuth.AuthorizationOptions

Options for customizing authorize.
You can use values from AuthorizationRequest to build your own URL.

| Property | Description | Type |
| :--- | :--- | :--- |
| url<mark style="color:red;">*</mark> | The full authorization URL. | <code>string</code> |

### OAuth.AuthorizationResponse

The response returned by authorize, containing the authorization code after the provider redirect. You can then exchange the authorization code for an access token using the provider's token endpoint.

| Property | Description | Type |
| :--- | :--- | :--- |
| authorizationCode<mark style="color:red;">*</mark> | The authorization code from the OAuth provider. | <code>string</code> |

### OAuth.TokenSet

Describes the TokenSet created from an OAuth provider's token response. The `accessToken` is the only required parameter but typically OAuth providers also return a refresh token, an expires value, and the scope.
Securely store a token set via setTokens.

| Property | Description | Type |
| :--- | :--- | :--- |
| accessToken<mark style="color:red;">*</mark> | The access token returned by an OAuth token request. | <code>string</code> |
| updatedAt<mark style="color:red;">*</mark> | The date when the token set was stored via OAuth.PKCEClient.setTokens. | <code>[Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)</code> |
| isExpired<mark style="color:red;">*</mark> |  | <code>() => boolean</code> |
| expiresIn | An optional expires value (in seconds) returned by an OAuth token request. | <code>number</code> |
| idToken | An optional id token returned by an identity request (e.g. /me, Open ID Connect). | <code>string</code> |
| refreshToken | An optional refresh token returned by an OAuth token request. | <code>string</code> |
| scope | The optional space-delimited list of scopes returned by an OAuth token request.  You can use this to compare the currently stored access scopes against new access scopes the extension might require in a future version,  and then ask the user to re-authorize with new scopes. | <code>string</code> |

#### Methods

| Name        | Type                       | Description                                                                                                                                                                                                                                          |
| :---------- | :------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| isExpired() | <code>() => boolean</code> | A convenience method for checking whether the access token has expired. The method factors in some seconds of "buffer", so it returns true a couple of seconds before the actual expiration time. This requires the `expiresIn` parameter to be set. |

### OAuth.TokenSetOptions

Options for a TokenSet.

| Property | Description | Type |
| :--- | :--- | :--- |
| accessToken<mark style="color:red;">*</mark> | The access token returned by an OAuth token request. | <code>string</code> |
| expiresIn | An optional expires value (in seconds) returned by an OAuth token request. | <code>number</code> |
| idToken | An optional id token returned by an identity request (e.g. /me, Open ID Connect). | <code>string</code> |
| refreshToken | An optional refresh token returned by an OAuth token request. | <code>string</code> |
| scope | The optional scope value returned by an OAuth token request. | <code>string</code> |

### OAuth.TokenResponse

Defines the standard JSON response for an OAuth token request.
The response can be directly used to store a TokenSet.

| Property | Description | Type |
| :--- | :--- | :--- |
| access_token<mark style="color:red;">*</mark> | The `access_token` value returned by an OAuth token request. | <code>string</code> |
| expires_in | An optional `expires_in` value (in seconds) returned by an OAuth token request. | <code>number</code> |
| id_token | An optional `id_token` value returned by an identity request (e.g. /me, Open ID Connect). | <code>string</code> |
| refresh_token | An optional `refresh_token` value returned by an OAuth token request. | <code>string</code> |
| scope | The optional `scope` value returned by an OAuth token request. | <code>string</code> |


# Preferences

Use the Preferences API to make your extension configurable.

Preferences are configured in the manifest per command or shared in the context of an extension.

Required preferences need to be set by the user before a command opens. They are a great way to make sure that the user of your extension has everything set up properly.

## API Reference

### getPreferenceValues

A function to access the preference values that have been passed to the command.

Each preference name is mapped to its value, and the defined default values are used as fallback values.

#### Signature

```typescript
function getPreferenceValues(): { [preferenceName: string]: any };
```

{% hint style="info" %}
You don't need to manually set preference types as an interface since it is autogenerated in `raycast-env.d.ts` when you run the extension.
{% endhint %}

#### Example

```typescript
import { getPreferenceValues } from "@raycast/api";

export default async function Command() {
  const preferences = getPreferenceValues<Preferences>();
  console.log(preferences);
}
```

#### Return

An object with the preference names as property key and the typed value as property value.

Depending on the type of the preference, the type of its value will be different.

| Preference type        | Value type                                             |
| :--------------------- | :----------------------------------------------------- |
| <code>textfield</code> | <code>string</code>                                    |
| <code>password</code>  | <code>string</code>                                    |
| <code>checkbox</code>  | <code>boolean</code>                                   |
| <code>dropdown</code>  | <code>string</code>                                    |
| <code>appPicker</code> | <code>Application</code> |
| <code>file</code>      | <code>string</code>                                    |
| <code>directory</code> | <code>string</code>                                    |

### openExtensionPreferences

Opens the extension's preferences screen.

#### Signature

```typescript
export declare function openExtensionPreferences(): Promise<void>;
```

#### Example

```typescript
import { ActionPanel, Action, Detail, openExtensionPreferences } from "@raycast/api";

export default function Command() {
  const markdown = "API key incorrect. Please update it in extension preferences and try again.";

  return (
    <Detail
      markdown={markdown}
      actions={
        <ActionPanel>
          <Action title="Open Extension Preferences" onAction={openExtensionPreferences} />
        </ActionPanel>
      }
    />
  );
}
```

#### Return

A Promise that resolves when the extensions preferences screen is opened.

### openCommandPreferences

Opens the command's preferences screen.

#### Signature

```typescript
export declare function openCommandPreferences(): Promise<void>;
```

#### Example

```typescript
import { ActionPanel, Action, Detail, openCommandPreferences } from "@raycast/api";

export default function Command() {
  const markdown = "API key incorrect. Please update it in command preferences and try again.";

  return (
    <Detail
      markdown={markdown}
      actions={
        <ActionPanel>
          <Action title="Open Command Preferences" onAction={openCommandPreferences} />
        </ActionPanel>
      }
    />
  );
}
```

#### Return

A Promise that resolves when the command's preferences screen is opened.

## Types

### Preferences

A command receives the values of its preferences via the `getPreferenceValues` function. It is an object with the preferences' `name` as keys and their values as the property's values.

Depending on the type of the preference, the type of its value will be different.

| Preference type        | Value type                                             |
| :--------------------- | :----------------------------------------------------- |
| <code>textfield</code> | <code>string</code>                                    |
| <code>password</code>  | <code>string</code>                                    |
| <code>checkbox</code>  | <code>boolean</code>                                   |
| <code>dropdown</code>  | <code>string</code>                                    |
| <code>appPicker</code> | <code>Application</code> |
| <code>file</code>      | <code>string</code>                                    |
| <code>directory</code> | <code>string</code>                                    |

{% hint style="info" %}
Raycast provides a global TypeScript namespace called `Preferences` which contains the types of the preferences of all the commands of the extension.

For example, if a command named `show-todos` has some preferences, its `getPreferenceValues`'s return type can be specified with `getPreferenceValues<Preferences.ShowTodos>()`. This will make sure that the types used in the command stay in sync with the manifest.
{% endhint %}


# Storage

The storage APIs can be used to store data in Raycast's local encrypted database.

All commands in an extension have shared access to the stored data. Extensions can _not_ access the storage of other extensions.

Values can be managed through functions such as `LocalStorage.getItem`. A typical use case is storing user-related data, for example entered todos.

{% hint style="info" %}
The API is not meant to store large amounts of data. For this, use [Node's built-in APIs to write files](https://nodejs.org/en/learn/manipulating-files/writing-files-with-nodejs), e.g. to the extension's support directory.
{% endhint %}

## API Reference

### LocalStorage.getItem

Retrieve the stored value for the given key.

#### Signature

```typescript
async function getItem(key: string): Promise<Value | undefined>;
```

#### Example

```typescript
import { LocalStorage } from "@raycast/api";

export default async function Command() {
  await LocalStorage.setItem("favorite-fruit", "apple");
  const item = await LocalStorage.getItem<string>("favorite-fruit");
  console.log(item);
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| key<mark style="color:red;">*</mark> | The key you want to retrieve the value of. | <code>string</code> |

#### Return

A Promise that resolves with the stored value for the given key. If the key does not exist, `undefined` is returned.

### LocalStorage.setItem

Stores a value for the given key.

#### Signature

```typescript
async function setItem(key: string, value: Value): Promise<void>;
```

#### Example

```typescript
import { LocalStorage } from "@raycast/api";

export default async function Command() {
  await LocalStorage.setItem("favorite-fruit", "apple");
  const item = await LocalStorage.getItem<string>("favorite-fruit");
  console.log(item);
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| key<mark style="color:red;">*</mark> | The key you want to create or update the value of. | <code>string</code> |
| value<mark style="color:red;">*</mark> | The value you want to create or update for the given key. | <code>LocalStorage.Value</code> |

#### Return

A Promise that resolves when the value is stored.

### LocalStorage.removeItem

Removes the stored value for the given key.

#### Signature

```typescript
async function removeItem(key: string): Promise<void>;
```

#### Example

```typescript
import { LocalStorage } from "@raycast/api";

export default async function Command() {
  await LocalStorage.setItem("favorite-fruit", "apple");
  console.log(await LocalStorage.getItem<string>("favorite-fruit"));
  await LocalStorage.removeItem("favorite-fruit");
  console.log(await LocalStorage.getItem<string>("favorite-fruit"));
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| key<mark style="color:red;">*</mark> | The key you want to remove the value of. | <code>string</code> |

#### Return

A Promise that resolves when the value is removed.

### LocalStorage.allItems

Retrieve all stored values in the local storage of an extension.

#### Signature

```typescript
async function allItems(): Promise<Values>;
```

#### Example

```typescript
import { LocalStorage } from "@raycast/api";

interface Values {
  todo: string;
  priority: number;
}

export default async function Command() {
  const items = await LocalStorage.allItems<Values>();
  console.log(`Local storage item count: ${Object.entries(items).length}`);
}
```

#### Return

A Promise that resolves with an object containing all Values.

### LocalStorage.clear

Removes all stored values of an extension.

#### Signature

```typescript
async function clear(): Promise<void>;
```

#### Example

```typescript
import { LocalStorage } from "@raycast/api";

export default async function Command() {
  await LocalStorage.clear();
}
```

#### Return

A Promise that resolves when all values are removed.

## Types

### LocalStorage.Values

Values of local storage items.

For type-safe values, you can define your own interface. Use the keys of the local storage items as the property names.

#### Properties

| Name          | Type             | Description                             |
| :------------ | :--------------- | :-------------------------------------- |
| [key: string] | <code>any</code> | The local storage value of a given key. |

### LocalStorage.Value

```typescript
Value: string | number | boolean;
```

Supported storage value types.

#### Example

```typescript
import { LocalStorage } from "@raycast/api";

export default async function Command() {
  // String
  await LocalStorage.setItem("favorite-fruit", "cherry");

  // Number
  await LocalStorage.setItem("fruit-basket-count", 3);

  // Boolean
  await LocalStorage.setItem("fruit-eaten-today", true);
}
```


# Tool

Tools are a type of entry point for an extension. As opposed to a command, they don’t show up in the root search and the user can’t directly interact with them. Instead, they are functionalities that the AI can use to interact with an extension.

## Types

### Tool.Confirmation

A tool confirmation is used to ask the user to validate the side-effects of the tool.

{% hint style="info" %}
The tool confirmation is executed _before_ the actual tool is executed and receives the same input as the tool.
A confirmation returns an optional object that describes what the tool is about to do. It is important to be as clear as possible.

If the user confirms the action, the tool will be executed afterwards. If the user cancels the action, the tool will not be executed.
{% endhint %}

```ts
type Confirmation<T> = (input: T) => Promise<
  | undefined
  | {
      /**
       * Defines the visual style of the Confirmation.
       *
       * @remarks
       * Use {@link Action.Style.Regular} to display a regular action.
       * Use {@link Action.Style.Destructive} when your action performs something irreversible like deleting data.
       *
       * @defaultValue {@link Action.Style.Regular}
       */
      style?: Action.Style;
      /**
       * Some name/value pairs that represents the side-effects of the tool.
       *
       * @remarks
       * Use it to provide more context about the tool to the user. For example, list the files that will be deleted.
       *
       * A name/value pair with an optional value won't be displayed if the value is `undefined`.
       */
      info?: {
        name: string;
        value?: string;
      }[];
      /**
       * A string that represents the side-effects of the tool.
       *
       * @remarks
       * Often times this is a question that the user needs to answer. For Example, "Are you sure you want to delete the file?"
       */
      message?: string;
      /**
       * An image that visually represents the side-effects of the tool.
       *
       * @remarks
       * Use an image that is relevant to the side-effects of the tool. For example, a screenshot of the files that will be deleted.
       */
      image?: Image.URL | FileIcon;
    }
>;
```

You can return `undefined` to skip the confirmation. This is useful for tools that conditionally perform destructive actions.
F.e. when moving a file, you don't need to confirm the action if the file doesn't overwrite another file.

#### Example

```typescript
import { Tool } from "@raycast/api";

type Input = {
  /**
   * The first name of the user to greet
   */
  name: string;
};

export const confirmation: Tool.Confirmation<Input> = (input) => {
  return {
    message: `Are you sure you want to greet ${input.name}?`,
  };
};
```


# User Interface

Raycast uses React for its user interface declaration and renders the supported elements to our native UI. The API comes with a set of UI components that you can use to build your extensions. Think of it as a design system. The high-level components are the following:

- List to show multiple similar items, f.e. a list of your open todos.
- Grid similar to a List but with more legroom to show an image for each item, f.e. a collection of icons.
- Detail to present more information, f.e. the details of a GitHub pull request.
- Form to create new content, f.e. filing a bug report.

Each component can provide interaction via an ActionPanel. Shortcuts allow users to use Raycast without using their mouse.

## Rendering

To render a user interface, you need to do the following:

- Set the `mode` to `view` in the `package.json` manifest file
- Export a React component from your command entry file

As a general rule of thumb, you should render something as quickly as possible. This guarantees that your command feels responsive. If you don't have data available to show, you can set the `isLoading` prop to `true` on top-level components such as `<Detail>`. It shows a loading indicator at the top of Raycast.

Here is an example that shows a loading indicator for 2 seconds after the command got launched:

```typescript
import { List } from "@raycast/api";
import { useEffect, useState } from "react";

export default function Command() {
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setTimeout(() => setIsLoading(false), 2000);
  }, []);

  return <List isLoading={isLoading}>{/* Render your data */}</List>;
}
```


# Action Panel



## API Reference

### ActionPanel

Exposes a list of actions that can be performed by the user.

Often items are context-aware, e.g., based on the selected list item. Actions can be grouped into semantic
sections and can have keyboard shortcuts assigned.

The first and second action become the primary and secondary action. They automatically get the default keyboard shortcuts assigned.
In List it's `⌘` `↵` for the primary and `⌘` `⇧` `↵` for the secondary.
Keep in mind that while you can specify an alternative shortcut for the primary and secondary actions, it won't be displayed in the Action Panel.

#### Example

```typescript
import { ActionPanel, Action, List } from "@raycast/api";

export default function Command() {
  return (
    <List navigationTitle="Open Pull Requests">
      <List.Item
        title="Docs: Update API Reference"
        subtitle="#1"
        actions={
          <ActionPanel title="#1 in raycast/extensions">
            <Action.OpenInBrowser url="https://github.com/raycast/extensions/pull/1" />
            <Action.CopyToClipboard
              title="Copy Pull Request URL"
              content="https://github.com/raycast/extensions/pull/1"
            />
          </ActionPanel>
        }
      />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children | Sections or Actions. If Action elements are specified, a default section is automatically created. | <code>ActionPanel.Children</code> | - |
| title | The title displayed at the top of the panel | <code>string</code> | - |

### ActionPanel.Section

A group of visually separated items.

Use sections when the ActionPanel contains a lot of actions to help guide the user to related actions.
For example, create a section for all copy actions.

#### Example

```typescript
import { ActionPanel, Action, List } from "@raycast/api";

export default function Command() {
  return (
    <List navigationTitle="Open Pull Requests">
      <List.Item
        title="Docs: Update API Reference"
        subtitle="#1"
        actions={
          <ActionPanel title="#1 in raycast/extensions">
            <ActionPanel.Section title="Copy">
              <Action.CopyToClipboard title="Copy Pull Request Number" content="#1" />
              <Action.CopyToClipboard
                title="Copy Pull Request URL"
                content="https://github.com/raycast/extensions/pull/1"
              />
              <Action.CopyToClipboard title="Copy Pull Request Title" content="Docs: Update API Reference" />
            </ActionPanel.Section>
            <ActionPanel.Section title="Danger zone">
              <Action title="Close Pull Request" onAction={() => console.log("Close PR #1")} />
            </ActionPanel.Section>
          </ActionPanel>
        }
      />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children | The item elements of the section. | <code>ActionPanel.Section.Children</code> | - |
| title | Title displayed above the section | <code>string</code> | - |

### ActionPanel.Submenu

A very specific action that replaces the current ActionPanel with its children when selected.

This is handy when an action needs to select from a range of options. For example, to add a label to a GitHub pull request or an assignee to a todo.

#### Example

```typescript
import { Action, ActionPanel, Color, Icon, List } from "@raycast/api";

export default function Command() {
  return (
    <List navigationTitle="Open Pull Requests">
      <List.Item
        title="Docs: Update API Reference"
        subtitle="#1"
        actions={
          <ActionPanel title="#1 in raycast/extensions">
            <ActionPanel.Submenu title="Add Label">
              <Action
                icon={{ source: Icon.Circle, tintColor: Color.Red }}
                title="Bug"
                onAction={() => console.log("Add bug label")}
              />
              <Action
                icon={{ source: Icon.Circle, tintColor: Color.Yellow }}
                title="Enhancement"
                onAction={() => console.log("Add enhancement label")}
              />
              <Action
                icon={{ source: Icon.Circle, tintColor: Color.Blue }}
                title="Help Wanted"
                onAction={() => console.log("Add help wanted label")}
              />
            </ActionPanel.Submenu>
          </ActionPanel>
        }
      />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The title displayed for submenu. | <code>string</code> | - |
| autoFocus | Indicates whether the ActionPanel.Submenu should be focused automatically when the parent ActionPanel (or Actionpanel.Submenu) opens. | <code>boolean</code> | - |
| children | Items of the submenu. | <code>ActionPanel.Submenu.Children</code> | - |
| filtering | Toggles Raycast filtering. When `true`, Raycast will use the query in the search bar to filter the  items. When `false`, the extension needs to take care of the filtering.    You can further define how native filtering orders sections by setting an object with a `keepSectionOrder` property:  When `true`, ensures that Raycast filtering maintains the section order as defined in the extension.  When `false`, filtering may change the section order depending on the ranking values of items. | <code>boolean</code> or <code>{ keepSectionOrder: boolean }</code> | - |
| icon | The icon displayed for the submenu. | <code>Image.ImageLike</code> | - |
| isLoading | Indicates whether a loading indicator should be shown or hidden next to the search bar | <code>boolean</code> | - |
| onOpen | Callback that is triggered when the Submenu is opened.    This callback can be used to fetch its content lazily:  ```js  function LazySubmenu() {    const [content, setContent] = useState(null)      return (      <ActionPanel.Submenu onOpen={() => fetchSubmenuContent().then(setContent)}>        {content}      </ActionPanel.Submenu>    )  }  ``` | <code>() => void</code> | - |
| onSearchTextChange | Callback triggered when the search bar text changes. | <code>(text: string) => void</code> | - |
| shortcut | The keyboard shortcut for the submenu. | <code>Keyboard.Shortcut</code> | - |
| throttle | Defines whether the `onSearchTextChange` handler will be triggered on every keyboard press or with a delay for throttling the events.  Recommended to set to `true` when using custom filtering logic with asynchronous operations (e.g. network requests). | <code>boolean</code> | - |

## Types

### ActionPanel.Children

```typescript
ActionPanel.Children: ActionPanel.Section | ActionPanel.Section[] | ActionPanel.Section.Children | null
```

Supported children for the ActionPanel component.

### ActionPanel.Section.Children

```typescript
ActionPanel.Section.Children: Action | Action[] | ReactElement<ActionPanel.Submenu.Props> | ReactElement<ActionPanel.Submenu.Props>[] | null
```

Supported children for the ActionPanel.Section component.

### ActionPanel.Submenu.Children

```typescript
ActionPanel.Children: ActionPanel.Section | ActionPanel.Section[] | ActionPanel.Section.Children | null
```

Supported children for the ActionPanel.Submenu component.


# Actions

Our API includes a few built-in actions that can be used for common interactions, such as opening a link or copying some content to the clipboard. By using them, you make sure to follow our human interface guidelines. If you need something custom, use the `Action` component. All built-in actions are just abstractions on top of it.

## API Reference

### Action

A context-specific action that can be performed by the user.

Assign keyboard shortcuts to items to make it easier for users to perform frequently used actions.

#### Example

```typescript
import { ActionPanel, Action, List } from "@raycast/api";

export default function Command() {
  return (
    <List navigationTitle="Open Pull Requests">
      <List.Item
        title="Docs: Update API Reference"
        subtitle="#1"
        actions={
          <ActionPanel title="#1 in raycast/extensions">
            <Action.OpenInBrowser url="https://github.com/raycast/extensions/pull/1" />
            <Action.CopyToClipboard title="Copy Pull Request Number" content="#1" />
            <Action title="Close Pull Request" onAction={() => console.log("Close PR #1")} />
          </ActionPanel>
        }
      />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The title displayed for the Action. | <code>string</code> | - |
| autoFocus | Indicates whether the Action should be focused automatically when the parent ActionPanel (or Actionpanel.Submenu) opens. | <code>boolean</code> | - |
| icon | The icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| onAction | Callback that is triggered when the Action is selected. | <code>() => void</code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| style | Defines the visual style of the Action. | <code>Alert.ActionStyle</code> | - |

### Action.CopyToClipboard

Action that copies the content to the clipboard.

The main window is closed, and a HUD is shown after the content was copied to the clipboard.

#### Example

```typescript
import { ActionPanel, Action, Detail } from "@raycast/api";

export default function Command() {
  return (
    <Detail
      markdown="Press `⌘ + .` and share some love."
      actions={
        <ActionPanel>
          <Action.CopyToClipboard content="I ❤️ Raycast" shortcut={{ modifiers: ["cmd"], key: "." }} />
        </ActionPanel>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| content<mark style="color:red;">*</mark> | The contents that will be copied to the clipboard. | <code>string</code> or <code>number</code> or <code>Clipboard.Content</code> | - |
| concealed | Indicates whether the content be treated as confidential. If `true`, it will not be recorded in the Clipboard History. | <code>boolean</code> | - |
| icon | A optional icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| onCopy | Callback when the content was copied to clipboard. | <code>(content: string \| number \| Clipboard.Content => void</code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| title | An optional title for the Action. | <code>string</code> | - |

### Action.Open

An action to open a file or folder with a specific application, just as if you had double-clicked the
file's icon.

The main window is closed after the file is opened.

#### Example

```typescript
import { ActionPanel, Detail, Action } from "@raycast/api";

export default function Command() {
  return (
    <Detail
      markdown="Check out your extension code."
      actions={
        <ActionPanel>
          <Action.Open title="Open Folder" target={__dirname} />
        </ActionPanel>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| target<mark style="color:red;">*</mark> | The file, folder or URL to open. | <code>string</code> | - |
| title<mark style="color:red;">*</mark> | The title for the Action. | <code>string</code> | - |
| application | The application name to use for opening the file. | <code>string</code> or <code>Application</code> | - |
| icon | The icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| onOpen | Callback when the file or folder was opened. | <code>(target: string) => void</code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |

### Action.OpenInBrowser

Action that opens a URL in the default browser.

The main window is closed after the URL is opened in the browser.

#### Example

```typescript
import { ActionPanel, Detail, Action } from "@raycast/api";

export default function Command() {
  return (
    <Detail
      markdown="Join the gang!"
      actions={
        <ActionPanel>
          <Action.OpenInBrowser url="https://raycast.com/jobs" />
        </ActionPanel>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| url<mark style="color:red;">*</mark> | The URL to open. | <code>string</code> | - |
| icon | The icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| onOpen | Callback when the URL was opened in the browser. | <code>(url: string) => void</code> | - |
| shortcut | The optional keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| title | An optional title for the Action. | <code>string</code> | - |

### Action.OpenWith

Action that opens a file or URL with a specific application.

The action opens a sub-menu with all applications that can open the file or URL.
The main window is closed after the item is opened in the specified application.

#### Example

```typescript
import { ActionPanel, Detail, Action } from "@raycast/api";
import { homedir } from "os";

const DESKTOP_DIR = `${homedir()}/Desktop`;

export default function Command() {
  return (
    <Detail
      markdown="What do you want to use to open your desktop with?"
      actions={
        <ActionPanel>
          <Action.OpenWith path={DESKTOP_DIR} />
        </ActionPanel>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| path<mark style="color:red;">*</mark> | The path to open. | <code>string</code> | - |
| icon | The icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| onOpen | Callback when the file or folder was opened. | <code>(path: string) => void</code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| title | The title for the Action. | <code>string</code> | - |

### Action.Paste

Action that pastes the content to the front-most applications.

The main window is closed after the content is pasted to the front-most application.

#### Example

```typescript
import { ActionPanel, Detail, Action } from "@raycast/api";

export default function Command() {
  return (
    <Detail
      markdown="Let us know what you think about the Raycast API?"
      actions={
        <ActionPanel>
          <Action.Paste content="api@raycast.com" />
        </ActionPanel>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| content<mark style="color:red;">*</mark> | The contents that will be pasted to the frontmost application. | <code>string</code> or <code>number</code> or <code>Clipboard.Content</code> | - |
| icon | The icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| onPaste | Callback when the content was pasted into the front-most application. | <code>(content: string \| number \| Clipboard.Content => void</code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| title | An optional title for the Action. | <code>string</code> | - |

### Action.Push

Action that pushes a new view to the navigation stack.

#### Example

```typescript
import { ActionPanel, Detail, Action } from "@raycast/api";

function Ping() {
  return (
    <Detail
      markdown="Ping"
      actions={
        <ActionPanel>
          <Action.Push title="Push Pong" target={<Pong />} />
        </ActionPanel>
      }
    />
  );
}

function Pong() {
  return <Detail markdown="Pong" />;
}

export default function Command() {
  return <Ping />;
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| target<mark style="color:red;">*</mark> | The target view that will be pushed to the navigation stack. | <code>React.ReactNode</code> | - |
| title<mark style="color:red;">*</mark> | The title displayed for the Action. | <code>string</code> | - |
| icon | The icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| onPop | Callback when the target view will be popped. | <code>() => void</code> | - |
| onPush | Callback when the target view was pushed. | <code>() => void</code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |

### Action.ShowInFinder

Action that shows a file or folder in the Finder.

The main window is closed after the file or folder is revealed in the Finder.

#### Example

```typescript
import { ActionPanel, Detail, Action } from "@raycast/api";
import { homedir } from "os";

const DOWNLOADS_DIR = `${homedir()}/Downloads`;

export default function Command() {
  return (
    <Detail
      markdown="Are your downloads pilling up again?"
      actions={
        <ActionPanel>
          <Action.ShowInFinder path={DOWNLOADS_DIR} />
        </ActionPanel>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| path<mark style="color:red;">*</mark> | The path to open. | <code>"fs".PathLike</code> | - |
| icon | A optional icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| onShow | Callback when the file or folder was shown in the Finder. | <code>(path: "fs".PathLike) => void</code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| title | An optional title for the Action. | <code>string</code> | - |

### Action.SubmitForm

Action that adds a submit handler for capturing form values.

#### Example

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Answer" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.Checkbox id="answer" label="Are you happy?" defaultValue={true} />
    </Form>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| icon | The icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| onSubmit | Callback when the Form was submitted.  The handler receives a the values object containing the user input. | <code>(input: Form.Values => boolean \| void \| Promise&lt;boolean \| void></code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| style | Defines the visual style of the Action. | <code>Alert.ActionStyle</code> | - |
| title | The title displayed for the Action. | <code>string</code> | - |

### Action.Trash

Action that moves a file or folder to the Trash.

#### Example

```typescript
import { ActionPanel, Detail, Action } from "@raycast/api";
import { homedir } from "os";

const FILE = `${homedir()}/Downloads/get-rid-of-me.txt`;

export default function Command() {
  return (
    <Detail
      markdown="Some spring cleaning?"
      actions={
        <ActionPanel>
          <Action.Trash paths={FILE} />
        </ActionPanel>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| paths<mark style="color:red;">*</mark> | The item or items to move to the trash. | <code>"fs".PathLike</code> or <code>"fs".PathLike[]</code> | - |
| icon | A optional icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| onTrash | Callback when all items were moved to the trash. | <code>(paths: "fs".PathLike \| "fs".PathLike[]) => void</code> | - |
| shortcut | The optional keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| title | An optional title for the Action. | <code>string</code> | - |

### Action.CreateSnippet

Action that navigates to the the Create Snippet command with some or all of the fields prefilled.

#### Example

```typescript
import { ActionPanel, Detail, Action } from "@raycast/api";

export default function Command() {
  return (
    <Detail
      markdown="Test out snippet creation"
      actions={
        <ActionPanel>
          <Action.CreateSnippet snippet={{ text: "DE75512108001245126199" }} />
        </ActionPanel>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| snippet<mark style="color:red;">*</mark> |  | <code>Snippet</code> | - |
| icon | A optional icon displayed for the Action. See Image.ImageLike for the supported formats and types. | <code>Image.ImageLike</code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| title | An optional title for the Action. | <code>string</code> | - |

### Action.CreateQuicklink

Action that navigates to the the Create Quicklink command with some or all of the fields prefilled.

#### Example

```typescript
import { ActionPanel, Detail, Action } from "@raycast/api";

export default function Command() {
  return (
    <Detail
      markdown="Test out quicklink creation"
      actions={
        <ActionPanel>
          <Action.CreateQuicklink quicklink={{ link: "https://duckduckgo.com/?q={Query}" }} />
        </ActionPanel>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| quicklink<mark style="color:red;">*</mark> | The Quicklink to create. | <code>Quicklink</code> | - |
| icon | A optional icon displayed for the Action. See Image.ImageLike for the supported formats and types. | <code>Image.ImageLike</code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| title | An optional title for the Action. | <code>string</code> | - |

### Action.ToggleQuickLook

Action that toggles the Quick Look to preview a file.

#### Example

```typescript
import { ActionPanel, List, Action } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item
        title="Preview me"
        quickLook={{ path: "~/Downloads/Raycast.dmg", name: "Some file" }}
        actions={
          <ActionPanel>
            <Action.ToggleQuickLook />
          </ActionPanel>
        }
      />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| icon | The icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| title | The title for the Action. | <code>string</code> | - |

### Action.PickDate

Action to pick a date.

#### Example

```typescript
import { ActionPanel, List, Action } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item
        title="Todo"
        actions={
          <ActionPanel>
            <Action.PickDate title="Set Due Date…" />
          </ActionPanel>
        }
      />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| onChange<mark style="color:red;">*</mark> | Callback when the Date was picked | <code>(date: [Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)) => void</code> | - |
| title<mark style="color:red;">*</mark> | A title for the Action. | <code>string</code> | - |
| icon | A optional icon displayed for the Action. | <code>Image.ImageLike</code> | - |
| max | The maximum date (inclusive) allowed for selection.    - If the PickDate type is `Type.Date`, only the full day date will be considered for comparison, ignoring the time components of the Date object.  - If the PickDate type is `Type.DateTime`, both date and time components will be considered for comparison.    The date should be a JavaScript Date object. | <code>[Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)</code> | - |
| min | The minimum date (inclusive) allowed for selection.    - If the PickDate type is `Type.Date`, only the full day date will be considered for comparison, ignoring the time components of the Date object.  - If the PickDate type is `Type.DateTime`, both date and time components will be considered for comparison.    The date should be a JavaScript Date object. | <code>[Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)</code> | - |
| shortcut | The keyboard shortcut for the Action. | <code>Keyboard.Shortcut</code> | - |
| type | Indicates what types of date components can be picked    Defaults to Action.PickDate.Type.DateTime | <code>Action.PickDate.Type</code> | - |

## Types

### Snippet

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| text<mark style="color:red;">*</mark> | The snippet contents. | <code>string</code> |
| keyword | The keyword to trigger the snippet. | <code>string</code> |
| name | The snippet name. | <code>string</code> |

### Quicklink

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| link<mark style="color:red;">*</mark> | The URL or file path, optionally including placeholders such as in "https://google.com/search?q={Query}" | <code>string</code> |
| application | The application that the quicklink should be opened in. | <code>string</code> or <code>Application</code> |
| icon | The icon to display for the quicklink. | <code>Icon</code> |
| name | The quicklink name | <code>string</code> |

### Action.Style

Defines the visual style of the Action.

Use Action.Style.Regular for displaying a regular actions.
Use Action.Style.Destructive when your action has something that user should be careful about.
Use the confirmation Alert if the action is doing something that user cannot revert.

### Action.PickDate.Type

The types of date components the user can pick with an `Action.PickDate`.

#### Enumeration members

| Name     | Description                                                      |
| -------- | ---------------------------------------------------------------- |
| DateTime | Hour and second can be picked in addition to year, month and day |
| Date     | Only year, month, and day can be picked                          |

### Action.PickDate.isFullDay

A method that determines if a given date represents a full day or a specific time.

```tsx
import { ActionPanel, List, Action } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item
        title="Todo"
        actions={
          <ActionPanel>
            <Action.PickDate
              title="Set Due Date…"
              onChange={(date) => {
                if (Action.PickDate.isFullDay(values.reminderDate)) {
                  // the event is for a full day
                } else {
                  // the event is at a specific time
                }
              }}
            />
          </ActionPanel>
        }
      />
    </List>
  );
}
```


# Colors

Anywhere you can pass a color in a component prop, you can pass either:

- A standard Color
- A Dynamic Color
- A Raw Color

## API Reference

### Color

The standard colors. Use those colors for consistency.

The colors automatically adapt to the Raycast theme (light or dark).

#### Example

```typescript
import { Color, Icon, List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item title="Blue" icon={{ source: Icon.Circle, tintColor: Color.Blue }} />
      <List.Item title="Green" icon={{ source: Icon.Circle, tintColor: Color.Green }} />
      <List.Item title="Magenta" icon={{ source: Icon.Circle, tintColor: Color.Magenta }} />
      <List.Item title="Orange" icon={{ source: Icon.Circle, tintColor: Color.Orange }} />
      <List.Item title="Purple" icon={{ source: Icon.Circle, tintColor: Color.Purple }} />
      <List.Item title="Red" icon={{ source: Icon.Circle, tintColor: Color.Red }} />
      <List.Item title="Yellow" icon={{ source: Icon.Circle, tintColor: Color.Yellow }} />
      <List.Item title="PrimaryText" icon={{ source: Icon.Circle, tintColor: Color.PrimaryText }} />
      <List.Item title="SecondaryText" icon={{ source: Icon.Circle, tintColor: Color.SecondaryText }} />
    </List>
  );
}
```

#### Enumeration members

| Name          | Dark Theme                                                | Light Theme                                          |
| :------------ | :-------------------------------------------------------- | :--------------------------------------------------- |
| Blue          |            |
| Green         |           |
| Magenta       |         |
| Orange        |          |
| Purple        |          |
| Red           |             |
| Yellow        |          |
| PrimaryText   |    |
| SecondaryText |  |

## Types

### Color.ColorLike

```typescript
ColorLike: Color | Color.Dynamic | Color.Raw;
```

Union type for the supported color types.

When using a Raw Color. However, we recommend leaving color adjustment on, unless your extension depends on exact color reproduction.

#### Example

```typescript
import { Color, Icon, List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item title="Built-in color" icon={{ source: Icon.Circle, tintColor: Color.Red }} />
      <List.Item title="Raw color" icon={{ source: Icon.Circle, tintColor: "#FF0000" }} />
      <List.Item
        title="Dynamic color"
        icon={{
          source: Icon.Circle,
          tintColor: {
            light: "#FF01FF",
            dark: "#FFFF50",
            adjustContrast: true,
          },
        }}
      />
    </List>
  );
}
```

### Color.Dynamic

A dynamic color applies different colors depending on the active Raycast theme.

When using a Dynamic Color, it will be adjusted to achieve high contrast with the Raycast user interface. To disable color adjustment, you can set the `adjustContrast` property to `false`. However, we recommend leaving color adjustment on, unless your extension depends on exact color reproduction.

#### Example

```typescript
import { Icon, List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item
        title="Dynamic Tint Color"
        icon={{
          source: Icon.Circle,
          tintColor: {
            light: "#FF01FF",
            dark: "#FFFF50",
            adjustContrast: false,
          },
        }}
      />
      <List.Item
        title="Dynamic Tint Color"
        icon={{
          source: Icon.Circle,
          tintColor: { light: "#FF01FF", dark: "#FFFF50" },
        }}
      />
    </List>
  );
}
```

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| dark<mark style="color:red;">*</mark> | The color which is used in dark theme. | <code>string</code> |
| light<mark style="color:red;">*</mark> | The color which is used in light theme. | <code>string</code> |
| adjustContrast | Enables dynamic contrast adjustment for light and dark theme color. | <code>boolean</code> |

### Color.Raw

A color can also be a simple string. You can use any of the following color formats:

- HEX, e.g `#FF0000`
- Short HEX, e.g. `#F00`
- RGBA, e.g. `rgb(255, 0, 0)`
- RGBA Percentage, e.g. `rgb(255, 0, 0, 1.0)`
- HSL, e.g. `hsla(200, 20%, 33%, 0.2)`
- Keywords, e.g. `red`


# Detail



## API Reference

### Detail

Renders a markdown ([CommonMark](https://commonmark.org)) string with an optional metadata panel.

Typically used as a standalone view or when navigating from a List.

#### Example

{% tabs %}
{% tab title="Render a markdown string" %}

```typescript
import { Detail } from "@raycast/api";

export default function Command() {
  return <Detail markdown="**Hello** _World_!" />;
}
```

{% endtab %}

{% tab title="Render an image from the assets directory" %}

```typescript
import { Detail } from "@raycast/api";

export default function Command() {
  return <Detail markdown={`!Image Title`} />;
}
```

{% endtab %}
{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| actions | A reference to an ActionPanel. | <code>React.ReactNode</code> | - |
| isLoading | Indicates whether a loading bar should be shown or hidden below the search bar | <code>boolean</code> | - |
| markdown | The CommonMark string to be rendered. | <code>string</code> | - |
| metadata | The `Detail.Metadata` to be rendered in the right side area | <code>React.ReactNode</code> | - |
| navigationTitle | The main title for that view displayed in Raycast | <code>string</code> | - |

{% hint style="info" %}
You can specify custom image dimensions by adding a `raycast-width` and `raycast-height` query string to the markdown image. For example: `!Image Title`

You can also specify a tint color to apply to an markdown image by adding a `raycast-tint-color` query string. For example: `!Image Title`
{% endhint %}

{% hint style="info" %}
You can now render [LaTeX](https://www.latex-project.org) in the markdown. We support the following delimiters:

- Inline math: `\(...\)` and `\begin{math}...\end{math}`
- Display math: `\[...\]`, `$$...$$` and `\begin{equation}...\end{equation}`

{% endhint %}

### Detail.Metadata

A Metadata view that will be shown in the right-hand-side of the `Detail`.

Use it to display additional structured data about the main content shown in the `Detail` view.



#### Example

```typescript
import { Detail } from "@raycast/api";

// Define markdown here to prevent unwanted indentation.
const markdown = `
# Pikachu

![](https://assets.pokemon.com/assets/cms2/img/pokedex/full/025.png)

Pikachu that can generate powerful electricity have cheek sacs that are extra soft and super stretchy.
`;

export default function Main() {
  return (
    <Detail
      markdown={markdown}
      navigationTitle="Pikachu"
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.Label title="Height" text={`1' 04"`} />
          <Detail.Metadata.Label title="Weight" text="13.2 lbs" />
          <Detail.Metadata.TagList title="Type">
            <Detail.Metadata.TagList.Item text="Electric" color={"#eed535"} />
          </Detail.Metadata.TagList>
          <Detail.Metadata.Separator />
          <Detail.Metadata.Link title="Evolution" target="https://www.pokemon.com/us/pokedex/pikachu" text="Raichu" />
        </Detail.Metadata>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children<mark style="color:red;">*</mark> | The elements of the Metadata view. | <code>React.ReactNode</code> | - |

### Detail.Metadata.Label

A single value with an optional icon.



#### Example

```typescript
import { Detail } from "@raycast/api";

// Define markdown here to prevent unwanted indentation.
const markdown = `
# Pikachu

![](https://assets.pokemon.com/assets/cms2/img/pokedex/full/025.png)

Pikachu that can generate powerful electricity have cheek sacs that are extra soft and super stretchy.
`;

export default function Main() {
  return (
    <Detail
      markdown={markdown}
      navigationTitle="Pikachu"
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.Label title="Height" text={`1' 04"`} icon="weight.svg" />
        </Detail.Metadata>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The title of the item. | <code>string</code> | - |
| icon | An icon to illustrate the value of the item. | <code>Image.ImageLike</code> | - |
| text | The text value of the item.  Specifying `color` will display the text in the provided color. Defaults to Color.PrimaryText. | <code>string</code> or <code>{ color?: Color; value: string }</code> | - |

### Detail.Metadata.Link

An item to display a link.



#### Example

```typescript
import { Detail } from "@raycast/api";

// Define markdown here to prevent unwanted indentation.
const markdown = `
# Pikachu

![](https://assets.pokemon.com/assets/cms2/img/pokedex/full/025.png)

Pikachu that can generate powerful electricity have cheek sacs that are extra soft and super stretchy.
`;

export default function Main() {
  return (
    <Detail
      markdown={markdown}
      navigationTitle="Pikachu"
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.Link title="Evolution" target="https://www.pokemon.com/us/pokedex/pikachu" text="Raichu" />
        </Detail.Metadata>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| target<mark style="color:red;">*</mark> | The target of the link. | <code>string</code> | - |
| text<mark style="color:red;">*</mark> | The text value of the item. | <code>string</code> | - |
| title<mark style="color:red;">*</mark> | The title shown above the item. | <code>string</code> | - |

### Detail.Metadata.TagList

A list of `Tags` displayed in a row.



#### Example

```typescript
import { Detail } from "@raycast/api";

// Define markdown here to prevent unwanted indentation.
const markdown = `
# Pikachu

![](https://assets.pokemon.com/assets/cms2/img/pokedex/full/025.png)

Pikachu that can generate powerful electricity have cheek sacs that are extra soft and super stretchy.
`;

export default function Main() {
  return (
    <Detail
      markdown={markdown}
      navigationTitle="Pikachu"
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.TagList title="Type">
            <Detail.Metadata.TagList.Item text="Electric" color={"#eed535"} />
          </Detail.Metadata.TagList>
        </Detail.Metadata>
      }
    />
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children<mark style="color:red;">*</mark> | The tags contained in the TagList. | <code>React.ReactNode</code> | - |
| title<mark style="color:red;">*</mark> | The title shown above the item. | <code>string</code> | - |

### Detail.Metadata.TagList.Item

A Tag in a `Detail.Metadata.TagList`.

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| color | Changes the text color to the provided color and sets a transparent background with the same color. | <code>Color.ColorLike</code> | - |
| icon | The optional icon tag icon. Required if the tag has no text. | <code>Image.ImageLike</code> | - |
| onAction | Callback that is triggered when the item is clicked. | <code>() => void</code> | - |
| text | The optional tag text. Required if the tag has no icon. | <code>string</code> | - |

### Detail.Metadata.Separator

A metadata item that shows a separator line. Use it for grouping and visually separating metadata items.



```typescript
import { Detail } from "@raycast/api";

// Define markdown here to prevent unwanted indentation.
const markdown = `
# Pikachu

![](https://assets.pokemon.com/assets/cms2/img/pokedex/full/025.png)

Pikachu that can generate powerful electricity have cheek sacs that are extra soft and super stretchy.
`;

export default function Main() {
  return (
    <Detail
      markdown={markdown}
      navigationTitle="Pikachu"
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.Label title="Height" text={`1' 04"`} />
          <Detail.Metadata.Separator />
          <Detail.Metadata.Label title="Weight" text="13.2 lbs" />
        </Detail.Metadata>
      }
    />
  );
}
```


# Form

Our `Form` component provides great user experience to collect some data from a user and submit it for extensions needs.



## Two Types of Items: Controlled vs. Uncontrolled

Items in React can be one of two types: controlled or uncontrolled.

An uncontrolled item is the simpler of the two. It's the closest to a plain HTML input. React puts it on the page, and Raycast keeps track of the rest. Uncontrolled inputs require less code, but make it harder to do certain things.

With a controlled item, YOU explicitly control the `value` that the item displays. You have to write code to respond to changes with defining `onChange` callback, store the current `value` somewhere, and pass that value back to the item to be displayed. It's a feedback loop with your code in the middle. It's more manual work to wire these up, but they offer the most control.

You can take look at these two styles below under each of the supported items.

## Validation

Before submitting data, it is important to ensure all required form controls are filled out, in the correct format.

In Raycast, validation can be fully controlled from the API. To keep the same behavior as we have natively, the proper way of usage is to validate a `value` in the `onBlur` callback, update the `error` of the item and keep track of updates with the `onChange` callback to drop the `error` value. The useForm utils hook nicely wraps this behaviour and is the recommended way to do deal with validations.



{% hint style="info" %}
Keep in mind that if the Form has any errors, the `Action.SubmitForm` `onSubmit` callback won't be triggered.
{% endhint %}

#### Example

{% tabs %}

{% tab title="FormValidationWithUtils.tsx" %}

```tsx
import { Action, ActionPanel, Form, showToast, Toast } from "@raycast/api";
import { useForm, FormValidation } from "@raycast/utils";

interface SignUpFormValues {
  name: string;
  password: string;
}

export default function Command() {
  const { handleSubmit, itemProps } = useForm<SignUpFormValues>({
    onSubmit(values) {
      showToast({
        style: Toast.Style.Success,
        title: "Yay!",
        message: `${values.name} account created`,
      });
    },
    validation: {
      name: FormValidation.Required,
      password: (value) => {
        if (value && value.length < 8) {
          return "Password must be at least 8 symbols";
        } else if (!value) {
          return "The item is required";
        }
      },
    },
  });
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit" onSubmit={handleSubmit} />
        </ActionPanel>
      }
    >
      <Form.TextField title="Full Name" placeholder="Tim Cook" {...itemProps.name} />
      <Form.PasswordField title="New Password" {...itemProps.password} />
    </Form>
  );
}
```

{% endtab %}

{% tab title="FormValidationWithoutUtils.tsx" %}

```typescript
import { Form } from "@raycast/api";
import { useState } from "react";

export default function Command() {
  const [nameError, setNameError] = useState<string | undefined>();
  const [passwordError, setPasswordError] = useState<string | undefined>();

  function dropNameErrorIfNeeded() {
    if (nameError && nameError.length > 0) {
      setNameError(undefined);
    }
  }

  function dropPasswordErrorIfNeeded() {
    if (passwordError && passwordError.length > 0) {
      setPasswordError(undefined);
    }
  }

  return (
    <Form>
      <Form.TextField
        id="nameField"
        title="Full Name"
        placeholder="Tim Cook"
        error={nameError}
        onChange={dropNameErrorIfNeeded}
        onBlur={(event) => {
          if (event.target.value?.length == 0) {
            setNameError("The field should't be empty!");
          } else {
            dropNameErrorIfNeeded();
          }
        }}
      />
      <Form.PasswordField
        id="password"
        title="New Password"
        error={passwordError}
        onChange={dropPasswordErrorIfNeeded}
        onBlur={(event) => {
          const value = event.target.value;
          if (value && value.length > 0) {
            if (!validatePassword(value)) {
              setPasswordError("Password should be at least 8 characters!");
            } else {
              dropPasswordErrorIfNeeded();
            }
          } else {
            setPasswordError("The field should't be empty!");
          }
        }}
      />
      <Form.TextArea id="bioTextArea" title="Add Bio" placeholder="Describe who you are" />
      <Form.DatePicker id="birthDate" title="Date of Birth" />
    </Form>
  );
}

function validatePassword(value: string): boolean {
  return value.length >= 8;
}
```

{% endtab %}

{% endtabs %}

## Drafts

Drafts are a mechanism to preserve filled-in inputs (but not yet submitted) when an end-user exits the command. To enable this mechanism, set the `enableDrafts` prop on your Form and populate the initial values of the Form with the top-level prop `draftValues`.



{% hint style="info" %}

- Drafts for forms nested in navigation are not supported yet. In this case, you will see a warning about it.
- Drafts won't preserve the `Form.Password`'s values.
- Drafts will be dropped once `Action.SubmitForm` is triggered.
- If you call `popToRoot()`, drafts won't be preserved or updated.

{% endhint %}

#### Example

{% tabs %}
{% tab title="Uncontrolled Form" %}

```typescript
import { Form, ActionPanel, Action, popToRoot, LaunchProps } from "@raycast/api";

interface TodoValues {
  title: string;
  description?: string;
  dueDate?: Date;
}

export default function Command(props: LaunchProps<{ draftValues: TodoValues }>) {
  const { draftValues } = props;

  return (
    <Form
      enableDrafts
      actions={
        <ActionPanel>
          <Action.SubmitForm
            onSubmit={(values: TodoValues) => {
              console.log("onSubmit", values);
              popToRoot();
            }}
          />
        </ActionPanel>
      }
    >
      <Form.TextField id="title" title="Title" defaultValue={draftValues?.title} />
      <Form.TextArea id="description" title="Description" defaultValue={draftValues?.description} />
      <Form.DatePicker id="dueDate" title="Due Date" defaultValue={draftValues?.dueDate} />
    </Form>
  );
}
```

{% endtab %}

{% tab title="Controlled Form" %}

```typescript
import { Form, ActionPanel, Action, popToRoot, LaunchProps } from "@raycast/api";
import { useState } from "react";

interface TodoValues {
  title: string;
  description?: string;
  dueDate?: Date;
}

export default function Command(props: LaunchProps<{ draftValues: TodoValues }>) {
  const { draftValues } = props;

  const [title, setTitle] = useState<string>(draftValues?.title || "");
  const [description, setDescription] = useState<string>(draftValues?.description || "");
  const [dueDate, setDueDate] = useState<Date | null>(draftValues?.dueDate || null);

  return (
    <Form
      enableDrafts
      actions={
        <ActionPanel>
          <Action.SubmitForm
            onSubmit={(values: TodoValues) => {
              console.log("onSubmit", values);
              popToRoot();
            }}
          />
        </ActionPanel>
      }
    >
      <Form.TextField id="title" title="Title" value={title} onChange={setTitle} />
      <Form.TextArea id="description" title="Description" value={description} onChange={setDescription} />
      <Form.DatePicker id="dueDate" title="Due Date" value={dueDate} onChange={setDueDate} />
    </Form>
  );
}
```

{% endtab %}
{% endtabs %}

## API Reference

### Form

Shows a list of form items such as Form.TextField.

Optionally add a Form.LinkAccessory in the right-hand side of the navigation bar.

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| actions | A reference to an ActionPanel. | <code>React.ReactNode</code> | - |
| children | The Form.Item elements of the form. | <code>React.ReactNode</code> | - |
| enableDrafts | Defines whether the Form.Items values will be preserved when user exits the screen. | <code>boolean</code> | - |
| isLoading | Indicates whether a loading bar should be shown or hidden below the search bar | <code>boolean</code> | - |
| navigationTitle | The main title for that view displayed in Raycast | <code>string</code> | - |
| searchBarAccessory | Form.LinkAccessory that will be shown in the right-hand-side of the search bar. | <code>ReactElement&lt;Form.LinkAccessory.Props, string></code> | - |

### Form.TextField

A form item with a text field for input.



#### Example

{% tabs %}
{% tab title="Uncontrolled text field" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Name" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.TextField id="name" defaultValue="Steve" />
    </Form>
  );
}
```

{% endtab %}

{% tab title="Controlled text field" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";
import { useState } from "react";

export default function Command() {
  const [name, setName] = useState<string>("");

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Name" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.TextField id="name" value={name} onChange={setName} />
    </Form>
  );
}
```

{% endtab %}
{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| id<mark style="color:red;">*</mark> | ID of the form item.  Make sure to assign each form item a unique id. | <code>string</code> | - |
| autoFocus | Indicates whether the item should be focused automatically once the form is rendered. | <code>boolean</code> | - |
| defaultValue | The default value of the item.  Keep in mind that `defaultValue` will be configured once per component lifecycle. This means that if a user changes the value, `defaultValue` won't be configured on re-rendering.    If you're using `storeValue` and configured it as `true` then the stored value will be set.    If you configure `value` at the same time with `defaultValue`, the `value` will be set instead of `defaultValue`. | <code>string</code> | - |
| error | An optional error message to show the form item validation issues.  If the `error` is present, the Form Item will be highlighted with red border and will show an error message on the right. | <code>string</code> | - |
| info | An optional info message to describe the form item. It appears on the right side of the item with an info icon. When the icon is hovered, the info message is shown. | <code>string</code> | - |
| onBlur | The callback that will be triggered when the item loses its focus. | <code>(event: FormEvent&lt;string>) => void</code> | - |
| onChange | The callback which will be triggered when the `value` of the item changes. | <code>(newValue: string) => void</code> | - |
| onFocus | The callback which will be triggered should be called when the item is focused. | <code>(event: FormEvent&lt;string>) => void</code> | - |
| placeholder | Placeholder text shown in the text field. | <code>string</code> | - |
| storeValue | Indicates whether the value of the item should be persisted after submitting, and restored next time the form is rendered. | <code>boolean</code> | - |
| title | The title displayed on the left side of the item. | <code>string</code> | - |
| value | The current value of the item. | <code>string</code> | - |

#### Methods (Imperative API)

| Name  | Signature               | Description                                                                |
| ----- | ----------------------- | -------------------------------------------------------------------------- |
| focus | <code>() => void</code> | Makes the item request focus.                                              |
| reset | <code>() => void</code> | Resets the form item to its initial value, or `defaultValue` if specified. |

### Form.PasswordField

A form item with a secure text field for password-entry in which the entered characters must be kept secret.



#### Example

{% tabs %}
{% tab title="Uncontrolled password field" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Password" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.PasswordField id="password" title="Enter Password" />
    </Form>
  );
}
```

{% endtab %}

{% tab title="Controlled password field" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";
import { useState } from "react";

export default function Command() {
  const [password, setPassword] = useState<string>("");

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Password" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.PasswordField id="password" value={password} onChange={setPassword} />
    </Form>
  );
}
```

{% endtab %}
{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| id<mark style="color:red;">*</mark> | ID of the form item.  Make sure to assign each form item a unique id. | <code>string</code> | - |
| autoFocus | Indicates whether the item should be focused automatically once the form is rendered. | <code>boolean</code> | - |
| defaultValue | The default value of the item.  Keep in mind that `defaultValue` will be configured once per component lifecycle. This means that if a user changes the value, `defaultValue` won't be configured on re-rendering.    If you're using `storeValue` and configured it as `true` then the stored value will be set.    If you configure `value` at the same time with `defaultValue`, the `value` will be set instead of `defaultValue`. | <code>string</code> | - |
| error | An optional error message to show the form item validation issues.  If the `error` is present, the Form Item will be highlighted with red border and will show an error message on the right. | <code>string</code> | - |
| info | An optional info message to describe the form item. It appears on the right side of the item with an info icon. When the icon is hovered, the info message is shown. | <code>string</code> | - |
| onBlur | The callback that will be triggered when the item loses its focus. | <code>(event: FormEvent&lt;string>) => void</code> | - |
| onChange | The callback which will be triggered when the `value` of the item changes. | <code>(newValue: string) => void</code> | - |
| onFocus | The callback which will be triggered should be called when the item is focused. | <code>(event: FormEvent&lt;string>) => void</code> | - |
| placeholder | Placeholder text shown in the password field. | <code>string</code> | - |
| storeValue | Indicates whether the value of the item should be persisted after submitting, and restored next time the form is rendered. | <code>boolean</code> | - |
| title | The title displayed on the left side of the item. | <code>string</code> | - |
| value | The current value of the item. | <code>string</code> | - |

#### Methods (Imperative API)

| Name  | Signature               | Description                                                                |
| ----- | ----------------------- | -------------------------------------------------------------------------- |
| focus | <code>() => void</code> | Makes the item request focus.                                              |
| reset | <code>() => void</code> | Resets the form item to its initial value, or `defaultValue` if specified. |

### Form.TextArea

A form item with a text area for input. The item supports multiline text entry.



#### Example

{% tabs %}
{% tab title="Uncontrolled text area" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

const DESCRIPTION =
  "We spend too much time staring at loading indicators. The Raycast team is dedicated to make everybody interact faster with their computers.";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Description" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.TextArea id="description" defaultValue={DESCRIPTION} />
    </Form>
  );
}
```

{% endtab %}

{% tab title="Controlled text area" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";
import { useState } from "react";

export default function Command() {
  const [description, setDescription] = useState<string>("");

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Description" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.TextArea id="description" value={description} onChange={setDescription} />
    </Form>
  );
}
```

{% endtab %}
{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| id<mark style="color:red;">*</mark> | ID of the form item.  Make sure to assign each form item a unique id. | <code>string</code> | - |
| autoFocus | Indicates whether the item should be focused automatically once the form is rendered. | <code>boolean</code> | - |
| defaultValue | The default value of the item.  Keep in mind that `defaultValue` will be configured once per component lifecycle. This means that if a user changes the value, `defaultValue` won't be configured on re-rendering.    If you're using `storeValue` and configured it as `true` then the stored value will be set.    If you configure `value` at the same time with `defaultValue`, the `value` will be set instead of `defaultValue`. | <code>string</code> | - |
| enableMarkdown | Whether markdown will be highlighted in the TextArea or not.  When enabled, markdown shortcuts starts to work for the TextArea (pressing `⌘ + B` will add `**bold**` around the selected text, `⌘ + I` will make the selected text italic, etc.) | <code>boolean</code> | - |
| error | An optional error message to show the form item validation issues.  If the `error` is present, the Form Item will be highlighted with red border and will show an error message on the right. | <code>string</code> | - |
| info | An optional info message to describe the form item. It appears on the right side of the item with an info icon. When the icon is hovered, the info message is shown. | <code>string</code> | - |
| onBlur | The callback that will be triggered when the item loses its focus. | <code>(event: FormEvent&lt;string>) => void</code> | - |
| onChange | The callback which will be triggered when the `value` of the item changes. | <code>(newValue: string) => void</code> | - |
| onFocus | The callback which will be triggered should be called when the item is focused. | <code>(event: FormEvent&lt;string>) => void</code> | - |
| placeholder | Placeholder text shown in the text area. | <code>string</code> | - |
| storeValue | Indicates whether the value of the item should be persisted after submitting, and restored next time the form is rendered. | <code>boolean</code> | - |
| title | The title displayed on the left side of the item. | <code>string</code> | - |
| value | The current value of the item. | <code>string</code> | - |

#### Methods (Imperative API)

| Name  | Signature               | Description                                                                |
| ----- | ----------------------- | -------------------------------------------------------------------------- |
| focus | <code>() => void</code> | Makes the item request focus.                                              |
| reset | <code>() => void</code> | Resets the form item to its initial value, or `defaultValue` if specified. |

### Form.Checkbox

A form item with a checkbox.



#### Example

{% tabs %}
{% tab title="Uncontrolled checkbox" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Answer" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.Checkbox id="answer" label="Are you happy?" defaultValue={true} />
    </Form>
  );
}
```

{% endtab %}

{% tab title="Controlled checkbox" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";
import { useState } from "react";

export default function Command() {
  const [checked, setChecked] = useState(true);

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Answer" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.Checkbox id="answer" label="Do you like orange juice?" value={checked} onChange={setChecked} />
    </Form>
  );
}
```

{% endtab %}
{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| id<mark style="color:red;">*</mark> | ID of the form item.  Make sure to assign each form item a unique id. | <code>string</code> | - |
| label<mark style="color:red;">*</mark> | The label displayed on the right side of the checkbox. | <code>string</code> | - |
| autoFocus | Indicates whether the item should be focused automatically once the form is rendered. | <code>boolean</code> | - |
| defaultValue | The default value of the item.  Keep in mind that `defaultValue` will be configured once per component lifecycle. This means that if a user changes the value, `defaultValue` won't be configured on re-rendering.    If you're using `storeValue` and configured it as `true` then the stored value will be set.    If you configure `value` at the same time with `defaultValue`, the `value` will be set instead of `defaultValue`. | <code>boolean</code> | - |
| error | An optional error message to show the form item validation issues.  If the `error` is present, the Form Item will be highlighted with red border and will show an error message on the right. | <code>string</code> | - |
| info | An optional info message to describe the form item. It appears on the right side of the item with an info icon. When the icon is hovered, the info message is shown. | <code>string</code> | - |
| onBlur | The callback that will be triggered when the item loses its focus. | <code>(event: FormEvent&lt;boolean>) => void</code> | - |
| onChange | The callback which will be triggered when the `value` of the item changes. | <code>(newValue: boolean) => void</code> | - |
| onFocus | The callback which will be triggered should be called when the item is focused. | <code>(event: FormEvent&lt;boolean>) => void</code> | - |
| storeValue | Indicates whether the value of the item should be persisted after submitting, and restored next time the form is rendered. | <code>boolean</code> | - |
| title | The title displayed on the left side of the item. | <code>string</code> | - |
| value | The current value of the item. | <code>boolean</code> | - |

#### Methods (Imperative API)

| Name  | Signature               | Description                                                                |
| ----- | ----------------------- | -------------------------------------------------------------------------- |
| focus | <code>() => void</code> | Makes the item request focus.                                              |
| reset | <code>() => void</code> | Resets the form item to its initial value, or `defaultValue` if specified. |

### Form.DatePicker

A form item with a date picker.



#### Example

{% tabs %}
{% tab title="Uncontrolled date picker" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Form" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.DatePicker id="dateOfBirth" title="Date of Birth" defaultValue={new Date(1955, 1, 24)} />
    </Form>
  );
}
```

{% endtab %}

{% tab title="Controlled date picker" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";
import { useState } from "react";

export default function Command() {
  const [date, setDate] = useState<Date | null>(null);

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Form" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.DatePicker id="launchDate" title="Launch Date" value={date} onChange={setDate} />
    </Form>
  );
}
```

{% endtab %}
{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| id<mark style="color:red;">*</mark> | ID of the form item.  Make sure to assign each form item a unique id. | <code>string</code> | - |
| autoFocus | Indicates whether the item should be focused automatically once the form is rendered. | <code>boolean</code> | - |
| defaultValue | The default value of the item.  Keep in mind that `defaultValue` will be configured once per component lifecycle. This means that if a user changes the value, `defaultValue` won't be configured on re-rendering.    If you're using `storeValue` and configured it as `true` then the stored value will be set.    If you configure `value` at the same time with `defaultValue`, the `value` will be set instead of `defaultValue`. | <code>[Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)</code> | - |
| error | An optional error message to show the form item validation issues.  If the `error` is present, the Form Item will be highlighted with red border and will show an error message on the right. | <code>string</code> | - |
| info | An optional info message to describe the form item. It appears on the right side of the item with an info icon. When the icon is hovered, the info message is shown. | <code>string</code> | - |
| max | The maximum date (inclusive) allowed for selection.    - If the PickDate type is `Type.Date`, only the full day date will be considered for comparison, ignoring the time components of the Date object.  - If the PickDate type is `Type.DateTime`, both date and time components will be considered for comparison.    The date should be a JavaScript Date object. | <code>[Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)</code> | - |
| min | The minimum date (inclusive) allowed for selection.    - If the PickDate type is `Type.Date`, only the full day date will be considered for comparison, ignoring the time components of the Date object.  - If the PickDate type is `Type.DateTime`, both date and time components will be considered for comparison.    The date should be a JavaScript Date object. | <code>[Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)</code> | - |
| onBlur | The callback that will be triggered when the item loses its focus. | <code>(event: FormEvent&lt;[Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)>) => void</code> | - |
| onChange | The callback which will be triggered when the `value` of the item changes. | <code>(newValue: [Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)) => void</code> | - |
| onFocus | The callback which will be triggered should be called when the item is focused. | <code>(event: FormEvent&lt;[Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)>) => void</code> | - |
| storeValue | Indicates whether the value of the item should be persisted after submitting, and restored next time the form is rendered. | <code>boolean</code> | - |
| title | The title displayed on the left side of the item. | <code>string</code> | - |
| type | Indicates what types of date components can be picked    Defaults to Form.DatePicker.Type.DateTime | <code>Form.DatePicker.Type</code> | - |
| value | The current value of the item. | <code>[Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)</code> | - |

#### Methods (Imperative API)

| Name  | Signature               | Description                                                                |
| ----- | ----------------------- | -------------------------------------------------------------------------- |
| focus | <code>() => void</code> | Makes the item request focus.                                              |
| reset | <code>() => void</code> | Resets the form item to its initial value, or `defaultValue` if specified. |

#### Form.DatePicker.isFullDay

A method that determines if a given date represents a full day or a specific time.

```ts
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm
            title="Create Event"
            onSubmit={(values) => {
              if (Form.DatePicker.isFullDay(values.reminderDate)) {
                // the event is for a full day
              } else {
                // the event is at a specific time
              }
            }}
          />
        </ActionPanel>
      }
    >
      <Form.DatePicker id="eventTitle" title="Title" />
      <Form.DatePicker id="eventDate" title="Date" />
    </Form>
  );
}
```

### Form.Dropdown

A form item with a dropdown menu.



#### Example

{% tabs %}
{% tab title="Uncontrolled dropdown" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Favorite" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.Dropdown id="emoji" title="Favorite Emoji" defaultValue="lol">
        <Form.Dropdown.Item value="poop" title="Pile of poop" icon="💩" />
        <Form.Dropdown.Item value="rocket" title="Rocket" icon="🚀" />
        <Form.Dropdown.Item value="lol" title="Rolling on the floor laughing face" icon="🤣" />
      </Form.Dropdown>
    </Form>
  );
}
```

{% endtab %}

{% tab title="Controlled dropdown" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";
import { useState } from "react";

export default function Command() {
  const [programmingLanguage, setProgrammingLanguage] = useState<string>("typescript");

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Favorite" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.Dropdown
        id="dropdown"
        title="Favorite Language"
        value={programmingLanguage}
        onChange={setProgrammingLanguage}
      >
        <Form.Dropdown.Item value="cpp" title="C++" />
        <Form.Dropdown.Item value="javascript" title="JavaScript" />
        <Form.Dropdown.Item value="ruby" title="Ruby" />
        <Form.Dropdown.Item value="python" title="Python" />
        <Form.Dropdown.Item value="swift" title="Swift" />
        <Form.Dropdown.Item value="typescript" title="TypeScript" />
      </Form.Dropdown>
    </Form>
  );
}
```

{% endtab %}
{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| id<mark style="color:red;">*</mark> | ID of the form item.  Make sure to assign each form item a unique id. | <code>string</code> | - |
| autoFocus | Indicates whether the item should be focused automatically once the form is rendered. | <code>boolean</code> | - |
| children | Sections or items. If Form.Dropdown.Item elements are specified, a default section is automatically created. | <code>React.ReactNode</code> | - |
| defaultValue | The default value of the item.  Keep in mind that `defaultValue` will be configured once per component lifecycle. This means that if a user changes the value, `defaultValue` won't be configured on re-rendering.    If you're using `storeValue` and configured it as `true` then the stored value will be set.    If you configure `value` at the same time with `defaultValue`, the `value` will be set instead of `defaultValue`. | <code>string</code> | - |
| error | An optional error message to show the form item validation issues.  If the `error` is present, the Form Item will be highlighted with red border and will show an error message on the right. | <code>string</code> | - |
| filtering | Toggles Raycast filtering. When `true`, Raycast will use the query in the search bar to filter the  items. When `false`, the extension needs to take care of the filtering.    You can further define how native filtering orders sections by setting an object with a `keepSectionOrder` property:  When `true`, ensures that Raycast filtering maintains the section order as defined in the extension.  When `false`, filtering may change the section order depending on the ranking values of items. | <code>boolean</code> or <code>{ keepSectionOrder: boolean }</code> | - |
| info | An optional info message to describe the form item. It appears on the right side of the item with an info icon. When the icon is hovered, the info message is shown. | <code>string</code> | - |
| isLoading | Indicates whether a loading indicator should be shown or hidden next to the search bar | <code>boolean</code> | - |
| onBlur | The callback that will be triggered when the item loses its focus. | <code>(event: FormEvent&lt;string>) => void</code> | - |
| onChange | The callback which will be triggered when the `value` of the item changes. | <code>(newValue: string) => void</code> | - |
| onFocus | The callback which will be triggered should be called when the item is focused. | <code>(event: FormEvent&lt;string>) => void</code> | - |
| onSearchTextChange | Callback triggered when the search bar text changes. | <code>(text: string) => void</code> | - |
| placeholder | Placeholder text that will be shown in the dropdown search field. | <code>string</code> | - |
| storeValue | Indicates whether the value of the item should be persisted after submitting, and restored next time the form is rendered. | <code>boolean</code> | - |
| throttle | Defines whether the `onSearchTextChange` handler will be triggered on every keyboard press or with a delay for throttling the events.  Recommended to set to `true` when using custom filtering logic with asynchronous operations (e.g. network requests). | <code>boolean</code> | - |
| title | The title displayed on the left side of the item. | <code>string</code> | - |
| value | The current value of the item. | <code>string</code> | - |

#### Methods (Imperative API)

| Name  | Signature               | Description                                                                |
| ----- | ----------------------- | -------------------------------------------------------------------------- |
| focus | <code>() => void</code> | Makes the item request focus.                                              |
| reset | <code>() => void</code> | Resets the form item to its initial value, or `defaultValue` if specified. |

### Form.Dropdown.Item

A dropdown item in a Form.Dropdown

#### Example

```typescript
import { Action, ActionPanel, Form, Icon } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Icon" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.Dropdown id="icon" title="Icon">
        <Form.Dropdown.Item value="circle" title="Cirlce" icon={Icon.Circle} />
      </Form.Dropdown>
    </Form>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The title displayed for the item. | <code>string</code> | - |
| value<mark style="color:red;">*</mark> | Value of the dropdown item.  Make sure to assign each unique value for each item. | <code>string</code> | - |
| icon | A optional icon displayed for the item. | <code>Image.ImageLike</code> | - |
| keywords | An optional property used for providing additional indexable strings for search.  When filtering the items in Raycast, the keywords will be searched in addition to the title. | <code>string[]</code> | - |

### Form.Dropdown.Section

Visually separated group of dropdown items.

Use sections to group related menu items together.

#### Example

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Favorite" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.Dropdown id="food" title="Favorite Food">
        <Form.Dropdown.Section title="Fruits">
          <Form.Dropdown.Item value="apple" title="Apple" icon="🍎" />
          <Form.Dropdown.Item value="banana" title="Banana" icon="🍌" />
        </Form.Dropdown.Section>
        <Form.Dropdown.Section title="Vegetables">
          <Form.Dropdown.Item value="broccoli" title="Broccoli" icon="🥦" />
          <Form.Dropdown.Item value="carrot" title="Carrot" icon="🥕" />
        </Form.Dropdown.Section>
      </Form.Dropdown>
    </Form>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children | The item elements of the section. | <code>React.ReactNode</code> | - |
| title | Title displayed above the section | <code>string</code> | - |

### Form.TagPicker

A form item with a tag picker that allows the user to select multiple items.



#### Example

{% tabs %}
{% tab title="Uncontrolled tag picker" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Favorite" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.TagPicker id="sports" title="Favorite Sports" defaultValue={["football"]}>
        <Form.TagPicker.Item value="basketball" title="Basketball" icon="🏀" />
        <Form.TagPicker.Item value="football" title="Football" icon="⚽️" />
        <Form.TagPicker.Item value="tennis" title="Tennis" icon="🎾" />
      </Form.TagPicker>
    </Form>
  );
}
```

{% endtab %}

{% tab title="Controlled tag picker" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";
import { useState } from "react";

export default function Command() {
  const [countries, setCountries] = useState<string[]>(["ger", "ned", "pol"]);

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Countries" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.TagPicker id="countries" title="Visited Countries" value={countries} onChange={setCountries}>
        <Form.TagPicker.Item value="ger" title="Germany" icon="🇩🇪" />
        <Form.TagPicker.Item value="ind" title="India" icon="🇮🇳" />
        <Form.TagPicker.Item value="ned" title="Netherlands" icon="🇳🇱" />
        <Form.TagPicker.Item value="nor" title="Norway" icon="🇳🇴" />
        <Form.TagPicker.Item value="pol" title="Poland" icon="🇵🇱" />
        <Form.TagPicker.Item value="rus" title="Russia" icon="🇷🇺" />
        <Form.TagPicker.Item value="sco" title="Scotland" icon="🏴󠁧󠁢󠁳󠁣󠁴󠁿" />
      </Form.TagPicker>
    </Form>
  );
}
```

{% endtab %}
{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| id<mark style="color:red;">*</mark> | ID of the form item.  Make sure to assign each form item a unique id. | <code>string</code> | - |
| autoFocus | Indicates whether the item should be focused automatically once the form is rendered. | <code>boolean</code> | - |
| children | The list of tags. | <code>React.ReactNode</code> | - |
| defaultValue | The default value of the item.  Keep in mind that `defaultValue` will be configured once per component lifecycle. This means that if a user changes the value, `defaultValue` won't be configured on re-rendering.    If you're using `storeValue` and configured it as `true` then the stored value will be set.    If you configure `value` at the same time with `defaultValue`, the `value` will be set instead of `defaultValue`. | <code>string[]</code> | - |
| error | An optional error message to show the form item validation issues.  If the `error` is present, the Form Item will be highlighted with red border and will show an error message on the right. | <code>string</code> | - |
| info | An optional info message to describe the form item. It appears on the right side of the item with an info icon. When the icon is hovered, the info message is shown. | <code>string</code> | - |
| onBlur | The callback that will be triggered when the item loses its focus. | <code>(event: FormEvent&lt;string[]>) => void</code> | - |
| onChange | The callback which will be triggered when the `value` of the item changes. | <code>(newValue: string[]) => void</code> | - |
| onFocus | The callback which will be triggered should be called when the item is focused. | <code>(event: FormEvent&lt;string[]>) => void</code> | - |
| placeholder | Placeholder text shown in the token field. | <code>string</code> | - |
| storeValue | Indicates whether the value of the item should be persisted after submitting, and restored next time the form is rendered. | <code>boolean</code> | - |
| title | The title displayed on the left side of the item. | <code>string</code> | - |
| value | The current value of the item. | <code>string[]</code> | - |

#### Methods (Imperative API)

| Name  | Signature               | Description                                                                |
| ----- | ----------------------- | -------------------------------------------------------------------------- |
| focus | <code>() => void</code> | Makes the item request focus.                                              |
| reset | <code>() => void</code> | Resets the form item to its initial value, or `defaultValue` if specified. |

### Form.TagPicker.Item

A tag picker item in a Form.TagPicker.

#### Example

```typescript
import { ActionPanel, Color, Form, Icon, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Color" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.TagPicker id="color" title="Color">
        <Form.TagPicker.Item value="red" title="Red" icon={{ source: Icon.Circle, tintColor: Color.Red }} />
        <Form.TagPicker.Item value="green" title="Green" icon={{ source: Icon.Circle, tintColor: Color.Green }} />
        <Form.TagPicker.Item value="blue" title="Blue" icon={{ source: Icon.Circle, tintColor: Color.Blue }} />
      </Form.TagPicker>
    </Form>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The display title of the tag. | <code>string</code> | - |
| value<mark style="color:red;">*</mark> | Value of the tag.  Make sure to assign unique value for each item. | <code>string</code> | - |
| icon | An icon to show in the tag. | <code>Image.ImageLike</code> | - |

### Form.Separator

A form item that shows a separator line. Use for grouping and visually separating form items.



#### Example

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Form" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.TextField id="textfield" />
      <Form.Separator />
      <Form.TextArea id="textarea" />
    </Form>
  );
}
```

### Form.FilePicker

A form item with a button to open a dialog to pick some files and/or some directories (depending on its props).

{% hint style="info" %}
While the user picked some items that existed, it might be possible for them to be deleted or changed when the `onSubmit` callback is called. Hence you should always make sure that the items exist before acting on them!
{% endhint %}





#### Example

{% tabs %}
{% tab title="Uncontrolled file picker" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";
import fs from "fs";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm
            title="Submit Name"
            onSubmit={(values: { files: string[] }) => {
              const files = values.files.filter((file: any) => fs.existsSync(file) && fs.lstatSync(file).isFile());
              console.log(files);
            }}
          />
        </ActionPanel>
      }
    >
      <Form.FilePicker id="files" />
    </Form>
  );
}
```

{% endtab %}

{% tab title="Single selection file picker" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";
import fs from "fs";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm
            title="Submit Name"
            onSubmit={(values: { files: string[] }) => {
              const file = values.files[0];
              if (!fs.existsSync(file) || !fs.lstatSync(file).isFile()) {
                return false;
              }
              console.log(file);
            }}
          />
        </ActionPanel>
      }
    >
      <Form.FilePicker id="files" allowMultipleSelection={false} />
    </Form>
  );
}
```

{% endtab %}

{% tab title="Directory picker" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";
import fs from "fs";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm
            title="Submit Name"
            onSubmit={(values: { folders: string[] }) => {
              const folder = values.folders[0];
              if (!fs.existsSync(folder) || fs.lstatSync(folder).isDirectory()) {
                return false;
              }
              console.log(folder);
            }}
          />
        </ActionPanel>
      }
    >
      <Form.FilePicker id="folders" allowMultipleSelection={false} canChooseDirectories canChooseFiles={false} />
    </Form>
  );
}
```

{% endtab %}

{% tab title="Controlled file picker" %}

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";
import { useState } from "react";

export default function Command() {
  const [files, setFiles] = useState<string[]>([]);

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Name" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.FilePicker id="files" value={files} onChange={setFiles} />
    </Form>
  );
}
```

{% endtab %}
{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| id<mark style="color:red;">*</mark> | ID of the form item.  Make sure to assign each form item a unique id. | <code>string</code> | - |
| allowMultipleSelection | Indicates whether the user can select multiple items or only one. | <code>boolean</code> | - |
| autoFocus | Indicates whether the item should be focused automatically once the form is rendered. | <code>boolean</code> | - |
| canChooseDirectories | Indicates whether it's possible to choose a directory.  Note: On Windows, this property is ignored if `canChooseFiles` is set to `true`. | <code>boolean</code> | - |
| canChooseFiles | Indicates whether it's possible to choose a file. | <code>boolean</code> | - |
| defaultValue | The default value of the item.  Keep in mind that `defaultValue` will be configured once per component lifecycle. This means that if a user changes the value, `defaultValue` won't be configured on re-rendering.    If you're using `storeValue` and configured it as `true` then the stored value will be set.    If you configure `value` at the same time with `defaultValue`, the `value` will be set instead of `defaultValue`. | <code>string[]</code> | - |
| error | An optional error message to show the form item validation issues.  If the `error` is present, the Form Item will be highlighted with red border and will show an error message on the right. | <code>string</code> | - |
| info | An optional info message to describe the form item. It appears on the right side of the item with an info icon. When the icon is hovered, the info message is shown. | <code>string</code> | - |
| onBlur | The callback that will be triggered when the item loses its focus. | <code>(event: FormEvent&lt;string[]>) => void</code> | - |
| onChange | The callback which will be triggered when the `value` of the item changes. | <code>(newValue: string[]) => void</code> | - |
| onFocus | The callback which will be triggered should be called when the item is focused. | <code>(event: FormEvent&lt;string[]>) => void</code> | - |
| showHiddenFiles | Indicates whether the file picker displays files that are normally hidden from the user. | <code>boolean</code> | - |
| storeValue | Indicates whether the value of the item should be persisted after submitting, and restored next time the form is rendered. | <code>boolean</code> | - |
| title | The title displayed on the left side of the item. | <code>string</code> | - |
| value | The current value of the item. | <code>string[]</code> | - |

#### Methods (Imperative API)

| Name  | Signature               | Description                                                                |
| ----- | ----------------------- | -------------------------------------------------------------------------- |
| focus | <code>() => void</code> | Makes the item request focus.                                              |
| reset | <code>() => void</code> | Resets the form item to its initial value, or `defaultValue` if specified. |

### Form.Description

A form item with a simple text label.

Do _not_ use this component to show validation messages for other form fields.



#### Example

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.Description
        title="Import / Export"
        text="Exporting will back-up your preferences, quicklinks, snippets, floating notes, script-command folder paths, aliases, hotkeys, favorites and other data."
      />
    </Form>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| text<mark style="color:red;">*</mark> | Text that will be displayed in the middle. | <code>string</code> | - |
| title | The display title of the left side from the description item. | <code>string</code> | - |

### Form.LinkAccessory

A link that will be shown in the right-hand side of the navigation bar.

#### Example

```typescript
import { ActionPanel, Form, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      searchBarAccessory={
        <Form.LinkAccessory
          target="https://developers.raycast.com/api-reference/user-interface/form"
          text="Open Documentation"
        />
      }
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit Name" onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.TextField id="name" defaultValue="Steve" />
    </Form>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| target<mark style="color:red;">*</mark> | The target of the link. | <code>string</code> | - |
| text<mark style="color:red;">*</mark> | The text value of the item. | <code>string</code> | - |

## Types

#### Form.Event

Some Form.Item callbacks (like `onFocus` and `onBlur`) can return a `Form.Event` object that you can use in a different ways.

| Property | Description | Type |
| :--- | :--- | :--- |
| target<mark style="color:red;">*</mark> | An interface containing target data related to the event | <code>{ id: string; value?: any }</code> |
| type<mark style="color:red;">*</mark> | A type of event | <code>Form.Event.Type</code> |

#### Example

```typescript
import { Form } from "@raycast/api";

export default function Main() {
  return (
    <Form>
      <Form.TextField id="textField" title="Text Field" onBlur={logEvent} onFocus={logEvent} />
      <Form.TextArea id="textArea" title="Text Area" onBlur={logEvent} onFocus={logEvent} />
      <Form.Dropdown id="dropdown" title="Dropdown" onBlur={logEvent} onFocus={logEvent}>
        {[1, 2, 3, 4, 5, 6, 7].map((num) => (
          <Form.Dropdown.Item value={String(num)} title={String(num)} key={num} />
        ))}
      </Form.Dropdown>
      <Form.TagPicker id="tagPicker" title="Tag Picker" onBlur={logEvent} onFocus={logEvent}>
        {[1, 2, 3, 4, 5, 6, 7].map((num) => (
          <Form.TagPicker.Item value={String(num)} title={String(num)} key={num} />
        ))}
      </Form.TagPicker>
    </Form>
  );
}

function logEvent(event: Form.Event<string[] | string>) {
  console.log(`Event '${event.type}' has happened for '${event.target.id}'. Current 'value': '${event.target.value}'`);
}
```

#### Form.Event.Type

The different types of `Form.Event`. Can be `"focus"` or `"blur"`.

### Form.Values

Values of items in the form.

For type-safe form values, you can define your own interface. Use the ID's of the form items as the property name.

#### Example

```typescript
import { Form, Action, ActionPanel } from "@raycast/api";

interface Values {
  todo: string;
  due?: Date;
}

export default function Command() {
  function handleSubmit(values: Values) {
    console.log(values);
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit" onSubmit={handleSubmit} />
        </ActionPanel>
      }
    >
      <Form.TextField id="todo" title="Todo" />
      <Form.DatePicker id="due" title="Due Date" />
    </Form>
  );
}
```

#### Properties

| Name              | Type  | Required | Description                     |
| ----------------- | ----- | -------- | ------------------------------- |
| \[itemId: string] | `any` | Yes      | The form value of a given item. |

### Form.DatePicker.Type

The types of date components the user can pick with a `Form.DatePicker`.

#### Enumeration members

| Name     | Description                                                      |
| -------- | ---------------------------------------------------------------- |
| DateTime | Hour and second can be picked in addition to year, month and day |
| Date     | Only year, month, and day can be picked                          |

---

## Imperative API

You can use React's [useRef](https://reactjs.org/docs/hooks-reference.html#useref) hook to create variables which have access to imperative APIs (such as `.focus()` or `.reset()`) exposed by the native form items.

```typescript
import { useRef } from "react";
import { ActionPanel, Form, Action } from "@raycast/api";

interface FormValues {
  nameField: string;
  bioTextArea: string;
  datePicker: string;
}

export default function Command() {
  const textFieldRef = useRef<Form.TextField>(null);
  const textAreaRef = useRef<Form.TextArea>(null);
  const datePickerRef = useRef<Form.DatePicker>(null);
  const passwordFieldRef = useRef<Form.PasswordField>(null);
  const dropdownRef = useRef<Form.Dropdown>(null);
  const tagPickerRef = useRef<Form.TagPicker>(null);
  const firstCheckboxRef = useRef<Form.Checkbox>(null);
  const secondCheckboxRef = useRef<Form.Checkbox>(null);

  async function handleSubmit(values: FormValues) {
    console.log(values);
    datePickerRef.current?.focus();
    dropdownRef.current?.reset();
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit" onSubmit={handleSubmit} />
          <ActionPanel.Section title="Focus">
            <Action title="Focus TextField" onAction={() => textFieldRef.current?.focus()} />
            <Action title="Focus TextArea" onAction={() => textAreaRef.current?.focus()} />
            <Action title="Focus DatePicker" onAction={() => datePickerRef.current?.focus()} />
            <Action title="Focus PasswordField" onAction={() => passwordFieldRef.current?.focus()} />
            <Action title="Focus Dropdown" onAction={() => dropdownRef.current?.focus()} />
            <Action title="Focus TagPicker" onAction={() => tagPickerRef.current?.focus()} />
            <Action title="Focus First Checkbox" onAction={() => firstCheckboxRef.current?.focus()} />
            <Action title="Focus Second Checkbox" onAction={() => secondCheckboxRef.current?.focus()} />
          </ActionPanel.Section>
          <ActionPanel.Section title="Reset">
            <Action title="Reset TextField" onAction={() => textFieldRef.current?.reset()} />
            <Action title="Reset TextArea" onAction={() => textAreaRef.current?.reset()} />
            <Action title="Reset DatePicker" onAction={() => datePickerRef.current?.reset()} />
            <Action title="Reset PasswordField" onAction={() => passwordFieldRef.current?.reset()} />
            <Action title="Reset Dropdown" onAction={() => dropdownRef.current?.reset()} />
            <Action title="Reset TagPicker" onAction={() => tagPickerRef.current?.reset()} />
            <Action title="Reset First Checkbox" onAction={() => firstCheckboxRef.current?.reset()} />
            <Action title="Reset Second Checkbox" onAction={() => secondCheckboxRef.current?.reset()} />
          </ActionPanel.Section>
        </ActionPanel>
      }
    >
      <Form.TextField id="textField" title="TextField" ref={textFieldRef} />
      <Form.TextArea id="textArea" title="TextArea" ref={textAreaRef} />
      <Form.DatePicker id="datePicker" title="DatePicker" ref={datePickerRef} />
      <Form.PasswordField id="passwordField" title="PasswordField" ref={passwordFieldRef} />
      <Form.Separator />
      <Form.Dropdown
        id="dropdown"
        title="Dropdown"
        defaultValue="first"
        onChange={(newValue) => {
          console.log(newValue);
        }}
        ref={dropdownRef}
      >
        <Form.Dropdown.Item value="first" title="First" />
        <Form.Dropdown.Item value="second" title="Second" />
      </Form.Dropdown>
      <Form.Separator />
      <Form.TagPicker
        id="tagPicker"
        title="TagPicker"
        ref={tagPickerRef}
        onChange={(t) => {
          console.log(t);
        }}
      >
        {["one", "two", "three"].map((tag) => (
          <Form.TagPicker.Item key={tag} value={tag} title={tag} />
        ))}
      </Form.TagPicker>
      <Form.Separator />
      <Form.Checkbox
        id="firstCheckbox"
        title="First Checkbox"
        label="First Checkbox"
        ref={firstCheckboxRef}
        onChange={(checked) => {
          console.log("first checkbox onChange ", checked);
        }}
      />
      <Form.Checkbox
        id="secondCheckbox"
        title="Second Checkbox"
        label="Second Checkbox"
        ref={secondCheckboxRef}
        onChange={(checked) => {
          console.log("second checkbox onChange ", checked);
        }}
      />
      <Form.Separator />
    </Form>
  );
}
```


# Grid

The `Grid` component is provided as an alternative to the List component when the defining characteristic of an item is an image.

{% hint style="info" %}
Because its API tries to stick as closely to List should be as simple as:

- making sure you're using at least version 1.36.0 of the `@raycast/api` package
- updating your imports from `import { List } from '@raycast/api'` to `import { Grid } from '@raycast/api'`;
- removing the `isShowingDetail` prop from the top-level `List` component, along with all List.Items' `detail` prop
- renaming all List.Items' h`icon` prop to `content`
- removing all List.Item does not _currently_ support accessories
- finally, replacing all usages of `List` with `Grid`.
  {% endhint %}



## Search Bar

The search bar allows users to interact quickly with grid items. By default, Grid.Items matched to the item's `title` or `keywords`.

### Custom filtering

Sometimes, you may not want to rely on Raycast's filtering, but use/implement your own. If that's the case, you can set the `Grid`'s `filtering` prop to false, and the items displayed will be independent of the search bar's text.
Note that `filtering` is also implicitly set to false if an `onSearchTextChange` listener is specified. If you want to specify a change listener and _still_ take advantage of Raycast's built-in filtering, you can explicitly set `filtering` to true.

```typescript
import { useEffect, useState } from "react";
import { Grid } from "@raycast/api";

const items = [
  { content: "🙈", keywords: ["see-no-evil", "monkey"] },
  { content: "🥳", keywords: ["partying", "face"] },
];

export default function Command() {
  const [searchText, setSearchText] = useState("");
  const [filteredList, filterList] = useState(items);

  useEffect(() => {
    filterList(items.filter((item) => item.keywords.some((keyword) => keyword.includes(searchText))));
  }, [searchText]);

  return (
    <Grid
      columns={5}
      inset={Grid.Inset.Large}
      filtering={false}
      onSearchTextChange={setSearchText}
      navigationTitle="Search Emoji"
      searchBarPlaceholder="Search your favorite emoji"
    >
      {filteredList.map((item) => (
        <Grid.Item key={item.content} content={item.content} />
      ))}
    </Grid>
  );
}
```

### Programmatically updating the search bar

Other times, you may want the content of the search bar to be updated by the extension, for example, you may store a list of the user's previous searches and, on the next visit, allow them to "continue" where they left off.

To do so, you can use the `searchText` prop.

```typescript
import { useState } from "react";
import { Action, ActionPanel, Grid } from "@raycast/api";

const items = [
  { content: "🙈", keywords: ["see-no-evil", "monkey"] },
  { content: "🥳", keywords: ["partying", "face"] },
];

export default function Command() {
  const [searchText, setSearchText] = useState("");

  return (
    <Grid
      searchText={searchText}
      onSearchTextChange={setSearchText}
      navigationTitle="Search Emoji"
      searchBarPlaceholder="Search your favorite emoji"
    >
      {items.map((item) => (
        <Grid.Item
          key={item.content}
          content={item.content}
          actions={
            <ActionPanel>
              <Action title="Select" onAction={() => setSearchText(item.content)} />
            </ActionPanel>
          }
        />
      ))}
    </Grid>
  );
}
```

### Dropdown

Some extensions may benefit from giving users a second filtering dimension. A media file management extension may allow users to view only videos or only images, an image-searching extension may allow switching ssearch engines, etc.

This is where the `searchBarAccessory` prop component, and it will be displayed on the right-side of the search bar. Invoke it either by using the global shortcut `⌘` `P` or by clicking on it.

### Pagination

{% hint style="info" %}
Pagination requires version 1.69.0 or higher of the `@raycast/api` package.
{% endhint %}

`Grid`s have built-in support for pagination. To opt in to pagination, you need to pass it a `pagination` prop, which is an object providing 3 pieces of information:

- `onLoadMore` - will be called by Raycast when the user reaches the end of the grid, either using the keyboard or the mouse. When it gets called, the extension is expected to perform an async operation which eventually can result in items being appended to the end of the grid.
- `hasMore` - indicates to Raycast whether it _should_ call `onLoadMore` when the user reaches the end of the grid.
- `pageSize` - indicates how many placeholder items Raycast should add to the end of the grid when it calls `onLoadMore`. Once `onLoadMore` finishes executing, the placeholder items will be replaced by the newly-added grid items.

Note that extensions have access to a limited amount of memory. As your extension paginates, its memory usage will increase. Paginating extensively could lead to the extension eventually running out of memory and crashing. To protect against the extension crashing due to memory exhaustion, Raycast monitors the extension's memory usage and employs heuristics to determine whether it's safe to paginate further. If it's deemed unsafe to continue paginating, `onLoadMore` will not be triggered when the user scrolls to the bottom, regardless of the `hasMore` value. Additionally, during development, a warning will be printed in the terminal.

For convenience, most of the hooks, and one "from scratch".

{% tabs %}

{% tab title="GridWithUsePromisePagination.tsx" %}

```typescript
import { setTimeout } from "node:timers/promises";
import { useState } from "react";
import { Grid } from "@raycast/api";
import { usePromise } from "@raycast/utils";

export default function Command() {
  const [searchText, setSearchText] = useState("");

  const { isLoading, data, pagination } = usePromise(
    (searchText: string) => async (options: { page: number }) => {
      await setTimeout(200);
      const newData = Array.from({ length: 25 }, (_v, index) => ({ index, page: options.page, text: searchText }));
      return { data: newData, hasMore: options.page < 10 };
    },
    [searchText]
  );

  return (
    <Grid isLoading={isLoading} onSearchTextChange={setSearchText} pagination={pagination}>
      {data?.map((item) => (
        <Grid.Item
          key={`${item.index} ${item.page} ${item.text}`}
          content=""
          title={`Page: ${item.page} Item ${item.index}`}
          subtitle={item.text}
        />
      ))}
    </Grid>
  );
}
```

{% endtab %}

{% tab title="GridWithPagination.tsx" %}

```typescript
import { setTimeout } from "node:timers/promises";
import { useCallback, useEffect, useRef, useState } from "react";
import { Grid } from "@raycast/api";

type State = {
  searchText: string;
  isLoading: boolean;
  hasMore: boolean;
  data: {
    index: number;
    page: number;
    text: string;
  }[];
  nextPage: number;
};
const pageSize = 20;
export default function Command() {
  const [state, setState] = useState<State>({ searchText: "", isLoading: true, hasMore: true, data: [], nextPage: 0 });
  const cancelRef = useRef<AbortController | null>(null);

  const loadNextPage = useCallback(async (searchText: string, nextPage: number, signal?: AbortSignal) => {
    setState((previous) => ({ ...previous, isLoading: true }));
    await setTimeout(200);
    const newData = Array.from({ length: pageSize }, (_v, index) => ({
      index,
      page: nextPage,
      text: searchText,
    }));
    if (signal?.aborted) {
      return;
    }
    setState((previous) => ({
      ...previous,
      data: [...previous.data, ...newData],
      isLoading: false,
      hasMore: nextPage < 10,
    }));
  }, []);

  const onLoadMore = useCallback(() => {
    setState((previous) => ({ ...previous, nextPage: previous.nextPage + 1 }));
  }, []);

  const onSearchTextChange = useCallback(
    (searchText: string) => {
      if (searchText === state.searchText) return;
      setState((previous) => ({
        ...previous,
        data: [],
        nextPage: 0,
        searchText,
      }));
    },
    [state.searchText]
  );

  useEffect(() => {
    cancelRef.current?.abort();
    cancelRef.current = new AbortController();
    loadNextPage(state.searchText, state.nextPage, cancelRef.current?.signal);
    return () => {
      cancelRef.current?.abort();
    };
  }, [loadNextPage, state.searchText, state.nextPage]);

  return (
    <Grid
      isLoading={state.isLoading}
      onSearchTextChange={onSearchTextChange}
      pagination={{ onLoadMore, hasMore: state.hasMore, pageSize }}
    >
      {state.data.map((item) => (
        <Grid.Item
          key={`${item.index} ${item.page} ${item.text}`}
          content=""
          title={`Page: ${item.page} Item ${item.index}`}
          subtitle={item.text}
        />
      ))}
    </Grid>
  );
}
```

{% endtab %}

{% endtabs %}

{% hint style="warning" %}
Pagination might not work properly if all grid items are rendered and visible at once, as `onLoadMore` won't be triggered. This typically happens when an API returns 10 results by default, all fitting within the Raycast window. To fix this, try displaying more items, like 20.
{% endhint %}

## Examples

{% tabs %}
{% tab title="Grid.tsx" %}

```jsx
import { Grid } from "@raycast/api";

export default function Command() {
  return (
    <Grid columns={8} inset={Grid.Inset.Large}>
      <Grid.Item content="🥳" />
      <Grid.Item content="🙈" />
    </Grid>
  );
}
```

{% endtab %}

{% tab title="GridWithSections.tsx" %}

```typescript
import { Grid } from "@raycast/api";

export default function Command() {
  return (
    <Grid>
      <Grid.Section title="Section 1">
        <Grid.Item content="https://placekitten.com/400/400" title="Item 1" />
      </Grid.Section>
      <Grid.Section title="Section 2" subtitle="Optional subtitle">
        <Grid.Item content="https://placekitten.com/400/400" title="Item 1" />
      </Grid.Section>
    </Grid>
  );
}
```

{% endtab %}

{% tab title="GridWithActions.tsx" %}

```typescript
import { ActionPanel, Action, Grid } from "@raycast/api";

export default function Command() {
  return (
    <Grid>
      <Grid.Item
        content="https://placekitten.com/400/400"
        title="Item 1"
        actions={
          <ActionPanel>
            <Action.CopyToClipboard content="👋" />
          </ActionPanel>
        }
      />
    </Grid>
  );
}
```

{% endtab %}

{% tab title="GridWithEmptyView.tsx" %}

```typescript
import { useEffect, useState } from "react";
import { Grid, Image } from "@raycast/api";

export default function CommandWithCustomEmptyView() {
  const [state, setState] = useState<{
    searchText: string;
    items: { content: Image.ImageLike; title: string }[];
  }>({ searchText: "", items: [] });

  useEffect(() => {
    console.log("Running effect after state.searchText changed. Current value:", JSON.stringify(state.searchText));
    // perform an API call that eventually populates `items`.
  }, [state.searchText]);

  return (
    <Grid onSearchTextChange={(newValue) => setState((previous) => ({ ...previous, searchText: newValue }))}>
      {state.searchText === "" && state.items.length === 0 ? (
        <Grid.EmptyView icon={{ source: "https://placekitten.com/500/500" }} title="Type something to get started" />
      ) : (
        state.items.map((item, index) => <Grid.Item key={index} content={item.content} title={item.title} />)
      )}
    </Grid>
  );
}
```

{% endtab %}

{% endtabs %}

## API Reference

### Grid

Displays Grid.Sections.

The grid uses built-in filtering by indexing the title & keywords of its items.

#### Example

```typescript
import { Grid } from "@raycast/api";

const items = [
  { content: "🙈", keywords: ["see-no-evil", "monkey"] },
  { content: "🥳", keywords: ["partying", "face"] },
];

export default function Command() {
  return (
    <Grid
      columns={5}
      inset={Grid.Inset.Large}
      navigationTitle="Search Emoji"
      searchBarPlaceholder="Search your favorite emoji"
    >
      {items.map((item) => (
        <Grid.Item key={item.content} content={item.content} keywords={item.keywords} />
      ))}
    </Grid>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| actions | A reference to an ActionPanel. It will only be shown when there aren't any children. | <code>React.ReactNode</code> | - |
| aspectRatio | Aspect ratio for the Grid.Item elements. Defaults to 1. | <code>"1"</code> or <code>"3/2"</code> or <code>"2/3"</code> or <code>"4/3"</code> or <code>"3/4"</code> or <code>"16/9"</code> or <code>"9/16"</code> | - |
| children | Grid sections or items. If Grid.Item elements are specified, a default section is automatically created. | <code>React.ReactNode</code> | - |
| columns | Column count for the grid's sections. Minimum value is 1, maximum value is 8. | <code>number</code> | - |
| filtering | Toggles Raycast filtering. When `true`, Raycast will use the query in the search bar to filter the  items. When `false`, the extension needs to take care of the filtering.    You can further define how native filtering orders sections by setting an object with a `keepSectionOrder` property:  When `true`, ensures that Raycast filtering maintains the section order as defined in the extension.  When `false`, filtering may change the section order depending on the ranking values of items. | <code>boolean</code> or <code>{ keepSectionOrder: boolean }</code> | - |
| fit | Fit for the Grid.Item element content. Defaults to "contain" | <code>Grid.Fit</code> | - |
| inset | Indicates how much space there should be between a Grid.Items' content and its borders.  The absolute value depends on the value of the `itemSize` prop. | <code>Grid.Inset</code> | - |
| isLoading | Indicates whether a loading bar should be shown or hidden below the search bar | <code>boolean</code> | - |
| navigationTitle | The main title for that view displayed in Raycast | <code>string</code> | - |
| onSearchTextChange | Callback triggered when the search bar text changes. | <code>(text: string) => void</code> | - |
| onSelectionChange | Callback triggered when the item selection in the grid changes.    When the received id is `null`, it means that all items have been filtered out  and that there are no item selected | <code>(id: string) => void</code> | - |
| pagination | Configuration for pagination | <code>{ hasMore: boolean; onLoadMore: () => void; pageSize: number }</code> | - |
| searchBarAccessory | Grid.Dropdown that will be shown in the right-hand-side of the search bar. | <code>ReactElement&lt;List.Dropdown.Props, string></code> | - |
| searchBarPlaceholder | Placeholder text that will be shown in the search bar. | <code>string</code> | - |
| searchText | The text that will be displayed in the search bar. | <code>string</code> | - |
| selectedItemId | Selects the item with the specified id. | <code>string</code> | - |
| throttle | Defines whether the `onSearchTextChange` handler will be triggered on every keyboard press or with a delay for throttling the events.  Recommended to set to `true` when using custom filtering logic with asynchronous operations (e.g. network requests). | <code>boolean</code> | - |

### Grid.Dropdown

A dropdown menu that will be shown in the right-hand-side of the search bar.

#### Example

```typescript
import { Grid, Image } from "@raycast/api";
import { useState } from "react";

const types = [
  { id: 1, name: "Smileys", value: "smileys" },
  { id: 2, name: "Animals & Nature", value: "animals-and-nature" },
];

const items: { [key: string]: { content: Image.ImageLike; keywords: string[] }[] } = {
  smileys: [{ content: "🥳", keywords: ["partying", "face"] }],
  "animals-and-nature": [{ content: "🙈", keywords: ["see-no-evil", "monkey"] }],
};

export default function Command() {
  const [type, setType] = useState<string>("smileys");

  return (
    <Grid
      navigationTitle="Search Beers"
      searchBarPlaceholder="Search your favorite drink"
      searchBarAccessory={
        <Grid.Dropdown tooltip="Select Emoji Category" storeValue={true} onChange={(newValue) => setType(newValue)}>
          <Grid.Dropdown.Section title="Emoji Categories">
            {types.map((type) => (
              <Grid.Dropdown.Item key={type.id} title={type.name} value={type.value} />
            ))}
          </Grid.Dropdown.Section>
        </Grid.Dropdown>
      }
    >
      {(items[type] || []).map((item) => (
        <Grid.Item key={`${item.content}`} content={item.content} keywords={item.keywords} />
      ))}
    </Grid>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| tooltip<mark style="color:red;">*</mark> | Tooltip displayed when hovering the dropdown. | <code>string</code> | - |
| children | Dropdown sections or items. If Dropdown.Item elements are specified, a default section is automatically created. | <code>React.ReactNode</code> | - |
| defaultValue | The default value of the dropdown.  Keep in mind that `defaultValue` will be configured once per component lifecycle. This means that if a user changes the value, `defaultValue` won't be configured on re-rendering.    **If you're using `storeValue` and configured it as `true` _and_ a Dropdown.Item with the same value exists, then it will be selected.**    **If you configure `value` at the same time as `defaultValue`, the `value` will have precedence over `defaultValue`.** | <code>string</code> | - |
| filtering | Toggles Raycast filtering. When `true`, Raycast will use the query in the search bar to filter the  items. When `false`, the extension needs to take care of the filtering.    You can further define how native filtering orders sections by setting an object with a `keepSectionOrder` property:  When `true`, ensures that Raycast filtering maintains the section order as defined in the extension.  When `false`, filtering may change the section order depending on the ranking values of items. | <code>boolean</code> or <code>{ keepSectionOrder: boolean }</code> | - |
| id | ID of the dropdown. | <code>string</code> | - |
| isLoading | Indicates whether a loading indicator should be shown or hidden next to the search bar | <code>boolean</code> | - |
| onChange | Callback triggered when the dropdown selection changes. | <code>(newValue: string) => void</code> | - |
| onSearchTextChange | Callback triggered when the search bar text changes. | <code>(text: string) => void</code> | - |
| placeholder | Placeholder text that will be shown in the dropdown search field. | <code>string</code> | - |
| storeValue | Indicates whether the value of the dropdown should be persisted after selection, and restored next time the dropdown is rendered. | <code>boolean</code> | - |
| throttle | Defines whether the `onSearchTextChange` handler will be triggered on every keyboard press or with a delay for throttling the events.  Recommended to set to `true` when using custom filtering logic with asynchronous operations (e.g. network requests). | <code>boolean</code> | - |
| value | The currently value of the dropdown. | <code>string</code> | - |

### Grid.Dropdown.Item

A dropdown item in a Grid.Dropdown

#### Example

```typescript
import { Grid } from "@raycast/api";

export default function Command() {
  return (
    <Grid
      searchBarAccessory={
        <Grid.Dropdown tooltip="Dropdown With Items">
          <Grid.Dropdown.Item title="One" value="one" />
          <Grid.Dropdown.Item title="Two" value="two" />
          <Grid.Dropdown.Item title="Three" value="three" />
        </Grid.Dropdown>
      }
    >
      <Grid.Item content="https://placekitten.com/400/400" title="Item in the Main Grid" />
    </Grid>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The title displayed for the item. | <code>string</code> | - |
| value<mark style="color:red;">*</mark> | Value of the dropdown item.  Make sure to assign each unique value for each item. | <code>string</code> | - |
| icon | An optional icon displayed for the item. | <code>Image.ImageLike</code> | - |
| keywords | An optional property used for providing additional indexable strings for search.  When filtering the items in Raycast, the keywords will be searched in addition to the title. | <code>string[]</code> | - |

### Grid.Dropdown.Section

Visually separated group of dropdown items.

Use sections to group related menu items together.

#### Example

```typescript
import { Grid } from "@raycast/api";

export default function Command() {
  return (
    <Grid
      searchBarAccessory={
        <Grid.Dropdown tooltip="Dropdown With Sections">
          <Grid.Dropdown.Section title="First Section">
            <Grid.Dropdown.Item title="One" value="one" />
          </Grid.Dropdown.Section>
          <Grid.Dropdown.Section title="Second Section">
            <Grid.Dropdown.Item title="Two" value="two" />
          </Grid.Dropdown.Section>
        </Grid.Dropdown>
      }
    >
      <Grid.Item content="https://placekitten.com/400/400" title="Item in the Main Grid" />
    </Grid>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children | The item elements of the section. | <code>React.ReactNode</code> | - |
| title | Title displayed above the section | <code>string</code> | - |

### Grid.EmptyView

A view to display when there aren't any items available. Use to greet users with a friendly message if the
extension requires user input before it can show any items e.g. when searching for an image, a gif etc.

Raycast provides a default `EmptyView` that will be displayed if the Grid component either has no children,
or if it has children, but none of them match the query in the search bar. This too can be overridden by passing an
empty view alongside the other `Grid.Item`s.

Note that the `EmptyView` is _never_ displayed if the `Grid`'s `isLoading` property is true and the search bar is empty.



#### Example

```typescript
import { useEffect, useState } from "react";
import { Grid, Image } from "@raycast/api";

export default function CommandWithCustomEmptyView() {
  const [state, setState] = useState<{
    searchText: string;
    items: { content: Image.ImageLike; title: string }[];
  }>({ searchText: "", items: [] });

  useEffect(() => {
    console.log("Running effect after state.searchText changed. Current value:", JSON.stringify(state.searchText));
    // perform an API call that eventually populates `items`.
  }, [state.searchText]);

  return (
    <Grid onSearchTextChange={(newValue) => setState((previous) => ({ ...previous, searchText: newValue }))}>
      {state.searchText === "" && state.items.length === 0 ? (
        <Grid.EmptyView icon={{ source: "https://placekitten.com/500/500" }} title="Type something to get started" />
      ) : (
        state.items.map((item, index) => <Grid.Item key={index} content={item.content} title={item.title} />)
      )}
    </Grid>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| actions | A reference to an ActionPanel. | <code>React.ReactNode</code> | - |
| description | An optional description for why the empty view is shown. | <code>string</code> | - |
| icon | An icon displayed in the center of the EmptyView. | <code>Image.ImageLike</code> | - |
| title | The main title displayed for the Empty View. | <code>string</code> | - |

### Grid.Item

A item in the Grid.

This is one of the foundational UI components of Raycast. A grid item represents a single entity. It can be an image, an emoji, a GIF etc. You most likely want to perform actions on this item, so make it clear
to the user what this item is about.

#### Example

```typescript
import { Grid } from "@raycast/api";

export default function Command() {
  return (
    <Grid>
      <Grid.Item content="🥳" title="Partying Face" subtitle="Smiley" />
    </Grid>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| content<mark style="color:red;">*</mark> | An image or color, optionally with a tooltip, representing the content of the grid item. | <code>Image.ImageLike }</code> or <code>{ tooltip: string; value: Image.ImageLike</code> or <code>{ color: Color.ColorLike; } }</code> | - |
| accessory | An optional Grid.Item.Accessory item displayed underneath a Grid.Item. | <code>Grid.Item.Accessory</code> | - |
| actions | An ActionPanel that will be updated for the selected grid item. | <code>React.ReactNode</code> | - |
| id | ID of the item. This string is passed to the `onSelectionChange` handler of the Grid when the item is selected.  Make sure to assign each item a unique ID or a UUID will be auto generated. | <code>string</code> | - |
| keywords | An optional property used for providing additional indexable strings for search.  When filtering the list in Raycast through the search bar, the keywords will be searched in addition to the title. | <code>string[]</code> | - |
| quickLook | Optional information to preview files with Quick Look. Toggle the preview ith Action.ToggleQuickLook. | <code>{ name?: string; path: "fs".PathLike }</code> | - |
| subtitle | An optional subtitle displayed below the title. | <code>string</code> | - |
| title | An optional title displayed below the content. | <code>string</code> | - |

### Grid.Section

A group of related Grid.Item.

Sections are a great way to structure your grid. For example, you can group photos taken in the same place or in the same day. This way, the user can quickly access what is most relevant.

Sections can specify their own `columns`, `fit`, `aspectRatio` and `inset` props, separate from what is defined on the main Grid component.

#### Example



{% tabs %}
{% tab title="GridWithSection.tsx" %}

```typescript
import { Grid } from "@raycast/api";

export default function Command() {
  return (
    <Grid>
      <Grid.Section title="Section 1">
        <Grid.Item content="https://placekitten.com/400/400" title="Item 1" />
      </Grid.Section>
      <Grid.Section title="Section 2" subtitle="Optional subtitle">
        <Grid.Item content="https://placekitten.com/400/400" title="Item 1" />
      </Grid.Section>
    </Grid>
  );
}
```

{% endtab %}
{% tab title="GridWithStyledSection.tsx" %}

```typescript
import { Grid, Color } from "@raycast/api";

export default function Command() {
  return (
    <Grid columns={6}>
      <Grid.Section aspectRatio="2/3" title="Movies">
        <Grid.Item content="https://api.lorem.space/image/movie?w=150&h=220" />
        <Grid.Item content="https://api.lorem.space/image/movie?w=150&h=220" />
        <Grid.Item content="https://api.lorem.space/image/movie?w=150&h=220" />
        <Grid.Item content="https://api.lorem.space/image/movie?w=150&h=220" />
        <Grid.Item content="https://api.lorem.space/image/movie?w=150&h=220" />
        <Grid.Item content="https://api.lorem.space/image/movie?w=150&h=220" />
      </Grid.Section>
      <Grid.Section columns={8} title="Colors">
        {Object.entries(Color).map(([key, value]) => (
          <Grid.Item key={key} content={{ color: value }} title={key} />
        ))}
      </Grid.Section>
    </Grid>
  );
}
```

{% endtab %}

{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| aspectRatio | Aspect ratio for the Grid.Item elements. Defaults to 1. | <code>"1"</code> or <code>"3/2"</code> or <code>"2/3"</code> or <code>"4/3"</code> or <code>"3/4"</code> or <code>"16/9"</code> or <code>"9/16"</code> | - |
| children | The Grid.Item elements of the section. | <code>React.ReactNode</code> | - |
| columns | Column count for the section. Minimum value is 1, maximum value is 8. | <code>number</code> | - |
| fit | Fit for the Grid.Item element content. Defaults to "contain" | <code>Grid.Fit</code> | - |
| inset | Inset for the Grid.Item element content. Defaults to "none". | <code>Grid.Inset</code> | - |
| subtitle | An optional subtitle displayed next to the title of the section. | <code>string</code> | - |
| title | Title displayed above the section. | <code>string</code> | - |

## Types

### Grid.Item.Accessory

An interface describing an accessory view in a `Grid.Item`.



### Grid.Inset

An enum representing the amount of space there should be between a Grid Item's content and its borders. The absolute value depends on the value of Grid's `columns` prop.

#### Enumeration members

| Name   | Description   |
| ------ | ------------- |
| Small  | Small insets  |
| Medium | Medium insets |
| Large  | Large insets  |

### Grid.ItemSize (deprecated)

An enum representing the size of the Grid's child Grid.Items.

#### Enumeration members

| Name   | Description           |
| ------ | --------------------- |
| Small  | Fits 8 items per row. |
| Medium | Fits 5 items per row. |
| Large  | Fits 3 items per row. |

### Grid.Fit

An enum representing how Grid.Item's content should be fit.

#### Enumeration members

| Name    | Description                                                                                                                     |
| ------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Contain | The content will be contained within the grid cell, with vertical/horizontal bars if its aspect ratio differs from the cell's.  |
| Fill    | The content will be scaled proportionally so that it fill the entire cell; parts of the content could end up being cropped out. |


# Icons & Images

## API Reference

### Icon

List of built-in icons that can be used for actions or list items.

#### Example

```typescript
import { Icon, List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item title="Icon" icon={Icon.Circle} />
    </List>
  );
}
```

#### Enumeration members

| <p><picture><source srcset="../../.gitbook/assets/icon-add-person-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-add-person-16@light.svg" alt=""></picture><br>AddPerson</p> | <p><picture><source srcset="../../.gitbook/assets/icon-airplane-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-airplane-16@light.svg" alt=""></picture><br>Airplane</p> | <p><picture><source srcset="../../.gitbook/assets/icon-airplane-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-airplane-filled-16@light.svg" alt=""></picture><br>AirplaneFilled</p> |
| :---: | :---: | :---: |
| <p><picture><source srcset="../../.gitbook/assets/icon-airplane-landing-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-airplane-landing-16@light.svg" alt=""></picture><br>AirplaneLanding</p> | <p><picture><source srcset="../../.gitbook/assets/icon-airplane-takeoff-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-airplane-takeoff-16@light.svg" alt=""></picture><br>AirplaneTakeoff</p> | <p><picture><source srcset="../../.gitbook/assets/icon-airpods-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-airpods-16@light.svg" alt=""></picture><br>Airpods</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-alarm-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-alarm-16@light.svg" alt=""></picture><br>Alarm</p> | <p><picture><source srcset="../../.gitbook/assets/icon-alarm-ringing-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-alarm-ringing-16@light.svg" alt=""></picture><br>AlarmRinging</p> | <p><picture><source srcset="../../.gitbook/assets/icon-align-centre-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-align-centre-16@light.svg" alt=""></picture><br>AlignCentre</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-align-left-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-align-left-16@light.svg" alt=""></picture><br>AlignLeft</p> | <p><picture><source srcset="../../.gitbook/assets/icon-align-right-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-align-right-16@light.svg" alt=""></picture><br>AlignRight</p> | <p><picture><source srcset="../../.gitbook/assets/icon-american-football-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-american-football-16@light.svg" alt=""></picture><br>AmericanFootball</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-anchor-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-anchor-16@light.svg" alt=""></picture><br>Anchor</p> | <p><picture><source srcset="../../.gitbook/assets/icon-app-window-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-app-window-16@light.svg" alt=""></picture><br>AppWindow</p> | <p><picture><source srcset="../../.gitbook/assets/icon-app-window-grid-2x2-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-app-window-grid-2x2-16@light.svg" alt=""></picture><br>AppWindowGrid2x2</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-app-window-grid-3x3-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-app-window-grid-3x3-16@light.svg" alt=""></picture><br>AppWindowGrid3x3</p> | <p><picture><source srcset="../../.gitbook/assets/icon-app-window-list-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-app-window-list-16@light.svg" alt=""></picture><br>AppWindowList</p> | <p><picture><source srcset="../../.gitbook/assets/icon-app-window-sidebar-left-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-app-window-sidebar-left-16@light.svg" alt=""></picture><br>AppWindowSidebarLeft</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-app-window-sidebar-right-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-app-window-sidebar-right-16@light.svg" alt=""></picture><br>AppWindowSidebarRight</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrow-clockwise-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-clockwise-16@light.svg" alt=""></picture><br>ArrowClockwise</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrow-counter-clockwise-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-counter-clockwise-16@light.svg" alt=""></picture><br>ArrowCounterClockwise</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-arrow-down-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-down-16@light.svg" alt=""></picture><br>ArrowDown</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrow-down-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-down-circle-16@light.svg" alt=""></picture><br>ArrowDownCircle</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrow-down-circle-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-down-circle-filled-16@light.svg" alt=""></picture><br>ArrowDownCircleFilled</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-arrow-left-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-left-16@light.svg" alt=""></picture><br>ArrowLeft</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrow-left-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-left-circle-16@light.svg" alt=""></picture><br>ArrowLeftCircle</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrow-left-circle-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-left-circle-filled-16@light.svg" alt=""></picture><br>ArrowLeftCircleFilled</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-arrow-ne-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-ne-16@light.svg" alt=""></picture><br>ArrowNe</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrow-right-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-right-16@light.svg" alt=""></picture><br>ArrowRight</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrow-right-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-right-circle-16@light.svg" alt=""></picture><br>ArrowRightCircle</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-arrow-right-circle-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-right-circle-filled-16@light.svg" alt=""></picture><br>ArrowRightCircleFilled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrow-up-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-up-16@light.svg" alt=""></picture><br>ArrowUp</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrow-up-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-up-circle-16@light.svg" alt=""></picture><br>ArrowUpCircle</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-arrow-up-circle-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrow-up-circle-filled-16@light.svg" alt=""></picture><br>ArrowUpCircleFilled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrows-contract-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrows-contract-16@light.svg" alt=""></picture><br>ArrowsContract</p> | <p><picture><source srcset="../../.gitbook/assets/icon-arrows-expand-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-arrows-expand-16@light.svg" alt=""></picture><br>ArrowsExpand</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-at-symbol-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-at-symbol-16@light.svg" alt=""></picture><br>AtSymbol</p> | <p><picture><source srcset="../../.gitbook/assets/icon-band-aid-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-band-aid-16@light.svg" alt=""></picture><br>BandAid</p> | <p><picture><source srcset="../../.gitbook/assets/icon-bank-note-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bank-note-16@light.svg" alt=""></picture><br>BankNote</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-bar-chart-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bar-chart-16@light.svg" alt=""></picture><br>BarChart</p> | <p><picture><source srcset="../../.gitbook/assets/icon-bar-code-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bar-code-16@light.svg" alt=""></picture><br>BarCode</p> | <p><picture><source srcset="../../.gitbook/assets/icon-bath-tub-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bath-tub-16@light.svg" alt=""></picture><br>BathTub</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-battery-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-battery-16@light.svg" alt=""></picture><br>Battery</p> | <p><picture><source srcset="../../.gitbook/assets/icon-battery-charging-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-battery-charging-16@light.svg" alt=""></picture><br>BatteryCharging</p> | <p><picture><source srcset="../../.gitbook/assets/icon-battery-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-battery-disabled-16@light.svg" alt=""></picture><br>BatteryDisabled</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-bell-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bell-16@light.svg" alt=""></picture><br>Bell</p> | <p><picture><source srcset="../../.gitbook/assets/icon-bell-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bell-disabled-16@light.svg" alt=""></picture><br>BellDisabled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-bike-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bike-16@light.svg" alt=""></picture><br>Bike</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-binoculars-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-binoculars-16@light.svg" alt=""></picture><br>Binoculars</p> | <p><picture><source srcset="../../.gitbook/assets/icon-bird-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bird-16@light.svg" alt=""></picture><br>Bird</p> | <p><picture><source srcset="../../.gitbook/assets/icon-blank-document-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-blank-document-16@light.svg" alt=""></picture><br>BlankDocument</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-bluetooth-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bluetooth-16@light.svg" alt=""></picture><br>Bluetooth</p> | <p><picture><source srcset="../../.gitbook/assets/icon-boat-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-boat-16@light.svg" alt=""></picture><br>Boat</p> | <p><picture><source srcset="../../.gitbook/assets/icon-bold-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bold-16@light.svg" alt=""></picture><br>Bold</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-bolt-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bolt-16@light.svg" alt=""></picture><br>Bolt</p> | <p><picture><source srcset="../../.gitbook/assets/icon-bolt-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bolt-disabled-16@light.svg" alt=""></picture><br>BoltDisabled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-book-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-book-16@light.svg" alt=""></picture><br>Book</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-bookmark-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bookmark-16@light.svg" alt=""></picture><br>Bookmark</p> | <p><picture><source srcset="../../.gitbook/assets/icon-box-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-box-16@light.svg" alt=""></picture><br>Box</p> | <p><picture><source srcset="../../.gitbook/assets/icon-brush-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-brush-16@light.svg" alt=""></picture><br>Brush</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-speech-bubble-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speech-bubble-16@light.svg" alt=""></picture><br>Bubble</p> | <p><picture><source srcset="../../.gitbook/assets/icon-bug-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bug-16@light.svg" alt=""></picture><br>Bug</p> | <p><picture><source srcset="../../.gitbook/assets/icon-building-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-building-16@light.svg" alt=""></picture><br>Building</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-bullet-points-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bullet-points-16@light.svg" alt=""></picture><br>BulletPoints</p> | <p><picture><source srcset="../../.gitbook/assets/icon-bulls-eye-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bulls-eye-16@light.svg" alt=""></picture><br>BullsEye</p> | <p><picture><source srcset="../../.gitbook/assets/icon-bulls-eye-missed-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-bulls-eye-missed-16@light.svg" alt=""></picture><br>BullsEyeMissed</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-buoy-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-buoy-16@light.svg" alt=""></picture><br>Buoy</p> | <p><picture><source srcset="../../.gitbook/assets/icon-calculator-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-calculator-16@light.svg" alt=""></picture><br>Calculator</p> | <p><picture><source srcset="../../.gitbook/assets/icon-calendar-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-calendar-16@light.svg" alt=""></picture><br>Calendar</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-camera-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-camera-16@light.svg" alt=""></picture><br>Camera</p> | <p><picture><source srcset="../../.gitbook/assets/icon-car-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-car-16@light.svg" alt=""></picture><br>Car</p> | <p><picture><source srcset="../../.gitbook/assets/icon-cart-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-cart-16@light.svg" alt=""></picture><br>Cart</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-cd-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-cd-16@light.svg" alt=""></picture><br>Cd</p> | <p><picture><source srcset="../../.gitbook/assets/icon-center-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-center-16@light.svg" alt=""></picture><br>Center</p> | <p><picture><source srcset="../../.gitbook/assets/icon-check-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-check-16@light.svg" alt=""></picture><br>Check</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-check-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-check-circle-16@light.svg" alt=""></picture><br>CheckCircle</p> | <p><picture><source srcset="../../.gitbook/assets/icon-check-list-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-check-list-16@light.svg" alt=""></picture><br>CheckList</p> | <p><picture><source srcset="../../.gitbook/assets/icon-check-rosette-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-check-rosette-16@light.svg" alt=""></picture><br>CheckRosette</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-checkmark-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-checkmark-16@light.svg" alt=""></picture><br>Checkmark</p> | <p><picture><source srcset="../../.gitbook/assets/icon-chess-piece-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-chess-piece-16@light.svg" alt=""></picture><br>ChessPiece</p> | <p><picture><source srcset="../../.gitbook/assets/icon-chevron-down-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-chevron-down-16@light.svg" alt=""></picture><br>ChevronDown</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-chevron-down-small-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-chevron-down-small-16@light.svg" alt=""></picture><br>ChevronDownSmall</p> | <p><picture><source srcset="../../.gitbook/assets/icon-chevron-left-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-chevron-left-16@light.svg" alt=""></picture><br>ChevronLeft</p> | <p><picture><source srcset="../../.gitbook/assets/icon-chevron-left-small-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-chevron-left-small-16@light.svg" alt=""></picture><br>ChevronLeftSmall</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-chevron-right-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-chevron-right-16@light.svg" alt=""></picture><br>ChevronRight</p> | <p><picture><source srcset="../../.gitbook/assets/icon-chevron-right-small-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-chevron-right-small-16@light.svg" alt=""></picture><br>ChevronRightSmall</p> | <p><picture><source srcset="../../.gitbook/assets/icon-chevron-up-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-chevron-up-16@light.svg" alt=""></picture><br>ChevronUp</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-chevron-up-down-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-chevron-up-down-16@light.svg" alt=""></picture><br>ChevronUpDown</p> | <p><picture><source srcset="../../.gitbook/assets/icon-chevron-up-small-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-chevron-up-small-16@light.svg" alt=""></picture><br>ChevronUpSmall</p> | <p><picture><source srcset="../../.gitbook/assets/icon-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-circle-16@light.svg" alt=""></picture><br>Circle</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-circle-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-circle-disabled-16@light.svg" alt=""></picture><br>CircleDisabled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-circle-ellipsis-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-circle-ellipsis-16@light.svg" alt=""></picture><br>CircleEllipsis</p> | <p><picture><source srcset="../../.gitbook/assets/icon-circle-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-circle-filled-16@light.svg" alt=""></picture><br>CircleFilled</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-circle-progress-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-circle-progress-16@light.svg" alt=""></picture><br>CircleProgress</p> | <p><picture><source srcset="../../.gitbook/assets/icon-circle-progress-100-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-circle-progress-100-16@light.svg" alt=""></picture><br>CircleProgress100</p> | <p><picture><source srcset="../../.gitbook/assets/icon-circle-progress-25-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-circle-progress-25-16@light.svg" alt=""></picture><br>CircleProgress25</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-circle-progress-50-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-circle-progress-50-16@light.svg" alt=""></picture><br>CircleProgress50</p> | <p><picture><source srcset="../../.gitbook/assets/icon-circle-progress-75-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-circle-progress-75-16@light.svg" alt=""></picture><br>CircleProgress75</p> | <p><picture><source srcset="../../.gitbook/assets/icon-clear-formatting-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-clear-formatting-16@light.svg" alt=""></picture><br>ClearFormatting</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-copy-clipboard-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-copy-clipboard-16@light.svg" alt=""></picture><br>Clipboard</p> | <p><picture><source srcset="../../.gitbook/assets/icon-clock-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-clock-16@light.svg" alt=""></picture><br>Clock</p> | <p><picture><source srcset="../../.gitbook/assets/icon-cloud-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-cloud-16@light.svg" alt=""></picture><br>Cloud</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-cloud-lightning-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-cloud-lightning-16@light.svg" alt=""></picture><br>CloudLightning</p> | <p><picture><source srcset="../../.gitbook/assets/icon-cloud-rain-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-cloud-rain-16@light.svg" alt=""></picture><br>CloudRain</p> | <p><picture><source srcset="../../.gitbook/assets/icon-cloud-snow-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-cloud-snow-16@light.svg" alt=""></picture><br>CloudSnow</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-cloud-sun-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-cloud-sun-16@light.svg" alt=""></picture><br>CloudSun</p> | <p><picture><source srcset="../../.gitbook/assets/icon-code-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-code-16@light.svg" alt=""></picture><br>Code</p> | <p><picture><source srcset="../../.gitbook/assets/icon-code-block-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-code-block-16@light.svg" alt=""></picture><br>CodeBlock</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-cog-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-cog-16@light.svg" alt=""></picture><br>Cog</p> | <p><picture><source srcset="../../.gitbook/assets/icon-coin-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-coin-16@light.svg" alt=""></picture><br>Coin</p> | <p><picture><source srcset="../../.gitbook/assets/icon-coins-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-coins-16@light.svg" alt=""></picture><br>Coins</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-command-symbol-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-command-symbol-16@light.svg" alt=""></picture><br>CommandSymbol</p> | <p><picture><source srcset="../../.gitbook/assets/icon-compass-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-compass-16@light.svg" alt=""></picture><br>Compass</p> | <p><picture><source srcset="../../.gitbook/assets/icon-computer-chip-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-computer-chip-16@light.svg" alt=""></picture><br>ComputerChip</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-contrast-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-contrast-16@light.svg" alt=""></picture><br>Contrast</p> | <p><picture><source srcset="../../.gitbook/assets/icon-copy-clipboard-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-copy-clipboard-16@light.svg" alt=""></picture><br>CopyClipboard</p> | <p><picture><source srcset="../../.gitbook/assets/icon-credit-card-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-credit-card-16@light.svg" alt=""></picture><br>CreditCard</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-cricket-ball-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-cricket-ball-16@light.svg" alt=""></picture><br>CricketBall</p> | <p><picture><source srcset="../../.gitbook/assets/icon-crop-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-crop-16@light.svg" alt=""></picture><br>Crop</p> | <p><picture><source srcset="../../.gitbook/assets/icon-crown-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-crown-16@light.svg" alt=""></picture><br>Crown</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-crypto-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-crypto-16@light.svg" alt=""></picture><br>Crypto</p> | <p><picture><source srcset="../../.gitbook/assets/icon-delete-document-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-delete-document-16@light.svg" alt=""></picture><br>DeleteDocument</p> | <p><picture><source srcset="../../.gitbook/assets/icon-desktop-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-desktop-16@light.svg" alt=""></picture><br>Desktop</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-devices-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-devices-16@light.svg" alt=""></picture><br>Devices</p> | <p><picture><source srcset="../../.gitbook/assets/icon-dna-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-dna-16@light.svg" alt=""></picture><br>Dna</p> | <p><picture><source srcset="../../.gitbook/assets/icon-blank-document-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-blank-document-16@light.svg" alt=""></picture><br>Document</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-dot-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-dot-16@light.svg" alt=""></picture><br>Dot</p> | <p><picture><source srcset="../../.gitbook/assets/icon-download-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-download-16@light.svg" alt=""></picture><br>Download</p> | <p><picture><source srcset="../../.gitbook/assets/icon-droplets-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-droplets-16@light.svg" alt=""></picture><br>Droplets</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-duplicate-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-duplicate-16@light.svg" alt=""></picture><br>Duplicate</p> | <p><picture><source srcset="../../.gitbook/assets/icon-edit-shape-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-edit-shape-16@light.svg" alt=""></picture><br>EditShape</p> | <p><picture><source srcset="../../.gitbook/assets/icon-eject-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-eject-16@light.svg" alt=""></picture><br>Eject</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-ellipsis-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-ellipsis-16@light.svg" alt=""></picture><br>Ellipsis</p> | <p><picture><source srcset="../../.gitbook/assets/icon-ellipsis-vertical-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-ellipsis-vertical-16@light.svg" alt=""></picture><br>EllipsisVertical</p> | <p><picture><source srcset="../../.gitbook/assets/icon-emoji-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-emoji-16@light.svg" alt=""></picture><br>Emoji</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-emoji-sad-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-emoji-sad-16@light.svg" alt=""></picture><br>EmojiSad</p> | <p><picture><source srcset="../../.gitbook/assets/icon-envelope-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-envelope-16@light.svg" alt=""></picture><br>Envelope</p> | <p><picture><source srcset="../../.gitbook/assets/icon-eraser-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-eraser-16@light.svg" alt=""></picture><br>Eraser</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-important-01-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-important-01-16@light.svg" alt=""></picture><br>ExclamationMark</p> | <p><picture><source srcset="../../.gitbook/assets/icon-exclamationmark-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-exclamationmark-16@light.svg" alt=""></picture><br>Exclamationmark</p> | <p><picture><source srcset="../../.gitbook/assets/icon-exclamationmark-2-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-exclamationmark-2-16@light.svg" alt=""></picture><br>Exclamationmark2</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-exclamationmark-3-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-exclamationmark-3-16@light.svg" alt=""></picture><br>Exclamationmark3</p> | <p><picture><source srcset="../../.gitbook/assets/icon-eye-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-eye-16@light.svg" alt=""></picture><br>Eye</p> | <p><picture><source srcset="../../.gitbook/assets/icon-eye-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-eye-disabled-16@light.svg" alt=""></picture><br>EyeDisabled</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-eye-dropper-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-eye-dropper-16@light.svg" alt=""></picture><br>EyeDropper</p> | <p><picture><source srcset="../../.gitbook/assets/icon-female-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-female-16@light.svg" alt=""></picture><br>Female</p> | <p><picture><source srcset="../../.gitbook/assets/icon-film-strip-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-film-strip-16@light.svg" alt=""></picture><br>FilmStrip</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-filter-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-filter-16@light.svg" alt=""></picture><br>Filter</p> | <p><picture><source srcset="../../.gitbook/assets/icon-finder-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-finder-16@light.svg" alt=""></picture><br>Finder</p> | <p><picture><source srcset="../../.gitbook/assets/icon-fingerprint-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-fingerprint-16@light.svg" alt=""></picture><br>Fingerprint</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-flag-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-flag-16@light.svg" alt=""></picture><br>Flag</p> | <p><picture><source srcset="../../.gitbook/assets/icon-folder-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-folder-16@light.svg" alt=""></picture><br>Folder</p> | <p><picture><source srcset="../../.gitbook/assets/icon-footprints-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-footprints-16@light.svg" alt=""></picture><br>Footprints</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-forward-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-forward-16@light.svg" alt=""></picture><br>Forward</p> | <p><picture><source srcset="../../.gitbook/assets/icon-forward-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-forward-filled-16@light.svg" alt=""></picture><br>ForwardFilled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-fountain-tip-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-fountain-tip-16@light.svg" alt=""></picture><br>FountainTip</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-full-signal-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-full-signal-16@light.svg" alt=""></picture><br>FullSignal</p> | <p><picture><source srcset="../../.gitbook/assets/icon-game-controller-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-game-controller-16@light.svg" alt=""></picture><br>GameController</p> | <p><picture><source srcset="../../.gitbook/assets/icon-gauge-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-gauge-16@light.svg" alt=""></picture><br>Gauge</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-cog-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-cog-16@light.svg" alt=""></picture><br>Gear</p> | <p><picture><source srcset="../../.gitbook/assets/icon-geopin-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-geopin-16@light.svg" alt=""></picture><br>Geopin</p> | <p><picture><source srcset="../../.gitbook/assets/icon-germ-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-germ-16@light.svg" alt=""></picture><br>Germ</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-gift-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-gift-16@light.svg" alt=""></picture><br>Gift</p> | <p><picture><source srcset="../../.gitbook/assets/icon-glasses-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-glasses-16@light.svg" alt=""></picture><br>Glasses</p> | <p><picture><source srcset="../../.gitbook/assets/icon-globe-01-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-globe-01-16@light.svg" alt=""></picture><br>Globe</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-goal-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-goal-16@light.svg" alt=""></picture><br>Goal</p> | <p><picture><source srcset="../../.gitbook/assets/icon-hammer-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-hammer-16@light.svg" alt=""></picture><br>Hammer</p> | <p><picture><source srcset="../../.gitbook/assets/icon-hard-drive-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-hard-drive-16@light.svg" alt=""></picture><br>HardDrive</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-hashtag-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-hashtag-16@light.svg" alt=""></picture><br>Hashtag</p> | <p><picture><source srcset="../../.gitbook/assets/icon-heading-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-heading-16@light.svg" alt=""></picture><br>Heading</p> | <p><picture><source srcset="../../.gitbook/assets/icon-headphones-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-headphones-16@light.svg" alt=""></picture><br>Headphones</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-heart-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-heart-16@light.svg" alt=""></picture><br>Heart</p> | <p><picture><source srcset="../../.gitbook/assets/icon-heart-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-heart-disabled-16@light.svg" alt=""></picture><br>HeartDisabled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-heartbeat-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-heartbeat-16@light.svg" alt=""></picture><br>Heartbeat</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-highlight-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-highlight-16@light.svg" alt=""></picture><br>Highlight</p> | <p><picture><source srcset="../../.gitbook/assets/icon-hourglass-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-hourglass-16@light.svg" alt=""></picture><br>Hourglass</p> | <p><picture><source srcset="../../.gitbook/assets/icon-house-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-house-16@light.svg" alt=""></picture><br>House</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-humidity-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-humidity-16@light.svg" alt=""></picture><br>Humidity</p> | <p><picture><source srcset="../../.gitbook/assets/icon-image-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-image-16@light.svg" alt=""></picture><br>Image</p> | <p><picture><source srcset="../../.gitbook/assets/icon-important-01-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-important-01-16@light.svg" alt=""></picture><br>Important</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-info-01-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-info-01-16@light.svg" alt=""></picture><br>Info</p> | <p><picture><source srcset="../../.gitbook/assets/icon-italics-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-italics-16@light.svg" alt=""></picture><br>Italics</p> | <p><picture><source srcset="../../.gitbook/assets/icon-key-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-key-16@light.svg" alt=""></picture><br>Key</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-keyboard-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-keyboard-16@light.svg" alt=""></picture><br>Keyboard</p> | <p><picture><source srcset="../../.gitbook/assets/icon-layers-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-layers-16@light.svg" alt=""></picture><br>Layers</p> | <p><picture><source srcset="../../.gitbook/assets/icon-leaderboard-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-leaderboard-16@light.svg" alt=""></picture><br>Leaderboard</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-leaf-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-leaf-16@light.svg" alt=""></picture><br>Leaf</p> | <p><picture><source srcset="../../.gitbook/assets/icon-signal-2-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-signal-2-16@light.svg" alt=""></picture><br>LevelMeter</p> | <p><picture><source srcset="../../.gitbook/assets/icon-light-bulb-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-light-bulb-16@light.svg" alt=""></picture><br>LightBulb</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-light-bulb-off-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-light-bulb-off-16@light.svg" alt=""></picture><br>LightBulbOff</p> | <p><picture><source srcset="../../.gitbook/assets/icon-line-chart-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-line-chart-16@light.svg" alt=""></picture><br>LineChart</p> | <p><picture><source srcset="../../.gitbook/assets/icon-link-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-link-16@light.svg" alt=""></picture><br>Link</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-app-window-list-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-app-window-list-16@light.svg" alt=""></picture><br>List</p> | <p><picture><source srcset="../../.gitbook/assets/icon-livestream-01-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-livestream-01-16@light.svg" alt=""></picture><br>Livestream</p> | <p><picture><source srcset="../../.gitbook/assets/icon-livestream-disabled-01-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-livestream-disabled-01-16@light.svg" alt=""></picture><br>LivestreamDisabled</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-lock-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-lock-16@light.svg" alt=""></picture><br>Lock</p> | <p><picture><source srcset="../../.gitbook/assets/icon-lock-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-lock-disabled-16@light.svg" alt=""></picture><br>LockDisabled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-lock-unlocked-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-lock-unlocked-16@light.svg" alt=""></picture><br>LockUnlocked</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-logout-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-logout-16@light.svg" alt=""></picture><br>Logout</p> | <p><picture><source srcset="../../.gitbook/assets/icon-lorry-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-lorry-16@light.svg" alt=""></picture><br>Lorry</p> | <p><picture><source srcset="../../.gitbook/assets/icon-lowercase-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-lowercase-16@light.svg" alt=""></picture><br>Lowercase</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-magnifying-glass-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-magnifying-glass-16@light.svg" alt=""></picture><br>MagnifyingGlass</p> | <p><picture><source srcset="../../.gitbook/assets/icon-male-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-male-16@light.svg" alt=""></picture><br>Male</p> | <p><picture><source srcset="../../.gitbook/assets/icon-map-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-map-16@light.svg" alt=""></picture><br>Map</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-mask-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-mask-16@light.svg" alt=""></picture><br>Mask</p> | <p><picture><source srcset="../../.gitbook/assets/icon-maximize-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-maximize-16@light.svg" alt=""></picture><br>Maximize</p> | <p><picture><source srcset="../../.gitbook/assets/icon-medical-support-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-medical-support-16@light.svg" alt=""></picture><br>MedicalSupport</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-megaphone-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-megaphone-16@light.svg" alt=""></picture><br>Megaphone</p> | <p><picture><source srcset="../../.gitbook/assets/icon-computer-chip-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-computer-chip-16@light.svg" alt=""></picture><br>MemoryChip</p> | <p><picture><source srcset="../../.gitbook/assets/icon-memory-stick-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-memory-stick-16@light.svg" alt=""></picture><br>MemoryStick</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-speech-bubble-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speech-bubble-16@light.svg" alt=""></picture><br>Message</p> | <p><picture><source srcset="../../.gitbook/assets/icon-microphone-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-microphone-16@light.svg" alt=""></picture><br>Microphone</p> | <p><picture><source srcset="../../.gitbook/assets/icon-microphone-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-microphone-disabled-16@light.svg" alt=""></picture><br>MicrophoneDisabled</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-minimize-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-minimize-16@light.svg" alt=""></picture><br>Minimize</p> | <p><picture><source srcset="../../.gitbook/assets/icon-minus-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-minus-16@light.svg" alt=""></picture><br>Minus</p> | <p><picture><source srcset="../../.gitbook/assets/icon-minus-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-minus-circle-16@light.svg" alt=""></picture><br>MinusCircle</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-minus-circle-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-minus-circle-filled-16@light.svg" alt=""></picture><br>MinusCircleFilled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-mobile-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-mobile-16@light.svg" alt=""></picture><br>Mobile</p> | <p><picture><source srcset="../../.gitbook/assets/icon-monitor-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-monitor-16@light.svg" alt=""></picture><br>Monitor</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-moon-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-moon-16@light.svg" alt=""></picture><br>Moon</p> | <p><picture><source srcset="../../.gitbook/assets/icon-moon-down-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-moon-down-16@light.svg" alt=""></picture><br>MoonDown</p> | <p><picture><source srcset="../../.gitbook/assets/icon-moon-up-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-moon-up-16@light.svg" alt=""></picture><br>MoonUp</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-moonrise-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-moonrise-16@light.svg" alt=""></picture><br>Moonrise</p> | <p><picture><source srcset="../../.gitbook/assets/icon-mountain-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-mountain-16@light.svg" alt=""></picture><br>Mountain</p> | <p><picture><source srcset="../../.gitbook/assets/icon-mouse-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-mouse-16@light.svg" alt=""></picture><br>Mouse</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-move-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-move-16@light.svg" alt=""></picture><br>Move</p> | <p><picture><source srcset="../../.gitbook/assets/icon-mug-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-mug-16@light.svg" alt=""></picture><br>Mug</p> | <p><picture><source srcset="../../.gitbook/assets/icon-mug-steam-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-mug-steam-16@light.svg" alt=""></picture><br>MugSteam</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-multiply-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-multiply-16@light.svg" alt=""></picture><br>Multiply</p> | <p><picture><source srcset="../../.gitbook/assets/icon-music-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-music-16@light.svg" alt=""></picture><br>Music</p> | <p><picture><source srcset="../../.gitbook/assets/icon-network-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-network-16@light.svg" alt=""></picture><br>Network</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-new-document-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-new-document-16@light.svg" alt=""></picture><br>NewDocument</p> | <p><picture><source srcset="../../.gitbook/assets/icon-new-folder-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-new-folder-16@light.svg" alt=""></picture><br>NewFolder</p> | <p><picture><source srcset="../../.gitbook/assets/icon-paperclip-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-paperclip-16@light.svg" alt=""></picture><br>Paperclip</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-paragraph-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-paragraph-16@light.svg" alt=""></picture><br>Paragraph</p> | <p><picture><source srcset="../../.gitbook/assets/icon-patch-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-patch-16@light.svg" alt=""></picture><br>Patch</p> | <p><picture><source srcset="../../.gitbook/assets/icon-pause-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-pause-16@light.svg" alt=""></picture><br>Pause</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-pause-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-pause-filled-16@light.svg" alt=""></picture><br>PauseFilled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-pencil-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-pencil-16@light.svg" alt=""></picture><br>Pencil</p> | <p><picture><source srcset="../../.gitbook/assets/icon-person-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-person-16@light.svg" alt=""></picture><br>Person</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-person-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-person-circle-16@light.svg" alt=""></picture><br>PersonCircle</p> | <p><picture><source srcset="../../.gitbook/assets/icon-person-lines-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-person-lines-16@light.svg" alt=""></picture><br>PersonLines</p> | <p><picture><source srcset="../../.gitbook/assets/icon-phone-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-phone-16@light.svg" alt=""></picture><br>Phone</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-phone-ringing-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-phone-ringing-16@light.svg" alt=""></picture><br>PhoneRinging</p> | <p><picture><source srcset="../../.gitbook/assets/icon-pie-chart-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-pie-chart-16@light.svg" alt=""></picture><br>PieChart</p> | <p><picture><source srcset="../../.gitbook/assets/icon-pill-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-pill-16@light.svg" alt=""></picture><br>Pill</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-pin-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-pin-16@light.svg" alt=""></picture><br>Pin</p> | <p><picture><source srcset="../../.gitbook/assets/icon-pin-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-pin-disabled-16@light.svg" alt=""></picture><br>PinDisabled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-play-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-play-16@light.svg" alt=""></picture><br>Play</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-play-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-play-filled-16@light.svg" alt=""></picture><br>PlayFilled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-plug-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-plug-16@light.svg" alt=""></picture><br>Plug</p> | <p><picture><source srcset="../../.gitbook/assets/icon-plus-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-plus-16@light.svg" alt=""></picture><br>Plus</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-plus-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-plus-circle-16@light.svg" alt=""></picture><br>PlusCircle</p> | <p><picture><source srcset="../../.gitbook/assets/icon-plus-circle-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-plus-circle-filled-16@light.svg" alt=""></picture><br>PlusCircleFilled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-plus-minus-divide-multiply-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-plus-minus-divide-multiply-16@light.svg" alt=""></picture><br>PlusMinusDivideMultiply</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-plus-square-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-plus-square-16@light.svg" alt=""></picture><br>PlusSquare</p> | <p><picture><source srcset="../../.gitbook/assets/icon-plus-top-right-square-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-plus-top-right-square-16@light.svg" alt=""></picture><br>PlusTopRightSquare</p> | <p><picture><source srcset="../../.gitbook/assets/icon-power-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-power-16@light.svg" alt=""></picture><br>Power</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-print-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-print-16@light.svg" alt=""></picture><br>Print</p> | <p><picture><source srcset="../../.gitbook/assets/icon-question-mark-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-question-mark-circle-16@light.svg" alt=""></picture><br>QuestionMark</p> | <p><picture><source srcset="../../.gitbook/assets/icon-question-mark-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-question-mark-circle-16@light.svg" alt=""></picture><br>QuestionMarkCircle</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-quicklink-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-quicklink-16@light.svg" alt=""></picture><br>Quicklink</p> | <p><picture><source srcset="../../.gitbook/assets/icon-quotation-marks-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-quotation-marks-16@light.svg" alt=""></picture><br>QuotationMarks</p> | <p><picture><source srcset="../../.gitbook/assets/icon-quote-block-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-quote-block-16@light.svg" alt=""></picture><br>QuoteBlock</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-racket-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-racket-16@light.svg" alt=""></picture><br>Racket</p> | <p><picture><source srcset="../../.gitbook/assets/icon-raindrop-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-raindrop-16@light.svg" alt=""></picture><br>Raindrop</p> | <p><picture><source srcset="../../.gitbook/assets/icon-raycast-logo-neg-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-raycast-logo-neg-16@light.svg" alt=""></picture><br>RaycastLogoNeg</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-raycast-logo-pos-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-raycast-logo-pos-16@light.svg" alt=""></picture><br>RaycastLogoPos</p> | <p><picture><source srcset="../../.gitbook/assets/icon-receipt-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-receipt-16@light.svg" alt=""></picture><br>Receipt</p> | <p><picture><source srcset="../../.gitbook/assets/icon-redo-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-redo-16@light.svg" alt=""></picture><br>Redo</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-remove-person-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-remove-person-16@light.svg" alt=""></picture><br>RemovePerson</p> | <p><picture><source srcset="../../.gitbook/assets/icon-repeat-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-repeat-16@light.svg" alt=""></picture><br>Repeat</p> | <p><picture><source srcset="../../.gitbook/assets/icon-replace-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-replace-16@light.svg" alt=""></picture><br>Replace</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-replace-one-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-replace-one-16@light.svg" alt=""></picture><br>ReplaceOne</p> | <p><picture><source srcset="../../.gitbook/assets/icon-reply-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-reply-16@light.svg" alt=""></picture><br>Reply</p> | <p><picture><source srcset="../../.gitbook/assets/icon-rewind-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-rewind-16@light.svg" alt=""></picture><br>Rewind</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-rewind-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-rewind-filled-16@light.svg" alt=""></picture><br>RewindFilled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-rocket-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-rocket-16@light.svg" alt=""></picture><br>Rocket</p> | <p><picture><source srcset="../../.gitbook/assets/icon-rosette-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-rosette-16@light.svg" alt=""></picture><br>Rosette</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-rotate-anti-clockwise-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-rotate-anti-clockwise-16@light.svg" alt=""></picture><br>RotateAntiClockwise</p> | <p><picture><source srcset="../../.gitbook/assets/icon-rotate-clockwise-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-rotate-clockwise-16@light.svg" alt=""></picture><br>RotateClockwise</p> | <p><picture><source srcset="../../.gitbook/assets/icon-rss-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-rss-16@light.svg" alt=""></picture><br>Rss</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-ruler-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-ruler-16@light.svg" alt=""></picture><br>Ruler</p> | <p><picture><source srcset="../../.gitbook/assets/icon-save-document-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-save-document-16@light.svg" alt=""></picture><br>SaveDocument</p> | <p><picture><source srcset="../../.gitbook/assets/icon-shield-01-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-shield-01-16@light.svg" alt=""></picture><br>Shield</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-short-paragraph-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-short-paragraph-16@light.svg" alt=""></picture><br>ShortParagraph</p> | <p><picture><source srcset="../../.gitbook/assets/icon-shuffle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-shuffle-16@light.svg" alt=""></picture><br>Shuffle</p> | <p><picture><source srcset="../../.gitbook/assets/icon-app-window-sidebar-right-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-app-window-sidebar-right-16@light.svg" alt=""></picture><br>Sidebar</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-signal-0-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-signal-0-16@light.svg" alt=""></picture><br>Signal0</p> | <p><picture><source srcset="../../.gitbook/assets/icon-signal-1-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-signal-1-16@light.svg" alt=""></picture><br>Signal1</p> | <p><picture><source srcset="../../.gitbook/assets/icon-signal-2-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-signal-2-16@light.svg" alt=""></picture><br>Signal2</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-signal-3-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-signal-3-16@light.svg" alt=""></picture><br>Signal3</p> | <p><picture><source srcset="../../.gitbook/assets/icon-snippets-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-snippets-16@light.svg" alt=""></picture><br>Snippets</p> | <p><picture><source srcset="../../.gitbook/assets/icon-snowflake-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-snowflake-16@light.svg" alt=""></picture><br>Snowflake</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-soccer-ball-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-soccer-ball-16@light.svg" alt=""></picture><br>SoccerBall</p> | <p><picture><source srcset="../../.gitbook/assets/icon-speaker-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speaker-16@light.svg" alt=""></picture><br>Speaker</p> | <p><picture><source srcset="../../.gitbook/assets/icon-speaker-down-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speaker-down-16@light.svg" alt=""></picture><br>SpeakerDown</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-speaker-high-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speaker-high-16@light.svg" alt=""></picture><br>SpeakerHigh</p> | <p><picture><source srcset="../../.gitbook/assets/icon-speaker-low-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speaker-low-16@light.svg" alt=""></picture><br>SpeakerLow</p> | <p><picture><source srcset="../../.gitbook/assets/icon-speaker-off-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speaker-off-16@light.svg" alt=""></picture><br>SpeakerOff</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-speaker-on-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speaker-on-16@light.svg" alt=""></picture><br>SpeakerOn</p> | <p><picture><source srcset="../../.gitbook/assets/icon-speaker-up-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speaker-up-16@light.svg" alt=""></picture><br>SpeakerUp</p> | <p><picture><source srcset="../../.gitbook/assets/icon-speech-bubble-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speech-bubble-16@light.svg" alt=""></picture><br>SpeechBubble</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-speech-bubble-active-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speech-bubble-active-16@light.svg" alt=""></picture><br>SpeechBubbleActive</p> | <p><picture><source srcset="../../.gitbook/assets/icon-speech-bubble-important-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-speech-bubble-important-16@light.svg" alt=""></picture><br>SpeechBubbleImportant</p> | <p><picture><source srcset="../../.gitbook/assets/icon-square-ellipsis-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-square-ellipsis-16@light.svg" alt=""></picture><br>SquareEllipsis</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-stacked-bars-1-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-stacked-bars-1-16@light.svg" alt=""></picture><br>StackedBars1</p> | <p><picture><source srcset="../../.gitbook/assets/icon-stacked-bars-2-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-stacked-bars-2-16@light.svg" alt=""></picture><br>StackedBars2</p> | <p><picture><source srcset="../../.gitbook/assets/icon-stacked-bars-3-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-stacked-bars-3-16@light.svg" alt=""></picture><br>StackedBars3</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-stacked-bars-4-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-stacked-bars-4-16@light.svg" alt=""></picture><br>StackedBars4</p> | <p><picture><source srcset="../../.gitbook/assets/icon-star-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-star-16@light.svg" alt=""></picture><br>Star</p> | <p><picture><source srcset="../../.gitbook/assets/icon-star-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-star-circle-16@light.svg" alt=""></picture><br>StarCircle</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-star-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-star-disabled-16@light.svg" alt=""></picture><br>StarDisabled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-stars-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-stars-16@light.svg" alt=""></picture><br>Stars</p> | <p><picture><source srcset="../../.gitbook/assets/icon-stop-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-stop-16@light.svg" alt=""></picture><br>Stop</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-stop-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-stop-filled-16@light.svg" alt=""></picture><br>StopFilled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-stopwatch-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-stopwatch-16@light.svg" alt=""></picture><br>Stopwatch</p> | <p><picture><source srcset="../../.gitbook/assets/icon-store-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-store-16@light.svg" alt=""></picture><br>Store</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-strike-through-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-strike-through-16@light.svg" alt=""></picture><br>StrikeThrough</p> | <p><picture><source srcset="../../.gitbook/assets/icon-sun-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-sun-16@light.svg" alt=""></picture><br>Sun</p> | <p><picture><source srcset="../../.gitbook/assets/icon-sunrise-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-sunrise-16@light.svg" alt=""></picture><br>Sunrise</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-swatch-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-swatch-16@light.svg" alt=""></picture><br>Swatch</p> | <p><picture><source srcset="../../.gitbook/assets/icon-switch-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-switch-16@light.svg" alt=""></picture><br>Switch</p> | <p><picture><source srcset="../../.gitbook/assets/icon-syringe-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-syringe-16@light.svg" alt=""></picture><br>Syringe</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-tack-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-tack-16@light.svg" alt=""></picture><br>Tack</p> | <p><picture><source srcset="../../.gitbook/assets/icon-tack-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-tack-disabled-16@light.svg" alt=""></picture><br>TackDisabled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-tag-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-tag-16@light.svg" alt=""></picture><br>Tag</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-temperature-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-temperature-16@light.svg" alt=""></picture><br>Temperature</p> | <p><picture><source srcset="../../.gitbook/assets/icon-tennis-ball-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-tennis-ball-16@light.svg" alt=""></picture><br>TennisBall</p> | <p><picture><source srcset="../../.gitbook/assets/icon-terminal-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-terminal-16@light.svg" alt=""></picture><br>Terminal</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-text-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-text-16@light.svg" alt=""></picture><br>Text</p> | <p><picture><source srcset="../../.gitbook/assets/icon-text-cursor-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-text-cursor-16@light.svg" alt=""></picture><br>TextCursor</p> | <p><picture><source srcset="../../.gitbook/assets/icon-text-input-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-text-input-16@light.svg" alt=""></picture><br>TextInput</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-text-selection-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-text-selection-16@light.svg" alt=""></picture><br>TextSelection</p> | <p><picture><source srcset="../../.gitbook/assets/icon-thumbs-down-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-thumbs-down-16@light.svg" alt=""></picture><br>ThumbsDown</p> | <p><picture><source srcset="../../.gitbook/assets/icon-thumbs-down-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-thumbs-down-filled-16@light.svg" alt=""></picture><br>ThumbsDownFilled</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-thumbs-up-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-thumbs-up-16@light.svg" alt=""></picture><br>ThumbsUp</p> | <p><picture><source srcset="../../.gitbook/assets/icon-thumbs-up-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-thumbs-up-filled-16@light.svg" alt=""></picture><br>ThumbsUpFilled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-ticket-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-ticket-16@light.svg" alt=""></picture><br>Ticket</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-torch-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-torch-16@light.svg" alt=""></picture><br>Torch</p> | <p><picture><source srcset="../../.gitbook/assets/icon-train-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-train-16@light.svg" alt=""></picture><br>Train</p> | <p><picture><source srcset="../../.gitbook/assets/icon-trash-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-trash-16@light.svg" alt=""></picture><br>Trash</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-tray-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-tray-16@light.svg" alt=""></picture><br>Tray</p> | <p><picture><source srcset="../../.gitbook/assets/icon-tree-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-tree-16@light.svg" alt=""></picture><br>Tree</p> | <p><picture><source srcset="../../.gitbook/assets/icon-trophy-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-trophy-16@light.svg" alt=""></picture><br>Trophy</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-two-people-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-two-people-16@light.svg" alt=""></picture><br>TwoPeople</p> | <p><picture><source srcset="../../.gitbook/assets/icon-umbrella-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-umbrella-16@light.svg" alt=""></picture><br>Umbrella</p> | <p><picture><source srcset="../../.gitbook/assets/icon-underline-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-underline-16@light.svg" alt=""></picture><br>Underline</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-undo-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-undo-16@light.svg" alt=""></picture><br>Undo</p> | <p><picture><source srcset="../../.gitbook/assets/icon-upload-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-upload-16@light.svg" alt=""></picture><br>Upload</p> | <p><picture><source srcset="../../.gitbook/assets/icon-uppercase-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-uppercase-16@light.svg" alt=""></picture><br>Uppercase</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-video-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-video-16@light.svg" alt=""></picture><br>Video</p> | <p><picture><source srcset="../../.gitbook/assets/icon-video-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-video-disabled-16@light.svg" alt=""></picture><br>VideoDisabled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-wallet-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-wallet-16@light.svg" alt=""></picture><br>Wallet</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-wand-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-wand-16@light.svg" alt=""></picture><br>Wand</p> | <p><picture><source srcset="../../.gitbook/assets/icon-warning-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-warning-16@light.svg" alt=""></picture><br>Warning</p> | <p><picture><source srcset="../../.gitbook/assets/icon-waveform-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-waveform-16@light.svg" alt=""></picture><br>Waveform</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-weights-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-weights-16@light.svg" alt=""></picture><br>Weights</p> | <p><picture><source srcset="../../.gitbook/assets/icon-wifi-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-wifi-16@light.svg" alt=""></picture><br>Wifi</p> | <p><picture><source srcset="../../.gitbook/assets/icon-wifi-disabled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-wifi-disabled-16@light.svg" alt=""></picture><br>WifiDisabled</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-wind-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-wind-16@light.svg" alt=""></picture><br>Wind</p> | <p><picture><source srcset="../../.gitbook/assets/icon-app-window-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-app-window-16@light.svg" alt=""></picture><br>Window</p> | <p><picture><source srcset="../../.gitbook/assets/icon-windsock-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-windsock-16@light.svg" alt=""></picture><br>Windsock</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-wrench-screwdriver-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-wrench-screwdriver-16@light.svg" alt=""></picture><br>WrenchScrewdriver</p> | <p><picture><source srcset="../../.gitbook/assets/icon-wrist-watch-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-wrist-watch-16@light.svg" alt=""></picture><br>WristWatch</p> | <p><picture><source srcset="../../.gitbook/assets/icon-x-mark-circle-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-x-mark-circle-16@light.svg" alt=""></picture><br>XMarkCircle</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-x-mark-circle-filled-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-x-mark-circle-filled-16@light.svg" alt=""></picture><br>XMarkCircleFilled</p> | <p><picture><source srcset="../../.gitbook/assets/icon-x-mark-circle-half-dash-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-x-mark-circle-half-dash-16@light.svg" alt=""></picture><br>XMarkCircleHalfDash</p> | <p><picture><source srcset="../../.gitbook/assets/icon-x-mark-top-right-square-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-x-mark-top-right-square-16@light.svg" alt=""></picture><br>XMarkTopRightSquare</p> |
| <p><picture><source srcset="../../.gitbook/assets/icon-xmark-16@dark.svg" media="(prefers-color-scheme: dark)"><img src="../../.gitbook/assets/icon-xmark-16@light.svg" alt=""></picture><br>Xmark</p> |

### Image.Mask

Available masks that can be used to change the shape of an image.

Can be handy to shape avatars or other items in a list.

#### Example

```typescript
import { Image, List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item
        title="Icon"
        icon={{
          source: "https://raycast.com/uploads/avatar.png",
          mask: Image.Mask.Circle,
        }}
      />
    </List>
  );
}
```

#### Enumeration members

| Name             | Value              |
| :--------------- | :----------------- |
| Circle           | "circle"           |
| RoundedRectangle | "roundedRectangle" |

## Types

### Image

Display different types of images, including network images or bundled assets.

Apply image transforms to the source, such as a `mask` or a `tintColor`.

{% hint style="info" %}
Tip: Suffix your local assets with `@dark` to automatically provide a dark theme option, eg: `icon.png` and `icon@dark.png`.
{% endhint %}

#### Example

```typescript
// Built-in icon
const icon = Icon.Eye;

// Built-in icon with tint color
const tintedIcon = { source: Icon.Bubble, tintColor: Color.Red };

// Bundled asset with circular mask
const avatar = { source: "avatar.png", mask: Image.Mask.Circle };

// Implicit theme-aware icon
// with 'icon.png' and 'icon@dark.png' in the `assets` folder
const icon = "icon.png";

// Explicit theme-aware icon
const icon = { source: { light: "https://example.com/icon-light.png", dark: "https://example.com/icon-dark.png" } };
```

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| source<mark style="color:red;">*</mark> | The Image.Source of the image. | <code>Image.Source</code> |
| fallback | Image.Fallback image, in case `source` can't be loaded. | <code>Image.Fallback</code> |
| mask | A Image.Mask to apply to the image. | <code>Image.Mask</code> |
| tintColor | A Color.ColorLike to tint all the non-transparent pixels of the image. | <code>Color.ColorLike</code> |

### FileIcon

An icon as it's used in the Finder.

#### Example

```typescript
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item title="File icon" icon={{ fileIcon: __filename }} />
    </List>
  );
}
```

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| fileIcon<mark style="color:red;">*</mark> | The path to a file or folder to get its icon from. | <code>string</code> |

### Image.ImageLike

```typescript
ImageLike: URL | Asset | Icon | FileIcon | Image;
```

Union type for the supported image types.

#### Example

```typescript
import { Icon, Image, List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item title="URL" icon="https://raycast.com/uploads/avatar.png" />
      <List.Item title="Asset" icon="avatar.png" />
      <List.Item title="Icon" icon={Icon.Circle} />
      <List.Item title="FileIcon" icon={{ fileIcon: __filename }} />
      <List.Item
        title="Image"
        icon={{
          source: "https://raycast.com/uploads/avatar.png",
          mask: Image.Mask.Circle,
        }}
      />
    </List>
  );
}
```

### Image.Source

```typescript
Image.Source: URL | Asset | Icon | { light: URL | Asset; dark: URL | Asset }
```

The source of an Image or
a single emoji.

For consistency, it's best to use the built-in Icon in lists, the Action Panel, and other places. If a
specific icon isn't built-in, you can reference custom ones from the `assets` folder of the extension by file name,
e.g. `my-icon.png`. Alternatively, you can reference an absolute HTTPS URL that points to an image or use an emoji.
You can also specify different remote or local assets for light and dark theme.

#### Example

```typescript
import { Icon, List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item title="URL" icon={{ source: "https://raycast.com/uploads/avatar.png" }} />
      <List.Item title="Asset" icon={{ source: "avatar.png" }} />
      <List.Item title="Icon" icon={{ source: Icon.Circle }} />
      <List.Item
        title="Theme"
        icon={{
          source: {
            light: "https://raycast.com/uploads/avatar.png",
            dark: "https://raycast.com/uploads/avatar.png",
          },
        }}
      />
    </List>
  );
}
```

### Image.Fallback

```typescript
Image.Fallback: Asset | Icon | { light: Asset; dark: Asset }
```

A fallback Image, a single emoji, or a theme-aware asset. Any specified `mask` or `tintColor` will also apply to the fallback image.

#### Example

```typescript
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item
        title="URL Source With Asset Fallback"
        icon={{
          source: "https://raycast.com/uploads/avatar.png",
          fallback: "default-avatar.png",
        }}
      />
    </List>
  );
}
```

### Image.URL

Image is a string representing a URL.

#### Example

```typescript
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item title="URL" icon={{ source: "https://raycast.com/uploads/avatar.png" }} />
    </List>
  );
}
```

### Image.Asset

Image is a string representing an asset from the `assets/` folder

#### Example

```typescript
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item title="Asset" icon={{ source: "avatar.png" }} />
    </List>
  );
}
```


---
description: >-
  The de-facto user interface in Raycast. Ideal to present similar data such as
  to-dos or files.
---

# List

Our `List` component provides great user experience out of the box:

- Use built-in filtering for best performance.
- Group-related items in sections with titles and subtitles.
- Show loading indicator for longer operations.
- Use the search query for typeahead experiences, optionally throttled.



## Search Bar

The search bar allows users to interact quickly with list items. By default, List.Items matched to the item's `title` or `keywords`.

### Custom filtering

Sometimes, you may not want to rely on Raycast's filtering, but use/implement your own. If that's the case, you can set the `List`'s `filtering` prop to false, and the items displayed will be independent of the search bar's text.
Note that `filtering` is also implicitly set to false if an `onSearchTextChange` listener is specified. If you want to specify a change listener and _still_ take advantage of Raycast's built-in filtering, you can explicitly set `filtering` to true.

```typescript
import { useEffect, useState } from "react";
import { Action, ActionPanel, List } from "@raycast/api";

const items = ["Augustiner Helles", "Camden Hells", "Leffe Blonde", "Sierra Nevada IPA"];

export default function Command() {
  const [searchText, setSearchText] = useState("");
  const [filteredList, filterList] = useState(items);

  useEffect(() => {
    filterList(items.filter((item) => item.includes(searchText)));
  }, [searchText]);

  return (
    <List
      filtering={false}
      onSearchTextChange={setSearchText}
      navigationTitle="Search Beers"
      searchBarPlaceholder="Search your favorite beer"
    >
      {filteredList.map((item) => (
        <List.Item
          key={item}
          title={item}
          actions={
            <ActionPanel>
              <Action title="Select" onAction={() => console.log(`${item} selected`)} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
```

### Programmatically updating the search bar

Other times, you may want the content of the search bar to be updated by the extension, for example, you may store a list of the user's previous searches and, on the next visit, allow them to "continue" where they left off.

To do so, you can use the `searchText` prop.

```typescript
import { useEffect, useState } from "react";
import { Action, ActionPanel, List } from "@raycast/api";

const items = ["Augustiner Helles", "Camden Hells", "Leffe Blonde", "Sierra Nevada IPA"];

export default function Command() {
  const [searchText, setSearchText] = useState("");

  return (
    <List
      searchText={searchText}
      onSearchTextChange={setSearchText}
      navigationTitle="Search Beers"
      searchBarPlaceholder="Search your favorite beer"
    >
      {items.map((item) => (
        <List.Item
          key={item}
          title={item}
          actions={
            <ActionPanel>
              <Action title="Select" onAction={() => setSearchText(item)} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
```

### Dropdown

Some extensions may benefit from giving users a second filtering dimension. A todo extension may allow users to use different groups, a newspaper-reading extension may want to allow quickly switching categories, etc.

This is where the `searchBarAccessory` prop component, and it will be displayed on the right-side of the search bar. Invoke it either by using the global shortcut `⌘` `P` or by clicking on it.

### Pagination

{% hint style="info" %}
Pagination requires version 1.69.0 or higher of the `@raycast/api` package.
{% endhint %}

`List`s have built-in support for pagination. To opt in to pagination, you need to pass it a `pagination` prop, which is an object providing 3 pieces of information:

- `onLoadMore` - will be called by Raycast when the user reaches the end of the list, either using the keyboard or the mouse. When it gets called, the extension is expected to perform an async operation which eventually can result in items being appended to the end of the list.
- `hasMore` - indicates to Raycast whether it _should_ call `onLoadMore` when the user reaches the end of the list.
- `pageSize` - indicates how many placeholder items Raycast should add to the end of the list when it calls `onLoadMore`. Once `onLoadMore` finishes executing, the placeholder items will be replaced by the newly-added list items.

Note that extensions have access to a limited amount of memory. As your extension paginates, its memory usage will increase. Paginating extensively could lead to the extension eventually running out of memory and crashing. To protect against the extension crashing due to memory exhaustion, Raycast monitors the extension's memory usage and employs heuristics to determine whether it's safe to paginate further. If it's deemed unsafe to continue paginating, `onLoadMore` will not be triggered when the user scrolls to the bottom, regardless of the `hasMore` value. Additionally, during development, a warning will be printed in the terminal.

For convenience, most of the hooks, and one "from scratch".

{% tabs %}

{% tab title="ListWithUsePromisePagination.tsx" %}

```typescript
import { setTimeout } from "node:timers/promises";
import { useState } from "react";
import { List } from "@raycast/api";
import { usePromise } from "@raycast/utils";

export default function Command() {
  const [searchText, setSearchText] = useState("");

  const { isLoading, data, pagination } = usePromise(
    (searchText: string) => async (options: { page: number }) => {
      await setTimeout(200);
      const newData = Array.from({ length: 25 }, (_v, index) => ({
        index,
        page: options.page,
        text: searchText,
      }));
      return { data: newData, hasMore: options.page < 10 };
    },
    [searchText]
  );

  return (
    <List isLoading={isLoading} onSearchTextChange={setSearchText} pagination={pagination}>
      {data?.map((item) => (
        <List.Item
          key={`${item.page} ${item.index} ${item.text}`}
          title={`Page ${item.page} Item ${item.index}`}
          subtitle={item.text}
        />
      ))}
    </List>
  );
}
```

{% endtab %}
{% tab title="ListWithPagination.tsx" %}

```typescript
import { setTimeout } from "node:timers/promises";
import { useCallback, useEffect, useRef, useState } from "react";
import { List } from "@raycast/api";

type State = {
  searchText: string;
  isLoading: boolean;
  hasMore: boolean;
  data: {
    index: number;
    page: number;
    text: string;
  }[];
  nextPage: number;
};
const pageSize = 20;
export default function Command() {
  const [state, setState] = useState<State>({ searchText: "", isLoading: true, hasMore: true, data: [], nextPage: 0 });
  const cancelRef = useRef<AbortController | null>(null);

  const loadNextPage = useCallback(async (searchText: string, nextPage: number, signal?: AbortSignal) => {
    setState((previous) => ({ ...previous, isLoading: true }));
    await setTimeout(500);
    const newData = Array.from({ length: pageSize }, (_v, index) => ({
      index,
      page: nextPage,
      text: searchText,
    }));
    if (signal?.aborted) {
      return;
    }
    setState((previous) => ({
      ...previous,
      data: [...previous.data, ...newData],
      isLoading: false,
      hasMore: nextPage < 10,
    }));
  }, []);

  const onLoadMore = useCallback(() => {
    setState((previous) => ({ ...previous, nextPage: previous.nextPage + 1 }));
  }, []);

  const onSearchTextChange = useCallback(
    (searchText: string) => {
      if (searchText === state.searchText) return;
      setState((previous) => ({
        ...previous,
        data: [],
        nextPage: 0,
        searchText,
      }));
    },
    [state.searchText]
  );

  useEffect(() => {
    cancelRef.current?.abort();
    cancelRef.current = new AbortController();
    loadNextPage(state.searchText, state.nextPage, cancelRef.current?.signal);
    return () => {
      cancelRef.current?.abort();
    };
  }, [loadNextPage, state.searchText, state.nextPage]);

  return (
    <List
      isLoading={state.isLoading}
      onSearchTextChange={onSearchTextChange}
      pagination={{ onLoadMore, hasMore: state.hasMore, pageSize }}
    >
      {state.data.map((item) => (
        <List.Item
          key={`${item.page} ${item.index} ${item.text}`}
          title={`Page ${item.page} Item ${item.index}`}
          subtitle={item.text}
        />
      ))}
    </List>
  );
}
```

{% endtab %}
{% endtabs %}

{% hint style="warning" %}
Pagination might not work properly if all list items are rendered and visible at once, as `onLoadMore` won't be triggered. This typically happens when an API returns 10 results by default, all fitting within the Raycast window. To fix this, try displaying more items, like 20.
{% endhint %}

## Examples

{% tabs %}
{% tab title="List.tsx" %}

```jsx
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item title="Item 1" />
      <List.Item title="Item 2" subtitle="Optional subtitle" />
    </List>
  );
}
```

{% endtab %}

{% tab title="ListWithSections.tsx" %}

```jsx
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Section title="Section 1">
        <List.Item title="Item 1" />
      </List.Section>
      <List.Section title="Section 2" subtitle="Optional subtitle">
        <List.Item title="Item 1" />
      </List.Section>
    </List>
  );
}
```

{% endtab %}

{% tab title="ListWithActions.tsx" %}

```jsx
import { ActionPanel, Action, List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item
        title="Item 1"
        actions={
          <ActionPanel>
            <Action.CopyToClipboard content="👋" />
          </ActionPanel>
        }
      />
    </List>
  );
}
```

{% endtab %}

{% tab title="ListWithDetail.tsx" %}

```jsx
import { useState } from "react";
import { Action, ActionPanel, List } from "@raycast/api";
import { useCachedPromise } from "@raycast/utils";

interface Pokemon {
  name: string;
  height: number;
  weight: number;
  id: string;
  types: string[];
  abilities: Array<{ name: string; isMainSeries: boolean }>;
}

const pokemons: Pokemon[] = [
  {
    name: "bulbasaur",
    height: 7,
    weight: 69,
    id: "001",
    types: ["Grass", "Poison"],
    abilities: [
      { name: "Chlorophyll", isMainSeries: true },
      { name: "Overgrow", isMainSeries: true },
    ],
  },
  {
    name: "ivysaur",
    height: 10,
    weight: 130,
    id: "002",
    types: ["Grass", "Poison"],
    abilities: [
      { name: "Chlorophyll", isMainSeries: true },
      { name: "Overgrow", isMainSeries: true },
    ],
  },
];

export default function Command() {
  const [showingDetail, setShowingDetail] = useState(true);
  const { data, isLoading } = useCachedPromise(() => new Promise<Pokemon[]>((resolve) => resolve(pokemons)));

  return (
    <List isLoading={isLoading} isShowingDetail={showingDetail}>
      {data &&
        data.map((pokemon) => {
          const props: Partial<List.Item.Props> = showingDetail
            ? {
                detail: (
                  <List.Item.Detail
                    markdown={`![Illustration](https://assets.pokemon.com/assets/cms2/img/pokedex/full/${
                      pokemon.id
                    }.png)\n\n${pokemon.types.join(" ")}`}
                  />
                ),
              }
            : { accessories: [{ text: pokemon.types.join(" ") }] };
          return (
            <List.Item
              key={pokemon.id}
              title={pokemon.name}
              subtitle={`#${pokemon.id}`}
              {...props}
              actions={
                <ActionPanel>
                  <Action.OpenInBrowser url={`https://www.pokemon.com/us/pokedex/${pokemon.name}`} />
                  <Action title="Toggle Detail" onAction={() => setShowingDetail(!showingDetail)} />
                </ActionPanel>
              }
            />
          );
        })}
    </List>
  );
}

```

{% endtab %}

{% tab title="ListWithEmptyView.tsx" %}

```typescript
import { useEffect, useState } from "react";
import { List } from "@raycast/api";

export default function CommandWithCustomEmptyView() {
  const [state, setState] = useState({ searchText: "", items: [] });

  useEffect(() => {
    // perform an API call that eventually populates `items`.
  }, [state.searchText]);

  return (
    <List onSearchTextChange={(newValue) => setState((previous) => ({ ...previous, searchText: newValue }))}>
      {state.searchText === "" && state.items.length === 0 ? (
        <List.EmptyView icon={{ source: "https://placekitten.com/500/500" }} title="Type something to get started" />
      ) : (
        state.items.map((item) => <List.Item key={item} title={item} />)
      )}
    </List>
  );
}
```

{% endtab %}

{% endtabs %}

## API Reference

### List

Displays List.Section.

The list uses built-in filtering by indexing the title of list items and additionally keywords.

#### Example

```typescript
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List navigationTitle="Search Beers" searchBarPlaceholder="Search your favorite beer">
      <List.Item title="Augustiner Helles" />
      <List.Item title="Camden Hells" />
      <List.Item title="Leffe Blonde" />
      <List.Item title="Sierra Nevada IPA" />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| actions | A reference to an ActionPanel. It will only be shown when there aren't any children. | <code>React.ReactNode</code> | - |
| children | List sections or items. If List.Item elements are specified, a default section is automatically created. | <code>React.ReactNode</code> | - |
| filtering | Toggles Raycast filtering. When `true`, Raycast will use the query in the search bar to filter the  items. When `false`, the extension needs to take care of the filtering.    You can further define how native filtering orders sections by setting an object with a `keepSectionOrder` property:  When `true`, ensures that Raycast filtering maintains the section order as defined in the extension.  When `false`, filtering may change the section order depending on the ranking values of items. | <code>boolean</code> or <code>{ keepSectionOrder: boolean }</code> | - |
| isLoading | Indicates whether a loading bar should be shown or hidden below the search bar | <code>boolean</code> | - |
| isShowingDetail | Whether the List should have an area on the right side of the items to show additional details about the selected item.    When true, it is recommended not to show any accessories on the `List.Item` and instead show the additional information in the `List.Item.Detail` view. | <code>boolean</code> | - |
| navigationTitle | The main title for that view displayed in Raycast | <code>string</code> | - |
| onSearchTextChange | Callback triggered when the search bar text changes. | <code>(text: string) => void</code> | - |
| onSelectionChange | Callback triggered when the item selection in the list changes.    When the received id is `null`, it means that all items have been filtered out  and that there are no item selected | <code>(id: string) => void</code> | - |
| pagination | Configuration for pagination | <code>{ hasMore: boolean; onLoadMore: () => void; pageSize: number }</code> | - |
| searchBarAccessory | List.Dropdown that will be shown in the right-hand-side of the search bar. | <code>ReactElement&lt;List.Dropdown.Props, string></code> | - |
| searchBarPlaceholder | Placeholder text that will be shown in the search bar. | <code>string</code> | - |
| searchText | The text that will be displayed in the search bar. | <code>string</code> | - |
| selectedItemId | Selects the item with the specified id. | <code>string</code> | - |
| throttle | Defines whether the `onSearchTextChange` handler will be triggered on every keyboard press or with a delay for throttling the events.  Recommended to set to `true` when using custom filtering logic with asynchronous operations (e.g. network requests). | <code>boolean</code> | - |

### List.Dropdown

A dropdown menu that will be shown in the right-hand-side of the search bar.

#### Example

```typescript
import { List } from "@raycast/api";

type DrinkType = { id: string; name: string };

function DrinkDropdown(props: { drinkTypes: DrinkType[]; onDrinkTypeChange: (newValue: string) => void }) {
  const { drinkTypes, onDrinkTypeChange } = props;
  return (
    <List.Dropdown
      tooltip="Select Drink Type"
      storeValue={true}
      onChange={(newValue) => {
        onDrinkTypeChange(newValue);
      }}
    >
      <List.Dropdown.Section title="Alcoholic Beverages">
        {drinkTypes.map((drinkType) => (
          <List.Dropdown.Item key={drinkType.id} title={drinkType.name} value={drinkType.id} />
        ))}
      </List.Dropdown.Section>
    </List.Dropdown>
  );
}

export default function Command() {
  const drinkTypes: DrinkType[] = [
    { id: "1", name: "Beer" },
    { id: "2", name: "Wine" },
  ];
  const onDrinkTypeChange = (newValue: string) => {
    console.log(newValue);
  };
  return (
    <List
      navigationTitle="Search Beers"
      searchBarPlaceholder="Search your favorite drink"
      searchBarAccessory={<DrinkDropdown drinkTypes={drinkTypes} onDrinkTypeChange={onDrinkTypeChange} />}
    >
      <List.Item title="Augustiner Helles" />
      <List.Item title="Camden Hells" />
      <List.Item title="Leffe Blonde" />
      <List.Item title="Sierra Nevada IPA" />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| tooltip<mark style="color:red;">*</mark> | Tooltip displayed when hovering the dropdown. | <code>string</code> | - |
| children | Dropdown sections or items. If Dropdown.Item elements are specified, a default section is automatically created. | <code>React.ReactNode</code> | - |
| defaultValue | The default value of the dropdown.  Keep in mind that `defaultValue` will be configured once per component lifecycle. This means that if a user changes the value, `defaultValue` won't be configured on re-rendering.    **If you're using `storeValue` and configured it as `true` _and_ a Dropdown.Item with the same value exists, then it will be selected.**    **If you configure `value` at the same time as `defaultValue`, the `value` will have precedence over `defaultValue`.** | <code>string</code> | - |
| filtering | Toggles Raycast filtering. When `true`, Raycast will use the query in the search bar to filter the  items. When `false`, the extension needs to take care of the filtering.    You can further define how native filtering orders sections by setting an object with a `keepSectionOrder` property:  When `true`, ensures that Raycast filtering maintains the section order as defined in the extension.  When `false`, filtering may change the section order depending on the ranking values of items. | <code>boolean</code> or <code>{ keepSectionOrder: boolean }</code> | - |
| id | ID of the dropdown. | <code>string</code> | - |
| isLoading | Indicates whether a loading indicator should be shown or hidden next to the search bar | <code>boolean</code> | - |
| onChange | Callback triggered when the dropdown selection changes. | <code>(newValue: string) => void</code> | - |
| onSearchTextChange | Callback triggered when the search bar text changes. | <code>(text: string) => void</code> | - |
| placeholder | Placeholder text that will be shown in the dropdown search field. | <code>string</code> | - |
| storeValue | Indicates whether the value of the dropdown should be persisted after selection, and restored next time the dropdown is rendered. | <code>boolean</code> | - |
| throttle | Defines whether the `onSearchTextChange` handler will be triggered on every keyboard press or with a delay for throttling the events.  Recommended to set to `true` when using custom filtering logic with asynchronous operations (e.g. network requests). | <code>boolean</code> | - |
| value | The currently value of the dropdown. | <code>string</code> | - |

### List.Dropdown.Item

A dropdown item in a List.Dropdown

#### Example

```typescript
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List
      searchBarAccessory={
        <List.Dropdown tooltip="Dropdown With Items">
          <List.Dropdown.Item title="One" value="one" />
          <List.Dropdown.Item title="Two" value="two" />
          <List.Dropdown.Item title="Three" value="three" />
        </List.Dropdown>
      }
    >
      <List.Item title="Item in the Main List" />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The title displayed for the item. | <code>string</code> | - |
| value<mark style="color:red;">*</mark> | Value of the dropdown item.  Make sure to assign each unique value for each item. | <code>string</code> | - |
| icon | An optional icon displayed for the item. | <code>Image.ImageLike</code> | - |
| keywords | An optional property used for providing additional indexable strings for search.  When filtering the items in Raycast, the keywords will be searched in addition to the title. | <code>string[]</code> | - |

### List.Dropdown.Section

Visually separated group of dropdown items.

Use sections to group related menu items together.

#### Example

```typescript
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List
      searchBarAccessory={
        <List.Dropdown tooltip="Dropdown With Sections">
          <List.Dropdown.Section title="First Section">
            <List.Dropdown.Item title="One" value="one" />
          </List.Dropdown.Section>
          <List.Dropdown.Section title="Second Section">
            <List.Dropdown.Item title="Two" value="two" />
          </List.Dropdown.Section>
        </List.Dropdown>
      }
    >
      <List.Item title="Item in the Main List" />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children | The item elements of the section. | <code>React.ReactNode</code> | - |
| title | Title displayed above the section | <code>string</code> | - |

### List.EmptyView

A view to display when there aren't any items available. Use to greet users with a friendly message if the
extension requires user input before it can show any list items e.g. when searching for a package, an article etc.

Raycast provides a default `EmptyView` that will be displayed if the List component either has no children,
or if it has children, but none of them match the query in the search bar. This too can be overridden by passing an
empty view alongside the other `List.Item`s.

Note that the `EmptyView` is _never_ displayed if the `List`'s `isLoading` property is true and the search bar is empty.



#### Example

```typescript
import { useEffect, useState } from "react";
import { List } from "@raycast/api";

export default function CommandWithCustomEmptyView() {
  const [state, setState] = useState({ searchText: "", items: [] });

  useEffect(() => {
    // perform an API call that eventually populates `items`.
  }, [state.searchText]);

  return (
    <List onSearchTextChange={(newValue) => setState((previous) => ({ ...previous, searchText: newValue }))}>
      {state.searchText === "" && state.items.length === 0 ? (
        <List.EmptyView icon={{ source: "https://placekitten.com/500/500" }} title="Type something to get started" />
      ) : (
        state.items.map((item) => <List.Item key={item} title={item} />)
      )}
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| actions | A reference to an ActionPanel. | <code>React.ReactNode</code> | - |
| description | An optional description for why the empty view is shown. | <code>string</code> | - |
| icon | An icon displayed in the center of the EmptyView. | <code>Image.ImageLike</code> | - |
| title | The main title displayed for the Empty View. | <code>string</code> | - |

### List.Item

A item in the List.

This is one of the foundational UI components of Raycast. A list item represents a single entity. It can be a
GitHub pull request, a file, or anything else. You most likely want to perform actions on this item, so make it clear
to the user what this list item is about.

#### Example

```typescript
import { Icon, List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item icon={Icon.Star} title="Augustiner Helles" subtitle="0,5 Liter" accessories={[{ text: "Germany" }]} />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The main title displayed for that item, optionally with a tooltip. | <code>string</code> or <code>{ tooltip?: string; value: string }</code> | - |
| accessories | An optional array of List.Item.Accessory items displayed on the right side in a List.Item. | <code>List.Item.Accessory[]</code> | - |
| actions | An ActionPanel that will be updated for the selected list item. | <code>React.ReactNode</code> | - |
| detail | The `List.Item.Detail` to be rendered in the right side area when the parent List is showing details and the item is selected. | <code>React.ReactNode</code> | - |
| icon | An optional icon displayed for the list item. | <code>Image.ImageLike }</code> | - |
| id | ID of the item. This string is passed to the `onSelectionChange` handler of the List when the item is selected.  Make sure to assign each item a unique ID or a UUID will be auto generated. | <code>string</code> | - |
| keywords | An optional property used for providing additional indexable strings for search.  When filtering the list in Raycast through the search bar, the keywords will be searched in addition to the title. | <code>string[]</code> | - |
| quickLook | Optional information to preview files with Quick Look. Toggle the preview with Action.ToggleQuickLook. | <code>{ name?: string; path: "fs".PathLike }</code> | - |
| subtitle | An optional subtitle displayed next to the main title, optionally with a tooltip. | <code>string</code> or <code>{ tooltip?: string; value?: string }</code> | - |

### List.Item.Detail

A Detail view that will be shown in the right-hand-side of the `List`.

When shown, it is recommended not to show any accessories on the `List.Item` and instead bring those additional information in the `List.Item.Detail` view.



#### Example

```typescript
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List isShowingDetail>
      <List.Item
        title="Pikachu"
        subtitle="Electric"
        detail={
          <List.Item.Detail markdown="![Illustration](https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png)" />
        }
      />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| isLoading | Indicates whether a loading bar should be shown or hidden above the detail | <code>boolean</code> | - |
| markdown | The CommonMark string to be rendered in the right side area when the parent List is showing details and the item is selected. | <code>string</code> | - |
| metadata | The `List.Item.Detail.Metadata` to be rendered in the bottom side of the `List.Item.Detail` | <code>React.ReactNode</code> | - |

### List.Item.Detail.Metadata

A Metadata view that will be shown in the bottom side of the `List.Item.Detail`.

Use it to display additional structured data about the content of the `List.Item`.

#### Example

{% tabs %}

{% tab title="Metadata + Markdown" %}



```typescript
import { List } from "@raycast/api";

export default function Metadata() {
  const markdown = `
![Illustration](https://assets.pokemon.com/assets/cms2/img/pokedex/full/001.png)
There is a plant seed on its back right from the day this Pokémon is born. The seed slowly grows larger.
`;
  return (
    <List isShowingDetail>
      <List.Item
        title="Bulbasaur"
        detail={
          <List.Item.Detail
            markdown={markdown}
            metadata={
              <List.Item.Detail.Metadata>
                <List.Item.Detail.Metadata.Label title="Types" />
                <List.Item.Detail.Metadata.Label title="Grass" icon="pokemon_types/grass.svg" />
                <List.Item.Detail.Metadata.Separator />
                <List.Item.Detail.Metadata.Label title="Poison" icon="pokemon_types/poison.svg" />
                <List.Item.Detail.Metadata.Separator />
                <List.Item.Detail.Metadata.Label title="Chracteristics" />
                <List.Item.Detail.Metadata.Label title="Height" text="70cm" />
                <List.Item.Detail.Metadata.Separator />
                <List.Item.Detail.Metadata.Label title="Weight" text="6.9 kg" />
                <List.Item.Detail.Metadata.Separator />
                <List.Item.Detail.Metadata.Label title="Abilities" />
                <List.Item.Detail.Metadata.Label title="Chlorophyll" text="Main Series" />
                <List.Item.Detail.Metadata.Separator />
                <List.Item.Detail.Metadata.Label title="Overgrow" text="Main Series" />
                <List.Item.Detail.Metadata.Separator />
              </List.Item.Detail.Metadata>
            }
          />
        }
      />
    </List>
  );
}
```

{% endtab %}

{% tab title="Metadata Standalone" %}



```typescript
import { List } from "@raycast/api";

export default function Metadata() {
  return (
    <List isShowingDetail>
      <List.Item
        title="Bulbasaur"
        detail={
          <List.Item.Detail
            metadata={
              <List.Item.Detail.Metadata>
                <List.Item.Detail.Metadata.Label title="Types" />
                <List.Item.Detail.Metadata.Label title="Grass" icon="pokemon_types/grass.svg" />
                <List.Item.Detail.Metadata.Separator />
                <List.Item.Detail.Metadata.Label title="Poison" icon="pokemon_types/poison.svg" />
                <List.Item.Detail.Metadata.Separator />
                <List.Item.Detail.Metadata.Label title="Chracteristics" />
                <List.Item.Detail.Metadata.Label title="Height" text="70cm" />
                <List.Item.Detail.Metadata.Separator />
                <List.Item.Detail.Metadata.Label title="Weight" text="6.9 kg" />
                <List.Item.Detail.Metadata.Separator />
                <List.Item.Detail.Metadata.Label title="Abilities" />
                <List.Item.Detail.Metadata.Label title="Chlorophyll" text="Main Series" />
                <List.Item.Detail.Metadata.Separator />
                <List.Item.Detail.Metadata.Label title="Overgrow" text="Main Series" />
                <List.Item.Detail.Metadata.Separator />
              </List.Item.Detail.Metadata>
            }
          />
        }
      />
    </List>
  );
}
```

{% endtab %}

{% endtabs %}

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children<mark style="color:red;">*</mark> | The elements of the Metadata view. | <code>React.ReactNode</code> | - |

### List.Item.Detail.Metadata.Label

A title with, optionally, an icon and/or text to its right.



#### Example

```typescript
import { List } from "@raycast/api";

export default function Metadata() {
  return (
    <List isShowingDetail>
      <List.Item
        title="Bulbasaur"
        detail={
          <List.Item.Detail
            metadata={
              <List.Item.Detail.Metadata>
                <List.Item.Detail.Metadata.Label title="Type" icon="pokemon_types/grass.svg" text="Grass" />
              </List.Item.Detail.Metadata>
            }
          />
        }
      />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| title<mark style="color:red;">*</mark> | The title of the item. | <code>string</code> | - |
| icon | An icon to illustrate the value of the item. | <code>Image.ImageLike</code> | - |
| text | The text value of the item.  Specifying `color` will display the text in the provided color. Defaults to Color.PrimaryText. | <code>string</code> or <code>{ color?: Color; value: string }</code> | - |

### List.Item.Detail.Metadata.Link

An item to display a link.



#### Example

```typescript
import { List } from "@raycast/api";

export default function Metadata() {
  return (
    <List isShowingDetail>
      <List.Item
        title="Bulbasaur"
        detail={
          <List.Item.Detail
            metadata={
              <List.Item.Detail.Metadata>
                <List.Item.Detail.Metadata.Link
                  title="Evolution"
                  target="https://www.pokemon.com/us/pokedex/pikachu"
                  text="Raichu"
                />
              </List.Item.Detail.Metadata>
            }
          />
        }
      />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| target<mark style="color:red;">*</mark> | The target of the link. | <code>string</code> | - |
| text<mark style="color:red;">*</mark> | The text value of the item. | <code>string</code> | - |
| title<mark style="color:red;">*</mark> | The title shown above the item. | <code>string</code> | - |

### List.Item.Detail.Metadata.TagList

A list of `Tags` displayed in a row.



#### Example

```typescript
import { List } from "@raycast/api";

export default function Metadata() {
  return (
    <List isShowingDetail>
      <List.Item
        title="Bulbasaur"
        detail={
          <List.Item.Detail
            metadata={
              <List.Item.Detail.Metadata>
                <List.Item.Detail.Metadata.TagList title="Type">
                  <List.Item.Detail.Metadata.TagList.Item text="Electric" color={"#eed535"} />
                </List.Item.Detail.Metadata.TagList>
              </List.Item.Detail.Metadata>
            }
          />
        }
      />
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children<mark style="color:red;">*</mark> | The tags contained in the TagList. | <code>React.ReactNode</code> | - |
| title<mark style="color:red;">*</mark> | The title shown above the item. | <code>string</code> | - |

### List.Item.Detail.Metadata.TagList.Item

A Tag in a `List.Item.Detail.Metadata.TagList`.

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| color | Changes the text color to the provided color and sets a transparent background with the same color. | <code>Color.ColorLike</code> | - |
| icon | The optional icon tag icon. Required if the tag has no text. | <code>Image.ImageLike</code> | - |
| onAction | Callback that is triggered when the item is clicked. | <code>() => void</code> | - |
| text | The optional tag text. Required if the tag has no icon. | <code>string</code> | - |

### List.Item.Detail.Metadata.Separator

A metadata item that shows a separator line. Use it for grouping and visually separating metadata items.



#### Example

```typescript
import { List } from "@raycast/api";

export default function Metadata() {
  return (
    <List isShowingDetail>
      <List.Item
        title="Bulbasaur"
        detail={
          <List.Item.Detail
            metadata={
              <List.Item.Detail.Metadata>
                <List.Item.Detail.Metadata.Label title="Type" icon="pokemon_types/grass.svg" text="Grass" />
                <List.Item.Detail.Metadata.Separator />
                <List.Item.Detail.Metadata.Label title="Type" icon="pokemon_types/poison.svg" text="Poison" />
              </List.Item.Detail.Metadata>
            }
          />
        }
      />
    </List>
  );
}
```

### List.Section

A group of related List.Item.

Sections are a great way to structure your list. For example, group GitHub issues with the same status and order them by priority.
This way, the user can quickly access what is most relevant.

#### Example

```typescript
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Section title="Lager">
        <List.Item title="Camden Hells" />
      </List.Section>
      <List.Section title="IPA">
        <List.Item title="Sierra Nevada IPA" />
      </List.Section>
    </List>
  );
}
```

#### Props

| Prop | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| children | The List.Item elements of the section. | <code>React.ReactNode</code> | - |
| subtitle | An optional subtitle displayed next to the title of the section. | <code>string</code> | - |
| title | Title displayed above the section. | <code>string</code> | - |

## Types

### List.Item.Accessory

An interface describing an accessory view in a `List.Item`.



#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| tag<mark style="color:red;">*</mark> | A string or Date that will be used as the label, optionally colored. The date is formatted relatively to the current time (for example `new Date()` will be displayed as `"now"`, yesterday's Date will be displayed as "1d", etc.).  Color changes the text color to the provided color and sets a transparent background with the same color.  Defaults to Color.SecondaryText. | <code>string</code> or <code>[Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)</code> or <code>undefined</code> or <code>null</code> or <code>{ color?: Color.ColorLike</code> or <code>undefined</code> or <code>null }</code> |
| text | An optional text that will be used as the label, optionally colored.  Color changes the text color to the provided color.  Defaults to Color.SecondaryText. | <code>string</code> or <code>null</code> or <code>{ color?: Color; value: string</code> or <code>undefined</code> or <code>null }</code> |
| date | An optional Date that will be used as the label, optionally colored. The date is formatted relatively to the current time (for example `new Date()` will be displayed as `"now"`, yesterday's Date will be displayed as "1d", etc.).  Color changes the text color to the provided color.  Defaults to Color.SecondaryText. | <code>[Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)</code> or <code>null</code> or <code>{ color?: Color</code> or <code>undefined</code> or <code>null }</code> |
| icon | An optional Image.ImageLike that will be used as the icon. | <code>Image.ImageLike</code> or <code>null</code> |
| tooltip | An optional tooltip shown when the accessory is hovered. | <code>string</code> or <code>null</code> |

#### Example

```typescript
import { Color, Icon, List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item
        title="An Item with Accessories"
        accessories={[
          { text: `An Accessory Text`, icon: Icon.Hammer },
          { text: { value: `A Colored Accessory Text`, color: Color.Orange }, icon: Icon.Hammer },
          { icon: Icon.Person, tooltip: "A person" },
          { text: "Just Do It!" },
          { date: new Date() },
          { tag: new Date() },
          { tag: { value: new Date(), color: Color.Magenta } },
          { tag: { value: "User", color: Color.Magenta }, tooltip: "Tag with tooltip" },
        ]}
      />
    </List>
  );
}
```


# Navigation

## API Reference

### useNavigation

A hook that lets you push and pop view components in the navigation stack.

You most likely won't use this hook too often. To push a new component, use the Push Action.
When a user presses `ESC`, we automatically pop to the previous component.

#### Signature

```typescript
function useNavigation(): Navigation;
```

#### Example

```typescript
import { Action, ActionPanel, Detail, useNavigation } from "@raycast/api";

function Ping() {
  const { push } = useNavigation();

  return (
    <Detail
      markdown="Ping"
      actions={
        <ActionPanel>
          <Action title="Push" onAction={() => push(<Pong />)} />
        </ActionPanel>
      }
    />
  );
}

function Pong() {
  const { pop } = useNavigation();

  return (
    <Detail
      markdown="Pong"
      actions={
        <ActionPanel>
          <Action title="Pop" onAction={pop} />
        </ActionPanel>
      }
    />
  );
}

export default function Command() {
  return <Ping />;
}
```

#### Return

A Navigation functions.
Use the functions to alter the navigation stack.

## Types

### Navigation

Return type of the useNavigation hook to perform push and pop actions.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| pop<mark style="color:red;">*</mark> | Pop current view component from the navigation stack. | <code>() => void</code> |
| push<mark style="color:red;">*</mark> | Push a new view component to the navigation stack. | <code>(component: React.ReactNode, onPop: () => void) => void</code> |


# System Utilities

This set of utilities exposes some of Raycast's native functionality to allow deep integration into the user's setup. For example, you can use the Application APIs to check if a desktop application is installed and then provide an action to deep-link into it.

## API Reference

### getApplications

Returns all applications that can open the file or URL.

#### Signature

```typescript
async function getApplications(path?: PathLike): Promise<Application[]>;
```

#### Example

{% tabs %}
{% tab title="Find Application" %}

```typescript
import { getApplications, Application } from "@raycast/api";

// it is a lot more reliable to get an app by its bundle ID than its path
async function findApplication(bundleId: string): Application | undefined {
  const installedApplications = await getApplications();
  return installedApplications.filter((application) => application.bundleId == bundleId);
}
```

{% endtab %}

{% tab title="List Installed Applications" %}

```typescript
import { getApplications } from "@raycast/api";

export default async function Command() {
  const installedApplications = await getApplications();
  console.log("The following applications are installed on your Mac:");
  console.log(installedApplications.map((a) => a.name).join(", "));
}
```

{% endtab %}
{% endtabs %}

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| path | The path of the file or folder to get the applications for. If no path is specified, all installed applications are returned. | <code>"fs".PathLike</code> |

#### Return

An array of Application.

### getDefaultApplication

Returns the default application that the file or URL would be opened with.

#### Signature

```typescript
async function getDefaultApplication(path: PathLike): Promise<Application>;
```

#### Example

```typescript
import { getDefaultApplication } from "@raycast/api";

export default async function Command() {
  const defaultApplication = await getDefaultApplication(__filename);
  console.log(`Default application for JavaScript is: ${defaultApplication.name}`);
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| path<mark style="color:red;">*</mark> | The path of the file or folder to get the default application for. | <code>"fs".PathLike</code> |

#### Return

A Promise that resolves with the default Application that would open the file or URL. If no application was found, the promise will be rejected.

### getFrontmostApplication

Returns the frontmost application.

#### Signature

```typescript
async function getFrontmostApplication(): Promise<Application>;
```

#### Example

```typescript
import { getFrontmostApplication } from "@raycast/api";

export default async function Command() => {
  const frontmostApplication = await getFrontmostApplication();
  console.log(`The frontmost application is: ${frontmostApplication.name}`);
};
```

#### Return

A Promise that resolves with the frontmost Application. If no application was found, the promise will be rejected.

### showInFinder

Shows a file or directory in the Finder.

#### Signature

```typescript
async function showInFinder(path: PathLike): Promise<void>;
```

#### Example

```typescript
import { showInFinder } from "@raycast/api";
import { homedir } from "os";
import { join } from "path";

export default async function Command() {
  await showInFinder(join(homedir(), "Downloads"));
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| path<mark style="color:red;">*</mark> | The path to show in the Finder. | <code>"fs".PathLike</code> |

#### Return

A Promise that resolves when the item is revealed in the Finder.

### trash

Moves a file or directory to the Trash.

#### Signature

```typescript
async function trash(path: PathLike | PathLike[]): Promise<void>;
```

#### Example

```typescript
import { trash } from "@raycast/api";
import { writeFile } from "fs/promises";
import { homedir } from "os";
import { join } from "path";

export default async function Command() {
  const file = join(homedir(), "Desktop", "yolo.txt");
  await writeFile(file, "I will be deleted soon!");
  await trash(file);
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| path<mark style="color:red;">*</mark> | The item or items to move to the trash. | <code>"fs".PathLike</code> or <code>"fs".PathLike[]</code> |

#### Return

A Promise that resolves when all files are moved to the trash.

### open

Opens a target with the default application or specified application.

#### Signature

```typescript
async function open(target: string, application?: Application | string): Promise<void>;
```

#### Example

```typescript
import { open } from "@raycast/api";

export default async function Command() {
  await open("https://www.raycast.com", "com.google.Chrome");
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| target<mark style="color:red;">*</mark> | The file, folder or URL to open. | <code>string</code> |
| application | The application name to use for opening the file. If no application is specified, the default application as determined by the system  is used to open the specified file. Note that you can use the application name, app identifier, or absolute path to the app. | <code>string</code> or <code>Application</code> |

#### Return

A Promise that resolves when the target has been opened.

### captureException

Report the provided exception to the Developer Hub.
This helps in handling failures gracefully while staying informed about the occurrence of the failure.

#### Signature

```typescript
function captureException(exception: unknown): void;
```

#### Example

```typescript
import { open, captureException, showToast, Toast } from "@raycast/api";

export default async function Command() {
  const url = "https://www.raycast.com";
  const app = "Google Chrome";
  try {
    await open(url, app);
  } catch (e: unknown) {
    captureException(e);
    await showToast({
      style: Toast.Style.Failure,
      title: `Could not open ${url} in ${app}.`,
    });
  }
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| target<mark style="color:red;">*</mark> | The file, folder or URL to open. | <code>string</code> |
| application | The application name to use for opening the file. If no application is specified, the default application as determined by the system  is used to open the specified file. Note that you can use the application name, app identifier, or absolute path to the app. | <code>string</code> or <code>Application</code> |

## Types

### Application

An object that represents a locally installed application on the system.

It can be used to open files or folders in a specific application. Use getApplications or 
getDefaultApplication to get applications that can open a specific file or folder.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| name<mark style="color:red;">*</mark> | The display name of the application. | <code>string</code> |
| path<mark style="color:red;">*</mark> | The absolute path to the application bundle, e.g. `/Applications/Raycast.app`, | <code>string</code> |
| bundleId | The macOS bundle identifier of the application, e.g. `com.raycast.macos`. | <code>string</code> |
| localizedName | The localized name of the application. | <code>string</code> |
| windowsAppId | The Windows App ID of the application. | <code>string</code> |

### PathLike

```typescript
PathLike: string | Buffer | URL;
```

Supported path types.


# Raycast Window & Search Bar

## API Reference

### clearSearchBar

Clear the text in the search bar.

#### Signature

```typescript
async function clearSearchBar(options?: { forceScrollToTop?: boolean }): Promise<void>;
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| options | Can be used to control the behaviour after the search bar is cleared. | <code>Object</code> |
| options.forceScrollToTop | Can be used to force scrolling to the top. Defaults to scrolling to the top after the  the search bar was cleared. | <code>boolean</code> |

#### Return

A Promise that resolves when the search bar is cleared.

### closeMainWindow

Closes the main Raycast window.

#### Signature

```typescript
async function closeMainWindow(options?: { clearRootSearch?: boolean; popToRootType?: PopToRootType }): Promise<void>;
```

#### Example

```typescript
import { closeMainWindow } from "@raycast/api";
import { setTimeout } from "timers/promises";

export default async function Command() {
  await setTimeout(1000);
  await closeMainWindow({ clearRootSearch: true });
}
```

You can use the `popToRootType` parameter to temporarily prevent Raycast from applying the user's "Pop to Root Search" preference in Raycast; for example, when you need to interact with an external system utility and then allow the user to return back to the view command:

```typescript
import { closeMainWindow, PopToRootType } from "@raycast/api";

export default async () => {
  await closeMainWindow({ popToRootType: PopToRootType.Suspended });
};
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| options | Can be used to control the behaviour after closing the main window. | <code>Object</code> |
| options.clearRootSearch | Clears the text in the root search bar and scrolls to the top | <code>boolean</code> |
| options.popToRootType | Defines the pop to root behavior (PopToRootType); the default is to to respect the user's "Pop to Root Search" preference in Raycast | <code>PopToRootType</code> |

#### Return

A Promise that resolves when the main window is closed.

### popToRoot

Pops the navigation stack back to root search.

#### Signature

```typescript
async function popToRoot(options?: { clearSearchBar?: boolean }): Promise<void>;
```

#### Example

```typescript
import { Detail, popToRoot } from "@raycast/api";
import { useEffect } from "react";
import { setTimeout } from "timers";

export default function Command() {
  useEffect(() => {
    setTimeout(() => {
      popToRoot({ clearSearchBar: true });
    }, 3000);
  }, []);

  return <Detail markdown="See you soon 👋" />;
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| options | Can be used to control the behaviour after going back to the root search. | <code>Object</code> |
| options.clearSearchBar |  | <code>boolean</code> |

#### Return

A Promise that resolves when Raycast popped to root.

## Types

### PopToRootType

Defines the pop to root behavior when the main window is closed.

#### Enumeration members

| Name      | Description                                                    |
| :-------- | :------------------------------------------------------------- |
| Default   | Respects the user's "Pop to Root Search" preference in Raycast |
| Immediate | Immediately pops back to root                                  |
| Suspended | Prevents Raycast from popping back to root                     |


# Window Management

The Window Management API provides developers with some functions to create commands with some advanced logic to move Windows around.

{% hint style="info" %}

Some users might not have access to this API. If a user doesn't have access to Raycast Pro, they will be asked if they want to get access when your extension calls the Window Management API. If the user doesn't wish to get access, the API call will throw an error.

You can check if a user has access to the API using `environment.canAccess(WindowManagement)`.

The API is not accessible on Windows for now.

{% endhint %}

## API Reference

### WindowManagement.getActiveWindow

Gets the active Window.

#### Signature

```typescript
async function getActiveWindow(): Promise<Window>;
```

#### Example

```typescript
import { WindowManagement, showToast } from "@raycast/api";

export default async function Command() {
  try {
    const window = await WindowManagement.getActiveWindow();
    if (window.positionable) {
      await WindowManagement.setWindowBounds({ id: window.id, bounds: { position: { x: 100 } } });
    }
  } catch (error) {
    showToast({ title: `Could not move window: ${error.message}`, style: Toast.Style.Failure });
  }
}
```

#### Return

A Promise that resolves with the active Window. If no window is active, the promise will be rejected.

### WindowManagement.getWindowsOnActiveDesktop

Gets the list of Window.

#### Signature

```typescript
async function getWindowsOnActiveDesktop(): Promise<Window[]>;
```

#### Example

```typescript
import { WindowManagement, showToast } from "@raycast/api";

export default async function Command() {
  const windows = await WindowManagement.getWindowsOnActiveDesktop();
  const chrome = windows.find((x) => x.application?.bundleId === "com.google.Chrome");
  if (!chrome) {
    showToast({ title: "Couldn't find chrome", style: Toast.Style.Failure });
    return;
  }
  WindowManagement.setWindowBounds({ id: chrome.id, bounds: { position: { x: 100 } } });
}
```

#### Return

A Promise that resolves with an array of Windows.

### WindowManagement.getDesktops

Gets the list of Desktops available across all screens.

#### Signature

```typescript
async function getDesktops(): Promise<Desktop[]>;
```

#### Example

```typescript
import { WindowManagement, showToast } from "@raycast/api";

export default function Command() {
  const desktops = await WindowManagement.getDesktops();
  const screens = Set(desktops.map((desktop) => desktop.screenId));
  showToast({ title: `Found ${desktops.length} desktops on ${screens.size} screens.` });
}
```

#### Return

A Promise that resolves with the desktops.

### WindowManagement.setWindowBounds

Move a Window or make it fullscreen.

#### Signature

```typescript
async function setWindowBounds(
  options: { id: string } & (
    | {
        bounds: {
          position?: { x?: number; y?: number };
          size?: { width?: number; height?: number };
        };
        desktopId?: string;
      }
    | {
        bounds: "fullscreen";
      }
  )
): Promise<void>;
```

#### Example

```typescript
import { WindowManagement, showToast } from "@raycast/api";

export default async function Command() {
  try {
    const window = await WindowManagement.getActiveWindow();
    if (window.positionable) {
      await WindowManagement.setWindowBounds({ id: window.id, bounds: { position: { x: 100 } } });
    }
  } catch (error) {
    showToast({ title: `Could not move window: ${error.message}`, style: Toast.Style.Failure });
  }
}
```

#### Parameters

| Name | Description | Type |
| :--- | :--- | :--- |
| options<mark style="color:red;">*</mark> |  | <code>{ id: string }</code> or <code>{ bounds: { position?: { x?: number; y?: number }; size?: { height?: number; width?: number } }; desktopId?: string }</code> or <code>{ bounds: "fullscreen" }</code> |

#### Return

A Promise that resolves with the window was moved. If the move isn't possible (for example trying to make a window fullscreen that doesn't support it), the promise will be rejected.

## Types

### WindowManagement.Window

A Window from an Application.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| active<mark style="color:red;">*</mark> |  | <code>boolean</code> |
| bounds<mark style="color:red;">*</mark> |  | <code>{ position: { x: number; y: number }; size: { height: number; width: number } }</code> or <code>"fullscreen"</code> |
| desktopId<mark style="color:red;">*</mark> |  | <code>string</code> |
| fullScreenSettable<mark style="color:red;">*</mark> |  | <code>boolean</code> |
| id<mark style="color:red;">*</mark> |  | <code>string</code> |
| positionable<mark style="color:red;">*</mark> |  | <code>boolean</code> |
| resizable<mark style="color:red;">*</mark> |  | <code>boolean</code> |
| application |  | <code>Application</code> |

### WindowManagement.Desktop

A Desktop represents a virtual desktop on a Screen.

#### Properties

| Property | Description | Type |
| :--- | :--- | :--- |
| active<mark style="color:red;">*</mark> |  | <code>boolean</code> |
| id<mark style="color:red;">*</mark> |  | <code>string</code> |
| screenId<mark style="color:red;">*</mark> |  | <code>string</code> |
| size<mark style="color:red;">*</mark> |  | <code>{ height: number; width: number }</code> |
| type<mark style="color:red;">*</mark> |  | <code>WindowManagement.DesktopType</code> |

### WindowManagement.DesktopType

The type of a Desktop.

#### Enumeration members

| Name       | Description                                                                               |
| :--------- | :---------------------------------------------------------------------------------------- |
| User       | The default Desktop type. It can contain any number of Window |
| FullScreen | A Desktop made of a single fullscreen window                                              |


# Contribute to an Extension

All published extensions are open-source and can be found in [this repository](https://github.com/raycast/extensions). This makes it easy for multiple developers to collaborate. This guide explains how to import an extension in order to fix a bug, add a new feature or otherwise contribute to it.

## Get source code

First, you need to find the source code of the extension. The easiest way to do this is to use the `Fork Extension` action in the Raycast's root search.



## Develop the extension

After you have the source code locally, open the Terminal and navigate to the extension's folder. Once there, run `npm install && npm run dev` from the extension folder in your Terminal to start developing the extension.



You should see your forked extension at the top of your root search and can open its commands.

When you're done editing the extension, make sure to add yourself to the contributors section of its manifest. If you used the `Fork Extension` action, this should have happened automatically.

Additionally, ensure the `CHANGELOG.md` file is updated with your changes; create it if it doesn't exist. Use the `{PR_MERGE_DATE}` placeholder for the date – see the Version History documentation for details.

Once everything is ready, see how to publish an extension for instructions on validating and publishing the changes.


# Create Your First Extension

## Create a new extension

Open the Create Extension command, name your extension "Hello World" and select the "Detail" template. Pick a parent folder in the Location field and press `⌘` `↵` to continue.



{% hint style="info" %}
To create a private extension, select your organization in the first dropdown. You need to be logged in and part of an organization to see the dropdown. Learn more about Raycast for Teams here.
{% endhint %}

{% hint style="info" %}
To kickstart your extensions, Raycast provides various templates for commands and tools. Learn more here.
{% endhint %}

Next, you'll need to follow the on-screen instructions to build the extension.

## Build the extension

Open your terminal, navigate to your extension directory and run `npm install && npm run dev`. Open Raycast, and you'll notice your extension at the top of the root search. Press `↵` to open it.



## Develop your extension

To make changes to your extension, open the `./src/index.tsx` file in your extension directory, change the `markdown` text and save it. Then, open your command in Raycast again and see your changes.

{% hint style="info" %}
`npm run dev` starts the extension in development mode with hot reloading, error reporting and more.
{% endhint %}

## Use your extension

Now, you can press `⌃` `C` in your terminal to stop `npm run dev`. The extension stays in Raycast, and you can find its commands in the root when searching for the extension name "Hello World" or the command name "Render Markdown".



🎉 Congratulations! You built your first extension. Off to many more.

{% hint style="info" %}
Don't forget to run `npm run dev` again when you want to change something in your extension.
{% endhint %}


# Debug an Extension

Bugs are unavoidable. Therefore it's important to have an easy way to discover and fix them. This guide shows you how to find problems in your extensions.

## Console

Use the `console` for simple debugging such as logging variables, function calls, or other helpful messages. All logs are shown in the terminal during development mode. Here are a few examples:

```typescript
console.log("Hello World"); // Prints: Hello World

const name = "Thomas";
console.debug(`Hello ${name}`); // Prints: Hello Thomas

const error = new Error("Boom 💥");
console.error(error); // Prints: Boom 💥
```

For more, checkout the [Node.js documentation](https://nodejs.org/dist/latest-v16.x/docs/api/console.html).

We automatically disable console logging for store extensions.

## Visual Studio Code

For more complex debugging you can install the [VSCode extension](https://marketplace.visualstudio.com/items?itemName=tonka3000.raycast) to be able to attach a node.js debugger to the running Raycast session.

1. Activate your extension in dev mode via `npm run dev` or via the VSCode command `Raycast: Start Development Mode`
2. Start the VSCode command `Raycast: Attach Debugger`
3. Set your breakpoint like in any other node.js base project
4. Activate your command

## Unhandled exceptions and Promise rejections

All unhandled exceptions and Promise rejections are shown with an error overlay in Raycast.



During development, we show the stack trace and add an action to jump to the error to make it easy to fix it. In production, only the error message is shown. You should show a toast for all expected errors, e.g. a failing network request.

### Extension Issue Dashboard

When unhandled exceptions and Promise rejections occur in the production build of a public extension, Raycast tries to redact all potentially sensitive information they may include, and reports them to our error backend. As an extension author, or as the manager of an organisation, you can view and manage error reports for your public extensions by going to https://www.raycast.com/extension-issues, or by finding your extension in Raycast's root, `Store` command, or `Manage Extensions` command, and using the `View Issues` action.
The dashboard should give you an overview of what issues occurred, how many times, how many users were affected, and more. Each issue additionally has a detail view, including a stack trace, breadcrumbs (typically the actions performed before the crash), extension release date, Raycast version, macOS version.



## React Developer Tools

We support [React Developer Tools](https://github.com/facebook/react/tree/main/packages/react-devtools) out-of-the-box. Use the tools to inspect and change the props of your React components, and see the results immediately in Raycast. This is especially useful for complex commands with a lot of states.



To get started, add the `react-devtools` to your extension. Open a terminal, navigate to your extension directory and run the following command:

```typescript
npm install --save-dev react-devtools@6.1.1
```

Then re-build your extension with `npm run dev`, open the command you want to debug in Raycast, and launch the React Developer Tools with `⌘` `⌥` `D`. Now select one of the React components, change a prop in the right sidebar, and hit enter. You'll notice the change immediately in Raycast.

### Alternative: Global installation of React Developer Tools

If you prefer to install the `react-devtools` globally, you can do the following:

```bash
npm install -g react-devtools@6.1.1
```

Then you can run `react-devtools` from a terminal to launch the standalone DevTools app. Raycast connects automatically, and you can start debugging your component tree.

## Environments

By default, extensions installed from the store run in Node production mode and development extensions in development mode. In development mode, the CLI output shows you additional errors and warnings (e.g. the infamous warning when you're missing the React `key` property for your list items); performance is generally better when running in production mode. You can force development extensions to run in Node production mode by going to Raycast Preferences > Advanced > "Use Node production environment".

At runtime, you can check which Node environment you're running in:

```typescript
if (process.env.NODE_ENV === "development") {
  // running in development Node environment
}
```

To check whether you're running the store or local development version:

```typescript
import { environment } from "@raycast/api";

if (environment.isDevelopment) {
  // running the development version
}
```


# Getting Started

## System Requirements

Before you can create your first extension, make sure you have the following prerequisites.

- You have Raycast 1.26.0 or higher installed.
- You have [Node.js](https://nodejs.org) 22.14 or higher installed. We recommend [nvm](https://github.com/nvm-sh/nvm) to install Node.
- You have [npm](http://npmjs.com) 7 or higher
- You are familiar with [React](https://reactjs.org) and [TypeScript](https://www.typescriptlang.org). Don't worry, you don't need to be an expert. If you need some help with the basics, check out TypeScript's [Handbook](https://www.typescriptlang.org/docs/handbook/intro.html) and React's [Getting Started](https://react.dev/learn) guide.

## Sign In



You need to be signed in to use the following extension development commands.

- **Store:** Search and install all published extensions
- **Create Extension:** Create new extensions from templates
- **Import Extension:** Import extensions from source code
- **Manage Extensions**: List and edit your published extensions


# Install an Extension

All published extensions are discoverable in the Raycast Store. Use the [web interface](https://raycast.com/store) or the Store command to find what you're looking for.

## In-app Store

The easiest way to discover extensions is the in-app store. Open the Store command in Raycast and search for an extension. Press `⌘` `↵` to install the selected extension or press `↵` to see more details about it.



## Web Store

Alternatively, you can use our [web store](https://raycast.com/store). Press `⌘` `K` to open the command palette, search for an extension and open it.



Then press the Install Extension button in the top right corner and follow the steps in Raycast.



## Use installed extensions

After an extension is installed, you can search for its commands in the root search. The extension can be further configured in the Extensions preferences tab.


# Prepare an Extension for Store

Here you will find requirements and guidelines that you'll need to follow in order to get through the review before your extension becomes available in the Store. Please read it carefully because it will save time for you and for us. This document is constantly evolving so please do visit it from time to time.

## Metadata and Configuration

- Things to double-check in your `package.json`
  - Ensure you use your **Raycast** account username in the `author` field
  - Ensure you use `MIT` in the `license` field
  - Ensure you are using the latest Raycast API version
  - Ensure the `platforms` field matching the requirement of your extension, eg. if you use platform-specific APIs, restrict the `platforms` field to the corresponding platform
- Please use `npm` for installing dependencies and include `package-lock.json` in your pull request. We use `npm` on our Continuous Integration (CI) environment when building and publishing extensions so, by providing a `package-lock.json` file, we ensure that the dependencies on the server match the same versions as your local dependencies.
- Please check the terms of service of third-party services that your extension uses.
- Read the [Extension Guidelines](https://manual.raycast.com/extensions) and make sure that your Extension comply with it.
- Make sure to **run a distribution build** with `npm run build` locally before submitting the extension for review. This will perform additional type checking and create an optimized build. Open the extension in Raycast to check whether everything works as expected with the distribution build. In addition, you can perform linting and code style checks by running `npm run lint`. (Those checks will later also run via automated GitHub checks.)

## Extensions and Commands Naming

- Extension and command titles should follow [**Apple Style Guide**](https://help.apple.com/applestyleguide/#/apsgb744e4a3?sub=apdca93e113f1d64) convention
  - ✅ `Google Workplace`, `Doppler Share Secrets`, `Search in Database`
  - ❌ `Hacker news`, `my issues`
  - 🤔 It's okay to use lower case for names and trademarks that are canonically written with lower case letters. E.g. `iOS` , `macOS` , `npm`.
- **Extension title**
  - It will be used only in the Store and in the preferences
  - Make it easy for people to understand what it does when they see it in the Store
    - ✅ `Emoji Search`, `Airport - Discover Testflight Apps`, `Hacker News`
    - ❌ `Converter`, `Images`, `Code Review`, `Utils`
    - 🤔 In some cases, you can add additional information to the title similar to the Airport example above. Only do so if it adds context.
    - 💡 You can use more creative titles to differentiate your extension from other extensions with similar names.
  - Aim to use nouns rather than verbs
    - `Emoji Search` is better than `Search Emoji`
  - Avoid generic names for an extension when your extension doesn't provide a lot of commands
    - E.g. if your extension can only search pages in Notion, name it `Notion Search` instead of just `Notion`. This will help users to form the right expectations about your extension. If your extension covers a lot of functionality, it's okay to use a generic name like `Notion`. Example: [GitLab](https://www.raycast.com/tonka3000/gitlab).
    - **Rule of thumb:** If your extension has only one command, you probably need to name the extension close to what this command does. Example: [Visual Studio Code Recent Projects](https://www.raycast.com/thomas/visual-studio-code) instead of just `Visual Studio Code`.
- **Extension description**
  - In one sentence, what does your extension do? This will be shown in the list of extensions in the Store. Keep it short and descriptive. See how other approved extensions in the Store do it for inspiration.
- **Command title**
  - Usually it's `<verb> <noun>` structure or just `<noun>`
  - The best approach is to see how other commands are named in Raycast to get inspiration
    - ✅ `Search Recent Projects`, `Translate`, `Open Issues`, `Create Task`
    - ❌ `Recent Projects Search`, `Translation`, `New Task`
  - Avoid articles
    - ✅ `Search Emoji`, `Create Issue`
    - ❌ `Search an Emoji`, `Create an Issue`
  - Avoid just giving it a service name, be more specific about what the command does
    - ✅ `Search Packages`
    - ❌ `NPM`
- **Command subtitle**
  - Use subtitles to add context to your command. Usually, it's an app or service name that you integrate with. It makes command names more lightweight and removes the need to specify a service name in the command title.
  - The subtitle is indexed so you can still search using subtitle and title: `xcode recent projects` would return `Search Recent Projects` in the example above.
  - Don't use subtitles as descriptions for your command
    - ❌ `Quickly open Xcode recent projects`
  - Don't use a subtitle if it doesn't add context. Usually, this is the case with single command extensions.
    - There is no need for a subtitle for the `Search Emoji` command since it's self-explanatory
    - **Rule of thumb:** If your subtitle is almost a duplication of your command title, you probably don't need it



## Extension Icon

{% hint style="info" %}
We made a new icon generator tool to ease the process of creating icons for your extensions. You can find it [here](https://icon.ray.so/).
{% endhint %}

- The published extension in the Store should have a 512x512px icon in `png` format
- The icon should look good in both light and dark themes (you can switch the theme in Raycast Preferences → Appearance)
- If you have separate light and dark icons, refer to the `package.json` [manifest](https://developers.raycast.com/information/manifest#extension-properties) documentation on how to configure them
- Extensions that use the default Raycast icon will be rejected
- This [Icon Template](https://www.figma.com/community/file/1030764827259035122/Extensions-Icon-Template) can help you with making and exporting a proper icon
- Make sure to remove unused assets and icons
- 💡 If you feel like designing icons is not up to your alley, ask [community](https://raycast.com/community) for help (#extensions channel)

## Provide README if Additional Configuration Required

- If your extension requires additional setup, such as getting an API access token, enabling some preferences in other applications, or has non-trivial use cases, please provide a README file at the root folder of your extension. When a README is provided, users will see the "About This Extension" button on the preferences onboarding screen.
- Supporting README media: Put all linked media files in a top-level `media` folder inside your extension directory. (This is different from assets that are required at runtime in your extension: they go inside the assets folder and will be bundled into your extension.)



## Categories



- All extensions should be published with at least one category
- Categories are case-sensitive and should follow the [Title Case](https://titlecaseconverter.com/rules/) convention
- Add categories in the `package.json` [manifest](https://developers.raycast.com/information/manifest) file or select the categories when you create a new extension using the **Create Extension** command

### All Categories

| Category        | Example                                                                                                                                                         |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Applications    | [Cleanshot X](https://www.raycast.com/Aayush9029/cleanshotx) – Capture and record your screen                                                                   |
| Communication   | [Slack Status](https://www.raycast.com/petr/slack-status) – Quickly change your Slack status.                                                                   |
| Data            | [Random Data Generator](https://www.raycast.com/loris/random) – Generate random data using Faker library.                                                       |
| Documentation   | [Tailwind CSS Documentation](https://www.raycast.com/vimtor/tailwindcss) – Quickly search Tailwind CSS documentation and open it in the browser.                |
| Design Tools    | [Figma File Search](https://www.raycast.com/michaelschultz/figma-files-raycast-extension) – Lists Figma files allowing you to search and navigate to them.      |
| Developer Tools | [Brew](https://www.raycast.com/nhojb/brew) – Search and install Homebrew formulae.                                                                              |
| Finance         | [Coinbase Pro](https://www.raycast.com/farisaziz12/coinbase-pro) – View your Coinbase Pro portfolio.                                                            |
| Fun             | [8 Ball](https://www.raycast.com/rocksack/8-ball) – Returns an 8 ball like answer to questions.                                                                 |
| Media           | [Unsplash](https://www.raycast.com/eggsy/unsplash) – Search images or collections on Unsplash, download, copy or set them as wallpaper without leaving Raycast. |
| News            | [Hacker News](https://www.raycast.com/thomas/hacker-news) – Read the latest stories of Hacker News.                                                             |
| Productivity    | [Todoist](https://www.raycast.com/thomaslombart/todoist) – Check your Todoist tasks and quickly create new ones.                                                |
| Security        | [1Password 7](https://www.raycast.com/khasbilegt/1password7) – Search, open or edit your 1Password 7 passwords from Raycast.                                    |
| System          | [Coffee](https://www.raycast.com/mooxl/coffee) – Prevent the sleep function on your mac.                                                                        |
| Web             | [Wikipedia](https://www.raycast.com/vimtor/wikipedia) – Search Wikipedia articles and view them.                                                                |
| Other           | To be used if you think your extension doesn’t fit in any of the above categories.                                                                              |

## Screenshots



- Screenshots are displayed in the metadata of an extension details screen, where users can click and browse through them to understand what your extension does in greater detail, before installing
- You can add a maximum of six screenshots. We recommend adding at least three, so your extensions detail screen looks beautiful.

### Adding Screenshots

In Raycast 1.37.0+ we made it easy for you to take beautiful pixel perfect screenshots of your extension with an ease.

#### How to use it?

1. Set up Window Capture in Advanced Preferences (Hotkey e.g.: `⌘⇧⌥+M`)
2. Ensure your extension is opened in development mode (Window Capture eliminates dev-related menus/icons).
3. Open the command
4. Press the hotkey, remember to tick `Save to Metadata`

{% hint style="info" %}
This tool will use your current background. Choose a background image with a good contrast that makes it clear and easy to see the app and extension you've made.

You can use [Raycast Wallpapers](https://www.raycast.com/wallpapers) to make your background look pretty
{% endhint %}

### Specifications

| Screenshot size                | Aspect ratio | Format | Dark mode support |
| ------------------------------ | ------------ | ------ | ----------------- |
| 2000 x 1250 pixels (landscape) | 16:10        | PNG    | No                |

### Do's & Dont's

- ✅ Choose a background with good contrast, that makes it clear and easy to see the app and extension you’ve made
- ✅ Select the most informative commands to showcase what your extension does – focus on giving the user as much detail as possible
- ❌ Do not use multiple backgrounds for different screenshots – be consistent and use the same across all screenshots
- ❌ Do not share sensitive data in your screenshots – these will be visible in the Store, as well as the Extension repository on GitHub
- ❌ Do not include screenshots of other applications - keep the focus entirely on your extension within Raycast
- ❌ Avoid using screenshots in different themes (light and dark), unless it is to demonstrate what your extension does

## Version History



- Make it easier for users to see exactly what notable changes have been made between each release of your extension with a `CHANGELOG.md` file in your extension metadata
  - To add Version History to your extension, add a `CHANGELOG.md` file to the root folder of your extension
- See an extension files structure with screenshots and a changelog file
- With each modification, provide clear and descriptive details regarding the latest update, accompanied by a title formatted as an h2 header followed by `{PR_MERGE_DATE}`. This placeholder will be automatically replaced when the pull request is merged. While you may still use the date timestamp format YYYY-MM-DD, it is often more practical to use `{PR_MERGE_DATE}` since merging of a pull request can take several days (depending on the review comments, etc.).
  - Make sure your change title is within square brackets
  - Separate your title and date with a hyphen `-` and spaces either side of the hyphen
- Below is an example of a changelog that follows the correct format

```markdown
# Brew Changelog

## [Added a bunch of new feedback] - {PR_MERGE_DATE}

- Improve reliability of `outdated` command
- Add action to copy formula/cask name
- Add cask name & tap to cask details
- Add Toast action to cancel current action
- Add Toast action to copy error log after failure

## [New Additions] - 2022-12-13

- Add greedy upgrade preference
- Add `upgrade` command

## [Fixes & Bits] - 2021-11-19

- Improve discovery of brew prefix
- Update Cask.installed correctly after installation
- Fix installed state after uninstalling search result
- Fix cache check after installing/uninstalling cask
- Add uninstall action to outdated action panel

## [New Commands] - 2021-11-04

Add support for searching and managing casks

## [Added Brew] - 2021-10-26

Initial version code
```

![An extensions version history on raycast.com/store](https://user-images.githubusercontent.com/17166544/159987128-1e9f22a6-506b-4edd-bb40-e121bfdc46f8.png)

{% hint style="info" %}
You can use [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) to help you format your changelog correctly
{% endhint %}

## Contributing to Existing Extensions vs Creating a New One

- **When you should contribute to an existing extension instead of creating a new one**
  - You want to make a small improvement to an extension that is already published, e.g. extra actions, new preference, UX improvements, etc.. Usually, it's a non-significant change.
  - You want to add a simple command that compliments an existing extension without changing the extension title or description, e.g. you want to add "Like Current Track" command for Spotify. It wouldn't make sense to create a whole new extension just for this when there is already the [Spotify Controls](https://www.raycast.com/thomas/spotify-controls) extension.
  - **Important:** If your change is significant, it makes sense to contact the author of the extension before you invest a lot of time into it. We cannot merge significant contributions without the author's sign-off.
- **When you should consider creating a new extension instead of contributing to an existing one**
  - The changes to an existing extension would be significant and might break other people's workflows. Check with the author if you want to proceed with the collaboration path.
  - Your extension provides an integration with the same service but has a different configuration, e.g. one extension could be "GitHub Cloud", another "GitHub Enterprise". One extension could be "Spotify Controls" and only uses AppleScript to play/pause songs, while another extension can provide deeper integration via the API and require an access token setup. There is no reason to try to merge everything together as this would only make things more complicated.
- **Multiple simple extensions vs one large one**
  - If your extension works standalone and brings something new to the Store, it's acceptable to create a new one instead of adding commands to an existing one. E.g. one extension could be "GitHub Repository Search", another one could be "GitHub Issue Search". It should not be the goal to merge all extensions connecting with one service into one mega extension. However, it's also acceptable to merge two extensions under one if the authors decide to do so.

## Binary Dependencies and Additional Configuration

- Avoid asking users to perform additional downloads and try to automate as much as possible from the extension, especially if you are targeting non-developers. See the [Speedtest](https://github.com/raycast/extensions/pull/302) extension that downloads a CLI in the background and later uses it under the hood.
- If you do end up downloading executable binaries in the background, please make sure it's done from a server that you don't have access to. Otherwise, we cannot guarantee that you won't replace the binary with malicious code after the review. E.g. downloading `speedtest-cli` from [`install.speedtest.net`](http://install.speedtest.net) is acceptable, but doing this from some custom AWS server would lead to a rejection. Add additional integrity checks through hashes.
- Don't bundle opaque binaries where sources are unavailable or where it's unclear how they have been built.
- Don't bundle heavy binary dependencies in the extension – this would lead to an increased extension download size.
- **Examples for interacting with binaries**
  - ✅ Calling known system binaries
  - ✅ Binary downloaded or installed from a trusted location with additional integrity checking through hashes (that is, verify whether the downloaded binary really matches the expected binary)
  - ✅ Binary extracted from an npm package and copied to assets, with traceable sources how the binary is built; **note**: we have yet to integrate CI actions for copying and comparing the files; meanwhile, ask a member of the Raycast team to add the binary for you
  - ❌ Any binary with unavailable sources or unclear builds just added to the assets folder

## Keychain Access

- Extensions requesting Keychain Access will be rejected due to security concerns. If you can't work around this limitation, reach out to us on [Slack](https://raycast.com/community) or via `feedback@raycast.com`.

## UI/UX Guidelines

### Preferences



- Use the [preferences API](https://developers.raycast.com/api-reference/preferences) to let your users configure your extension or for providing credentials like API tokens
  - When using `required: true`, Raycast will ask the user to set preferences before continuing with an extension. See the example [here](https://github.com/raycast/extensions/blob/main/extensions/gitlab/package.json#L150).
- You should not build separate commands for configuring your extension. If you miss some API to achieve the preferences setup you want, please file a [GitHub issue](https://github.com/raycast/extensions/issues) with a feature request.

### Action Panel



- Actions in the action panel should also follow the **Title Case** naming convention
  - ✅ `Open in Browser`, `Copy to Clipboard`
  - ❌ `Copy url`, `set project`, `Set priority`
- Provide icons for actions if there are other actions with icons in the list
  - Avoid having a list of actions where some have icons and some don't
- Add ellipses `…` for actions that will have a submenu. Don't repeat the parent action name in the submenu
  - ✅ `Set Priority…` and submenu would have `Low`, `Medium`, `High`
  - ❌ `Set Priority` and submenu would have `Set Priority Low`, `Set Priority Medium`, etc

### Navigation

- Use the [Navigation API](https://developers.raycast.com/api-reference/user-interface/navigation) for pushing new screens. This will ensure that a user can navigate within your extension the same way as in the rest of the application.
- Avoid introducing your own navigation stack. Extensions that just replace the view's content when it's expected to push a new screen will be rejected.

### Empty States

- When you update lists with an empty array of elements, the "No results" view will be shown. You can customize this view by using the List.EmptyView components.
- **Common mistake** - "flickering empty state view" on start
  - If you try rendering an empty list before real data arrives (e.g. from the network or disk), you might see a flickering "No results" view when opening the extension. To prevent this, make sure not to return an empty list of items before you get the data you want to display. In the meantime, you can show the loading indicator. See [this example](https://developers.raycast.com/information/best-practices#show-loading-indicator).

### Navigation Title

- Don't change the `navigationTitle` in the root command - it will be automatically set to the command name. Use `navigationTitle` only in nested screens to provide additional context. See [Slack Status extension](https://github.com/raycast/extensions/blob/020f2232aa5579b5c63b4b3c08d23ad719bce1f8/extensions/slack-status/src/setStatusForm.tsx#L95) as an example of correct usage of the `navigationTitle` property.
- Avoid long titles. If you can't predict how long the navigation title string will be, consider using something else. E.g. in the Jira extension, we use the issue key instead of the issue title to keep it short.
- Avoid updating the navigation title multiple times on one screen depending on some state. If you find yourself doing it, there is a high chance you are misusing it.

### Placeholders in Text Fields

- For a better visual experience, add placeholders in text field and text area components. This includes preferences.
- Don't leave the search bar without a placeholder

### Analytics

- It’s not allowed to include external analytics in extensions. Later on, we will add support to give developers more insights into how their extension is being used.

### Localization / Language

- At the moment, Raycast doesn't support localization and only supports US English. Therefore, please avoid introducing your custom way to localize your extension. If the locale might affect functionality (e.g. using the correct unit of measurement), please use the preferences API.
- Use US English spelling (not British)


# Publish an Extension

Before you publish your extension, take a look at how to prepare your extension for the Store. Making sure you follow the guidelines is the best way to help your extension pass the review.

### Validate your extension

Open your terminal, navigate to your extension directory, and run `npm run build` to verify your extension. The command should complete without any errors.

{% hint style="info" %}
`npm run build` validates your extension for distribution without publishing it to the store. Read more about it here.
{% endhint %}

### Publish your extension

To share your extension with others, navigate to your extension directory, and run `npm run publish` to publish your extension. 

{% hint style="info" %}

It is possible that the `publish` script doesn't exist (usually because the extension was created before the template was updated to include it). In that case, you can add the following line in the `scripts` object of the package.json `"publish": "npx @raycast/api@latest publish"` and then run `npm run publish` again.

{% endhint %}

You will be asked to authenticate with GitHub because the script will automatically open a pull request in our [`raycast/extensions`](https://github.com/raycast/extensions) repository.

The command will squash commits and their commit messages. If you want more control, see the alternative way below.

{% hint style="info" %}
If someone contributes to your extension, or you make edits directly on GitHub, running `npm run publish` will fail until you run

```bash
npx @raycast/api@latest pull-contributions
```

in your git repository. This will merge the contributions with your code, asking you to fix the conflicts if any.
{% endhint %}

Once the pull request is opened, you can continue pushing more commits to it by running `npm run publish` again.

#### Alternative way

If you want more control over the publishing process, you can manually do what `npm run publish` does. You need to open a pull request in our [repository](https://github.com/raycast/extensions). For this, [fork our repository](https://docs.github.com/en/get-started/quickstart/fork-a-repo), add your extension to your fork, push your changes, and open a pull request [via the GitHub web interface](https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork) into our `main` branch.

### Waiting for review

After you opened a pull request, we'll review your extension and request changes when required. Once accepted, the pull request is merged and your extension will be automatically published to the [Raycast Store](https://raycast.com/store).

{% hint style="info" %}
We're still figuring things out and updating our guidelines. If something is unclear, please tell us in [our community](https://raycast.com/community).
{% endhint %}

### Share your extension

Once your extension is published in the Raycast Store, you can share it with our community. Open the Manage Extensions command, search for your extension and press `⌘` `⌥` `.` to copy the link.



🚀 Now it's time to share your work! Tweet about your extension, share it with our [Slack community](https://raycast.com/community) or send it to your teammates.


# Review an extension in a Pull Request

All updates to an extension are made through a [Pull Request](https://github.com/raycast/extensions/pulls) - if you need to review whether the Pull Request works as expected, then you can checkout the fork within a few seconds.

## Steps

1. Open a terminal window
2. Navigate to a folder where you want the repository to land
3. Run the below commands

_There are a few things you'll need to find and insert manually in the snippet below_

**FORK_URL**

Open the PR and click on the incomming ref as shown below



Now click the code button and copy the HTTPS path from the dropdown

**BRANCH**

You can see the branch on the above image (in this example it’s `notion-quicklinks`)

**EXTENSION_NAME**

Click the `Files Changed` tab to see in which directory files have been changed (in this example it’s `notion`)

```
BRANCH="ext/soundboard"
FORK_URL="https://github.com/pernielsentikaer/raycast-extensions.git"
EXTENSION_NAME="soundboard"

git clone -n --depth=1 --filter=tree:0 -b ${BRANCH} ${FORK_URL}
cd raycast-extensions
git sparse-checkout set --no-cone "extensions/${EXTENSION_NAME}"
git checkout
cd "extensions/${EXTENSION_NAME}"
npm install && npm run dev
```

4. That's it, the extension should now be attached in Raycast


# Doppler Share Secrets

{% hint style="info" %}
The full source code of the example can be found [here](https://github.com/raycast/extensions/tree/main/extensions/doppler-share-secrets#readme). You can install the extension [here](https://www.raycast.com/thomas/doppler-share-secrets).
{% endhint %}

In this example we use a form to collect inputs from a user. To make it interesting, we use [Doppler](http://share.doppler.com) which is a service to make it easy to securely share sensitive information such as API keys or passwords.



The extension has multiple commands. In this example we're using a simple form with a textfield for the secret, a dropdown for an expiration after views and a second dropdown for an alternate expiration after a maximum of days.

## Add form items

First, we render the static form. For this we add all the mentioned form items:

```typescript
import { Action, ActionPanel, Clipboard, Form, Icon, showToast, Toast } from "@raycast/api";
import got from "got";

export default function Command() {
  return (
    <Form>
      <Form.TextArea id="secret" title="Secret" placeholder="Enter sensitive data to securely share…" />
      <Form.Dropdown id="expireViews" title="Expire After Views" storeValue>
        <Form.Dropdown.Item value="1" title="1 View" />
        <Form.Dropdown.Item value="2" title="2 Views" />
        <Form.Dropdown.Item value="3" title="3 Views" />
        <Form.Dropdown.Item value="5" title="5 Views" />
        <Form.Dropdown.Item value="10" title="10 Views" />
        <Form.Dropdown.Item value="20" title="20 Views" />
        <Form.Dropdown.Item value="50" title="50 Views" />
        <Form.Dropdown.Item value="-1" title="Unlimited Views" />
      </Form.Dropdown>
      <Form.Dropdown id="expireDays" title="Expire After Days" storeValue>
        <Form.Dropdown.Item value="1" title="1 Day" />
        <Form.Dropdown.Item value="2" title="2 Days" />
        <Form.Dropdown.Item value="3" title="3 Days" />
        <Form.Dropdown.Item value="7" title="1 Week" />
        <Form.Dropdown.Item value="14" title="2 Weeks" />
        <Form.Dropdown.Item value="30" title="1 Month" />
        <Form.Dropdown.Item value="90" title="3 Months" />
      </Form.Dropdown>
    </Form>
  );
}
```

Both dropdowns set the `storeValue` to true. This restores the last selected value when the command is opened again. This option is handy when your users select the same options often. In this case, we assume that users want to keep the expiration settings persisted.

## Submit form values

Now that we have the form, we want to collect the inserted values, send them to Doppler and copy the URL that allows us to share the information securely. For this, we create a new action:

```tsx
function ShareSecretAction() {
  async function handleSubmit(values: { secret: string; expireViews: number; expireDays: number }) {
    if (!values.secret) {
      showToast({
        style: Toast.Style.Failure,
        title: "Secret is required",
      });
      return;
    }

    const toast = await showToast({
      style: Toast.Style.Animated,
      title: "Sharing secret",
    });

    try {
      const { body } = await got.post("https://api.doppler.com/v1/share/secrets/plain", {
        json: {
          secret: values.secret,
          expire_views: values.expireViews,
          expire_days: values.expireDays,
        },
        responseType: "json",
      });

      await Clipboard.copy((body as any).authenticated_url);

      toast.style = Toast.Style.Success;
      toast.title = "Shared secret";
      toast.message = "Copied link to clipboard";
    } catch (error) {
      toast.style = Toast.Style.Failure;
      toast.title = "Failed sharing secret";
      toast.message = String(error);
    }
  }

  return <Action.SubmitForm icon={Icon.Upload} title="Share Secret" onSubmit={handleSubmit} />;
}
```

Let's break this down:

- The `<ShareSecretAction>` returns an `<Action.SubmitForm>`.
- The `handleSubmit()` gets called when the form is submitted with it's values.
  - First we check if the user entered a secret. If not, we show a toast.
  - Then we show a toast to hint that there is a network call in progress to share the secret.
  - We call [Doppler's API](https://docs.doppler.com/reference/share-secret) with the form values
    - If the network response succeeds, we copy the authenticated URL to the clipboard and show a success toast.
    - If the network response fails, we show a failure toast with additional information about the failure.

## Wire it up

The last step is to add the `<ShareSecretAction>` to the form:

```typescript
import { Action, ActionPanel, Clipboard, Form, Icon, showToast, Toast } from "@raycast/api";
import got from "got";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <ShareSecretAction />
        </ActionPanel>
      }
    >
      <Form.TextArea id="secret" title="Secret" placeholder="Enter sensitive data to securely share…" />
      <Form.Dropdown id="expireViews" title="Expire After Views" storeValue>
        <Form.Dropdown.Item value="1" title="1 View" />
        <Form.Dropdown.Item value="2" title="2 Views" />
        <Form.Dropdown.Item value="3" title="3 Views" />
        <Form.Dropdown.Item value="5" title="5 Views" />
        <Form.Dropdown.Item value="10" title="10 Views" />
        <Form.Dropdown.Item value="20" title="20 Views" />
        <Form.Dropdown.Item value="50" title="50 Views" />
        <Form.Dropdown.Item value="-1" title="Unlimited Views" />
      </Form.Dropdown>
      <Form.Dropdown id="expireDays" title="Expire After Days" storeValue>
        <Form.Dropdown.Item value="1" title="1 Day" />
        <Form.Dropdown.Item value="2" title="2 Days" />
        <Form.Dropdown.Item value="3" title="3 Days" />
        <Form.Dropdown.Item value="7" title="1 Week" />
        <Form.Dropdown.Item value="14" title="2 Weeks" />
        <Form.Dropdown.Item value="30" title="1 Month" />
        <Form.Dropdown.Item value="90" title="3 Months" />
      </Form.Dropdown>
    </Form>
  );
}

function ShareSecretAction() {
  async function handleSubmit(values: { secret: string; expireViews: number; expireDays: number }) {
    if (!values.secret) {
      showToast({
        style: Toast.Style.Failure,
        title: "Secret is required",
      });
      return;
    }

    const toast = await showToast({
      style: Toast.Style.Animated,
      title: "Sharing secret",
    });

    try {
      const { body } = await got.post("https://api.doppler.com/v1/share/secrets/plain", {
        json: {
          secret: values.secret,
          expire_views: values.expireViews,
          expire_days: values.expireDays,
        },
        responseType: "json",
      });

      await Clipboard.copy((body as any).authenticated_url);

      toast.style = Toast.Style.Success;
      toast.title = "Shared secret";
      toast.message = "Copied link to clipboard";
    } catch (error) {
      toast.style = Toast.Style.Failure;
      toast.title = "Failed sharing secret";
      toast.message = String(error);
    }
  }

  return <Action.SubmitForm icon={Icon.Upload} title="Share Secret" onSubmit={handleSubmit} />;
}
```

And there you go. A simple form to enter a secret and get a URL that you can share with others that will "destroy itself" accordingly to your preferences. As next steps, you could use the `<PasteAction>` to paste the link directly to front-most application or add another action that clears the form and let's you create another shareable link.


# Hacker News

{% hint style="info" %}
The source code of the example can be found [here](https://github.com/raycast/extensions/tree/main/extensions/hacker-news#readme). You can install it [here](https://www.raycast.com/thomas/hacker-news).
{% endhint %}

Who doesn't like a good morning read on [Hacker News](https://news.ycombinator.com) with a warm coffee?! In this example, we create a simple list with the top stories on the frontpage.



## Load top stories

First, let's get the latest top stories. For this we use a [RSS feed](https://hnrss.org):

```typescript
import { Action, ActionPanel, List, showToast, Toast, Keyboard } from "@raycast/api";
import { useEffect, useState } from "react";
import Parser from "rss-parser";

const parser = new Parser();

interface State {
  items?: Parser.Item[];
  error?: Error;
}

export default function Command() {
  const [state, setState] = useState<State>({});

  useEffect(() => {
    async function fetchStories() {
      try {
        const feed = await parser.parseURL("https://hnrss.org/frontpage?description=0&count=25");
        setState({ items: feed.items });
      } catch (error) {
        setState({
          error: error instanceof Error ? error : new Error("Something went wrong"),
        });
      }
    }

    fetchStories();
  }, []);

  console.log(state.items); // Prints stories

  return <List isLoading={!state.items && !state.error} />;
}
```

Breaking this down:

- We use a third-party dependency to parse the RSS feed and intially the parser.
- We define our command state as a TypeScript interface.
- We use [React's `useEffect`](https://reactjs.org/docs/hooks-effect.html) hook to parse the RSS feed after the command did mount.
- We print the top stories to the console.
- We render a list and show the loading indicator as long as we load the stories.

## Render stories

Now that we got the data from Hacker News, we want to render the stories. For this, we create a new React component and a few helper functions that render a story:

```typescript
function StoryListItem(props: { item: Parser.Item; index: number }) {
  const icon = getIcon(props.index + 1);
  const points = getPoints(props.item);
  const comments = getComments(props.item);

  return (
    <List.Item
      icon={icon}
      title={props.item.title ?? "No title"}
      subtitle={props.item.creator}
      accessories={[{ text: `👍 ${points}` }, { text: `💬  ${comments}` }]}
    />
  );
}

const iconToEmojiMap = new Map<number, string>([
  [1, "1️⃣"],
  [2, "2️⃣"],
  [3, "3️⃣"],
  [4, "4️⃣"],
  [5, "5️⃣"],
  [6, "6️⃣"],
  [7, "7️⃣"],
  [8, "8️⃣"],
  [9, "9️⃣"],
  [10, "🔟"],
]);

function getIcon(index: number) {
  return iconToEmojiMap.get(index) ?? "⏺";
}

function getPoints(item: Parser.Item) {
  const matches = item.contentSnippet?.match(/(?<=Points:\s*)(\d+)/g);
  return matches?.[0];
}

function getComments(item: Parser.Item) {
  const matches = item.contentSnippet?.match(/(?<=Comments:\s*)(\d+)/g);
  return matches?.[0];
}
```

To give the list item a nice look, we use a simple number emoji as icon, add the creator's name as subtitle and the points and comments as accessory title. Now we can render the `<StoryListItem>`:

```typescript
export default function Command() {
  const [state, setState] = useState<State>({});

  // ...

  return (
    <List isLoading={!state.items && !state.error}>
      {state.items?.map((item, index) => (
        <StoryListItem key={item.guid} item={item} index={index} />
      ))}
    </List>
  );
}
```

## Add actions

When we select a story in the list, we want to be able to open it in the browser and also copy it's link so that we can share it in our watercooler Slack channel. For this, we create a new React Component:

```typescript
function Actions(props: { item: Parser.Item }) {
  return (
    <ActionPanel title={props.item.title}>
      <ActionPanel.Section>
        {props.item.link && <Action.OpenInBrowser url={props.item.link} />}
        {props.item.guid && <Action.OpenInBrowser url={props.item.guid} title="Open Comments in Browser" />}
      </ActionPanel.Section>
      <ActionPanel.Section>
        {props.item.link && (
          <Action.CopyToClipboard
            content={props.item.link}
            title="Copy Link"
            shortcut={Keyboard.Shortcut.Common.Copy}
          />
        )}
      </ActionPanel.Section>
    </ActionPanel>
  );
}
```

The component takes a story and renders an `<ActionPanel>` with our required actions. We add the actions to the `<StoryListItem>`:

```typescript
function StoryListItem(props: { item: Parser.Item; index: number }) {
  // ...

  return (
    <List.Item
      icon={icon}
      title={props.item.title ?? "No title"}
      subtitle={props.item.creator}
      accessories={[{ text: `👍 ${points}` }, { text: `💬  ${comments}` }]}
      // Wire up actions
      actions={<Actions item={props.item} />}
    />
  );
}
```

## Handle errors

Lastly, we want to be a good citizen and handle errors appropriately to guarantee a smooth experience. We'll show a toast whenever our network request fails:

```typescript
export default function Command() {
  const [state, setState] = useState<State>({});

  // ...

  if (state.error) {
    showToast({
      style: Toast.Style.Failure,
      title: "Failed loading stories",
      message: state.error.message,
    });
  }

  // ...
}
```

## Wrapping up

That's it, you have a working extension to read the frontpage of Hacker News. As next steps, you can add another command to show the jobs feed or add an action to copy a Markdown formatted link.


# Spotify Controls

{% hint style="info" %}
The source code of the example can be found [here](https://github.com/raycast/extensions/tree/main/extensions/spotify-controls#readme). You can install it [here](https://www.raycast.com/thomas/spotify-controls).
{% endhint %}

This example shows how to build commands that don't show a UI in Raycast. This type of command is useful for interactions with other apps such as skipping songs in Spotify or just simply running some scripts that don't need visual confirmation.



## Control Spotify macOS app

Spotify's macOS app supports AppleScript. This is great to control the app without opening it. For this, we use the [`run-applescript`](https://www.npmjs.com/package/run-applescript) package. Let's start by toggling play pause:

```typescript
import { runAppleScript } from "run-applescript";

export default async function Command() {
  await runAppleScript('tell application "Spotify" to playpause');
}
```

## Close Raycast main window

When performing this command, you'll notice that Raycast toggles the play pause state of the Spotify macOS app but the Raycast main window stays open. Ideally the window closes after you run the command. Then you can carry on with what you did before.

Here is how you can close the main window:

```typescript
import { closeMainWindow } from "@raycast/api";
import { runAppleScript } from "run-applescript";

export default async function Command() {
  await closeMainWindow();
  await runAppleScript('tell application "Spotify" to playpause');
}
```

Notice that we call the `closeMainWindow` function before running the AppleScript. This makes the command feel snappier.

With less than 10 lines of code, you executed a script and controlled the UI of Raycast. As a next step you could add more commands to skip a track.


# Todo List

{% hint style="info" %}
The source code of the example can be found [here](https://github.com/raycast/extensions/tree/main/examples/todo-list#readme).
{% endhint %}

What's an example section without a todo list?! Let's put one together in Raycast. This example will show how to render a list, navigate to a form to create a new element and update the list.



## Render todo list

Let's start with a set of todos and simply render them as a list in Raycast:

```typescript
import { List } from "@raycast/api";
import { useState } from "react";

interface Todo {
  title: string;
  isCompleted: boolean;
}

export default function Command() {
  const [todos, setTodos] = useState<Todo[]>([
    { title: "Write a todo list extension", isCompleted: false },
    { title: "Explain it to others", isCompleted: false },
  ]);

  return (
    <List>
      {todos.map((todo, index) => (
        <List.Item key={index} title={todo.title} />
      ))}
    </List>
  );
}
```

For this we define a TypeScript interface to describe out Todo with a `title` and a `isCompleted` flag that we use later to complete the todo. We use [React's `useState` hook](https://reactjs.org/docs/hooks-state.html) to create a local state of our todos. This allows us to update them later and the list will get re-rendered. Lastly we render a list of all todos.

## Create a todo

A static list of todos isn't that much fun. Let's create new ones with a form. For this, we create a new React component that renders the form:

```typescript
function CreateTodoForm(props: { onCreate: (todo: Todo) => void }) {
  const { pop } = useNavigation();

  function handleSubmit(values: { title: string }) {
    props.onCreate({ title: values.title, isCompleted: false });
    pop();
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Create Todo" onSubmit={handleSubmit} />
        </ActionPanel>
      }
    >
      <Form.TextField id="title" title="Title" />
    </Form>
  );
}

function CreateTodoAction(props: { onCreate: (todo: Todo) => void }) {
  return (
    <Action.Push
      icon={Icon.Pencil}
      title="Create Todo"
      shortcut={{ modifiers: ["cmd"], key: "n" }}
      target={<CreateTodoForm onCreate={props.onCreate} />}
    />
  );
}
```

The `<CreateTodoForm>` shows a single text field for the title. When the form is submitted, it calls the `onCreate` callback and closes itself.



To use the action, we add it to the `<List>` component. This makes the action available when the list is empty which is exactly what we want to create our first todo.

```typescript
export default function Command() {
  const [todos, setTodos] = useState<Todo[]>([]);

  function handleCreate(todo: Todo) {
    const newTodos = [...todos, todo];
    setTodos(newTodos);
  }

  return (
    <List
      actions={
        <ActionPanel>
          <CreateTodoAction onCreate={handleCreate} />
        </ActionPanel>
      }
    >
      {todos.map((todo, index) => (
        <List.Item key={index} title={todo.title} />
      ))}
    </List>
  );
}
```

## Complete a todo

Now that we can create new todos, we also want to make sure that we can tick off something on our todo list. For this, we create a `<ToggleTodoAction>` that we assign to the `<List.Item>`:

```typescript
export default function Command() {
  const [todos, setTodos] = useState<Todo[]>([]);

  // ...

  function handleToggle(index: number) {
    const newTodos = [...todos];
    newTodos[index].isCompleted = !newTodos[index].isCompleted;
    setTodos(newTodos);
  }

  return (
    <List
      actions={
        <ActionPanel>
          <CreateTodoAction onCreate={handleCreate} />
        </ActionPanel>
      }
    >
      {todos.map((todo, index) => (
        <List.Item
          key={index}
          icon={todo.isCompleted ? Icon.Checkmark : Icon.Circle}
          title={todo.title}
          actions={
            <ActionPanel>
              <ActionPanel.Section>
                <ToggleTodoAction todo={todo} onToggle={() => handleToggle(index)} />
              </ActionPanel.Section>
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}

function ToggleTodoAction(props: { todo: Todo; onToggle: () => void }) {
  return (
    <Action
      icon={props.todo.isCompleted ? Icon.Circle : Icon.Checkmark}
      title={props.todo.isCompleted ? "Uncomplete Todo" : "Complete Todo"}
      onAction={props.onToggle}
    />
  );
}
```

In this case we added the `<ToggleTodoAction>` to the list item. By doing this we can use the `index` to toggle the appropriate todo. We also added an icon to our todo that reflects the `isCompleted` state.

## Delete a todo

Similar to toggling a todo, we also add the possibility to delete one. You can follow the same steps and create a new `<DeleteTodoAction>` and add it to the `<List.Item>`.

```typescript
export default function Command() {
  const [todos, setTodos] = useState<Todo[]>([]);

  // ...

  function handleDelete(index: number) {
    const newTodos = [...todos];
    newTodos.splice(index, 1);
    setTodos(newTodos);
  }

  return (
    <List
      actions={
        <ActionPanel>
          <CreateTodoAction onCreate={handleCreate} />
        </ActionPanel>
      }
    >
      {todos.map((todo, index) => (
        <List.Item
          key={index}
          icon={todo.isCompleted ? Icon.Checkmark : Icon.Circle}
          title={todo.title}
          actions={
            <ActionPanel>
              <ActionPanel.Section>
                <ToggleTodoAction todo={todo} onToggle={() => handleToggle(index)} />
              </ActionPanel.Section>
              <ActionPanel.Section>
                <CreateTodoAction onCreate={handleCreate} />
                <DeleteTodoAction onDelete={() => handleDelete(index)} />
              </ActionPanel.Section>
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}

// ...

function DeleteTodoAction(props: { onDelete: () => void }) {
  return (
    <Action
      icon={Icon.Trash}
      title="Delete Todo"
      shortcut={{ modifiers: ["ctrl"], key: "x" }}
      onAction={props.onDelete}
    />
  );
}
```

We also gave the `<DeleteTodoAction>` a keyboard shortcut. This way users can delete todos quicker. Additionally, we also added the `<CreateTodoAction>` to the `<List.Item>`. This makes sure that users can also create new todos when there are some already.

Finally, our command looks like this:

```typescript
import { Action, ActionPanel, Form, Icon, List, useNavigation } from "@raycast/api";
import { useState } from "react";

interface Todo {
  title: string;
  isCompleted: boolean;
}

export default function Command() {
  const [todos, setTodos] = useState<Todo[]>([
    { title: "Write a todo list extension", isCompleted: false },
    { title: "Explain it to others", isCompleted: false },
  ]);

  function handleCreate(todo: Todo) {
    const newTodos = [...todos, todo];
    setTodos(newTodos);
  }

  function handleToggle(index: number) {
    const newTodos = [...todos];
    newTodos[index].isCompleted = !newTodos[index].isCompleted;
    setTodos(newTodos);
  }

  function handleDelete(index: number) {
    const newTodos = [...todos];
    newTodos.splice(index, 1);
    setTodos(newTodos);
  }

  return (
    <List
      actions={
        <ActionPanel>
          <CreateTodoAction onCreate={handleCreate} />
        </ActionPanel>
      }
    >
      {todos.map((todo, index) => (
        <List.Item
          key={index}
          icon={todo.isCompleted ? Icon.Checkmark : Icon.Circle}
          title={todo.title}
          actions={
            <ActionPanel>
              <ActionPanel.Section>
                <ToggleTodoAction todo={todo} onToggle={() => handleToggle(index)} />
              </ActionPanel.Section>
              <ActionPanel.Section>
                <CreateTodoAction onCreate={handleCreate} />
                <DeleteTodoAction onDelete={() => handleDelete(index)} />
              </ActionPanel.Section>
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}

function CreateTodoForm(props: { onCreate: (todo: Todo) => void }) {
  const { pop } = useNavigation();

  function handleSubmit(values: { title: string }) {
    props.onCreate({ title: values.title, isCompleted: false });
    pop();
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Create Todo" onSubmit={handleSubmit} />
        </ActionPanel>
      }
    >
      <Form.TextField id="title" title="Title" />
    </Form>
  );
}

function CreateTodoAction(props: { onCreate: (todo: Todo) => void }) {
  return (
    <Action.Push
      icon={Icon.Pencil}
      title="Create Todo"
      shortcut={{ modifiers: ["cmd"], key: "n" }}
      target={<CreateTodoForm onCreate={props.onCreate} />}
    />
  );
}

function ToggleTodoAction(props: { todo: Todo; onToggle: () => void }) {
  return (
    <Action
      icon={props.todo.isCompleted ? Icon.Circle : Icon.Checkmark}
      title={props.todo.isCompleted ? "Uncomplete Todo" : "Complete Todo"}
      onAction={props.onToggle}
    />
  );
}

function DeleteTodoAction(props: { onDelete: () => void }) {
  return (
    <Action
      icon={Icon.Trash}
      title="Delete Todo"
      shortcut={{ modifiers: ["ctrl"], key: "x" }}
      onAction={props.onDelete}
    />
  );
}
```

And that's a wrap. You created a todo list in Raycast, it's that easy. As next steps, you could extract the `<CreateTodoForm>` into a separate command. Then you can create todos also from the root search of Raycast and can even assign a global hotkey to open the form. Also, the todos aren't persisted. If you close the command and reopen it, they are gone. To persist, you can use the storage.


# FAQ

<details>

<summary>What's the difference between <a href="https://github.com/raycast/script-commands">script commands</a> and extensions?</summary>

Script commands were the first way to extend Raycast. They are a simple way to execute a shell script and show some limited output in Raycast. Extensions are our next iteration to extend Raycast. While scripts can be written in pretty much any scripting language, extensions are written in TypeScript. They can show rich user interfaces like lists and forms but can also be "headless" and just run a simple script.

Extensions can be shared with our community via our Store. This makes them easy to discover and use for not so technical folks that don't have homebrew or other shell integrations on their Mac.

</details>

<details>

<summary>Why can I not use <code>react-dom</code>?</summary>

Even though you write JS/TS code, everything is rendered natively in Raycast. There isn't any HTML or CSS involved. Therefore you don't need the DOM-specific methods that the `react-dom` package provides.

Instead, we implemented a custom [reconciler](https://reactjs.org/docs/reconciliation.html) that converts your React component tree to a render tree that Raycast understands. The render tree is used natively to construct a view hierarchy that is backed by [Apple's AppKit](https://developer.apple.com/documentation/appkit/). This is similar to how [React Native](https://reactnative.dev) works.

</details>

<details>

<summary>Can I import ESM packages in my extension?</summary>

Yes, but you need to convert your extension to ESM.

Quick steps:

- Make sure you are using TypeScript 4.7 or later.
- Add `"type": "module"` to your package.json.
- Add `"module": "node16", "moduleResolution": "node16"` to your tsconfig.json.
- Use only full relative file paths for imports: `import x from '.';` → `import x from './index.js';`.
- Remove `namespace` usage and use `export` instead.
- Use the [`node:` protocol](https://nodejs.org/api/esm.html#esm_node_imports) for Node.js built-in imports.
- **You must use a `.js` extension in relative imports even though you're importing `.ts` files.**

</details>


# Best Practices

## General

### Handle errors

Network requests can fail, permissions to files can be missing… More generally, errors happen. By default, we handle every unhandled exception or unresolved Promise and show error screens. However, you should handle the "expected" error cases for your command. You should aim not to disrupt the user's flow just because something went wrong. For example, if a network request fails but you can read the cache, show the cache. A user might not need the fresh data straight away. In most cases, it's best to show a `Toast` with information about the error.

Here is an example of how to show a toast for an error:

```typescript
import { Detail, showToast, Toast } from "@raycast/api";
import { useEffect, useState } from "react";

export default function Command() {
  const [error, setError] = useState<Error>();

  useEffect(() => {
    setTimeout(() => {
      setError(new Error("Booom 💥"));
    }, 1000);
  }, []);

  useEffect(() => {
    if (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Something went wrong",
        message: error.message,
      });
    }
  }, [error]);

  return <Detail markdown="Example for proper error handling" />;
}
```

### Handle runtime dependencies

Ideally, your extension doesn't depend on any runtime dependencies. In reality, sometimes locally installed apps or CLIs are required to perform functionality. Here are a few tips to guarantee a good user experience:

- If a command requires a runtime dependency to run (e.g. an app that needs to be installed by the user), show a helpful message.
  - If your extension is tightly coupled to an app, f.e. searching tabs in Safari or using AppleScript to control Spotify, checks don't always have to be strict because users most likely don't install the extension without having the dependency installed locally.
- If only some functionality of your extension requires the runtime dependency, consider making this functionality only available if the dependency is installed. Typically, this is the best case for actions, e.g. to open a URL in the desktop app instead of the browser.

### Show loading indicator

When commands need to load big data sets, it's best to inform the user about this. To keep your command snappy, it's important to render a React component as quickly as possible.

You can start with an empty list or a static form and then load the data to fill the view. To make the user aware of the loading process, you can use the `isLoading` prop on all top-level components, e.g. `<Detail>`.

Here is an example to show the loading indicator in a list:

```typescript
import { List } from "@raycast/api";
import { useEffect, useState } from "react";

export default function Command() {
  const [items, setItems] = useState<string[]>();

  useEffect(() => {
    setTimeout(() => {
      setItems(["Item 1", "Item 2", "Item 3"]);
    }, 1000);
  }, []);

  return (
    <List isLoading={items === undefined}>
      {items?.map((item, index) => (
        <List.Item key={index} title={item} />
      ))}
    </List>
  );
}
```

---

## Forms

### Use Forms Validation

Before submitting data, it is important to ensure all required form controls are filled out, in the correct format.

In Raycast, validation can be fully controlled from the API. To keep the same behavior as we have natively, the proper way of usage is to validate a `value` in the `onBlur` callback, update the `error` of the item and keep track of updates with the `onChange` callback to drop the `error` value. The useForm utils hook nicely wraps this behaviour and is the recommended way to do deal with validations.



{% hint style="info" %}
Keep in mind that if the Form has any errors, the `Action.SubmitForm` `onSubmit` callback won't be triggered.
{% endhint %}

{% tabs %}

{% tab title="FormValidationWithUtils.tsx" %}

```tsx
import { Action, ActionPanel, Form, showToast, Toast } from "@raycast/api";
import { useForm, FormValidation } from "@raycast/utils";

interface SignUpFormValues {
  name: string;
  password: string;
}

export default function Command() {
  const { handleSubmit, itemProps } = useForm<SignUpFormValues>({
    onSubmit(values) {
      showToast({
        style: Toast.Style.Success,
        title: "Yay!",
        message: `${values.name} account created`,
      });
    },
    validation: {
      name: FormValidation.Required,
      password: (value) => {
        if (value && value.length < 8) {
          return "Password must be at least 8 symbols";
        } else if (!value) {
          return "The item is required";
        }
      },
    },
  });
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit" onSubmit={handleSubmit} />
        </ActionPanel>
      }
    >
      <Form.TextField title="Full Name" placeholder="Tim Cook" {...itemProps.name} />
      <Form.PasswordField title="New Password" {...itemProps.password} />
    </Form>
  );
}
```

{% endtab %}

{% tab title="FormValidationWithoutUtils.tsx" %}

```typescript
import { Form } from "@raycast/api";
import { useState } from "react";

export default function Command() {
  const [nameError, setNameError] = useState<string | undefined>();
  const [passwordError, setPasswordError] = useState<string | undefined>();

  function dropNameErrorIfNeeded() {
    if (nameError && nameError.length > 0) {
      setNameError(undefined);
    }
  }

  function dropPasswordErrorIfNeeded() {
    if (passwordError && passwordError.length > 0) {
      setPasswordError(undefined);
    }
  }

  return (
    <Form>
      <Form.TextField
        id="nameField"
        title="Full Name"
        placeholder="Tim Cook"
        error={nameError}
        onChange={dropNameErrorIfNeeded}
        onBlur={(event) => {
          if (event.target.value?.length == 0) {
            setNameError("The field should't be empty!");
          } else {
            dropNameErrorIfNeeded();
          }
        }}
      />
      <Form.PasswordField
        id="password"
        title="New Password"
        error={passwordError}
        onChange={dropPasswordErrorIfNeeded}
        onBlur={(event) => {
          const value = event.target.value;
          if (value && value.length > 0) {
            if (!validatePassword(value)) {
              setPasswordError("Password should be at least 8 characters!");
            } else {
              dropPasswordErrorIfNeeded();
            }
          } else {
            setPasswordError("The field should't be empty!");
          }
        }}
      />
      <Form.TextArea id="bioTextArea" title="Add Bio" placeholder="Describe who you are" />
      <Form.DatePicker id="birthDate" title="Date of Birth" />
    </Form>
  );
}

function validatePassword(value: string): boolean {
  return value.length >= 8;
}
```

{% endtab %}

{% endtabs %}


# Tools

Raycast provides several tools to smoothen your experience when building extensions:

- Manage Extensions Command _- A Raycast command to manage your extensions, add new command, etc._
- CLI _- A CLI to build, develop, and lint your extension_
- ESLint _- An ESLint configuration helping you follow best practices as you build your extension_
- Forked Extensions (community tool) - _The extension for helping you manage your forked Raycast extensions_
- VS Code (community tool) _- A VS Code extension to enhance your development experience_


# CLI

The CLI is part of the `@raycast/api` package and is automatically installed in your extension directory during setup. To get a list of the available CLI commands, run the following command inside your extension directory:

```bash
 npx ray help
```

## Build

`npx ray build` creates an optimized production build of your extension for distribution. This command is used by our CI to publish your extension to the store.

You can use `npx ray build -e dist` to validate that your extension builds properly.

## Development

`npx ray develop` starts your extension in development mode. The mode includes the following:

- Extension shows up at the top of the root search for quick access
- Commands get automatically reloaded when you save your changes (you can toggle auto-reloading via Raycast Preferences > Advanced > "Auto-reload on save")
- Error overlays include detailed stack traces for faster debugging
- Log messages are displayed in the terminal
- Status indicator is visible in the navigation title of the command to signal build errors
- Imports the extension to Raycast if it wasn't before

## Lint

`npx ray lint` runs [ESLint](http://eslint.org) for all files in the `src` directory.

## Migrate

`npx ray migrate` migrates your extension to the latest version of the `@raycast/api`.

## Publish

`npx ray publish` verifies, builds, and publishes an extension.

If the extension is private (eg. has an `owner` and no public `access`), it will be published to the organization's private store. This command is only available to users that are part of that organization. Learn more about it here.


# ESLint

Raycast makes it easy to lint your extensions using the CLI's lint command (`ray lint`).

Raycast provides by default an [opinionated ESLint configuration](https://github.com/raycast/eslint-config/blob/main/index.js) that includes everything you need to lint your Raycast extensions. The default configuration is as simple as this:

```js
import { defineConfig } from "eslint/config";
import raycastConfig from "@raycast/eslint-config";

export default defineConfig([...raycastConfig]);
```

It abstracts away the different ESLint dependencies used for Raycast extensions and includes different rule-sets.

It also includes Raycast's own ESLint plugin rule-set that makes it easier for you to follow best practices when building extension. For example, there's a [rule](https://github.com/raycast/eslint-plugin/blob/main/docs/rules/prefer-title-case.md) helping you follow the Title Case convention for `Action` components.

You can check Raycast's ESLint plugin rules directly on the [repository documentation](https://github.com/raycast/eslint-plugin#rules).

## Customization

You're free to turn on/off rules or add new plugins as you see fit for your extensions. For example, you could add the rule [`@raycast/prefer-placeholders`](https://github.com/raycast/eslint-plugin/blob/main/docs/rules/prefer-placeholders.md) for your extension:

```js
import { defineConfig } from "eslint/config";
import raycastConfig from "@raycast/eslint-config";

export default defineConfig([
  ...raycastConfig,
  {
    rules: {
      "@raycast/prefer-placeholders": "warn",
    },
  },
]);
```

To keep the consistency of development experiences across extensions, we don't encourage adding too many personal ESLint preferences to an extension.

## Migration

Starting with version 1.48.8, the ESLint configuration is included automatically when creating a new extension using the `Create Extension` command. If your extension was created before this version, you can migrate following the steps outlined on the [v1.48.8](https://developers.raycast.com/migration/v1.48.8) page.


# Forked Extensions (community tool)

This extension leverages the [Git sparse-checkout](https://git-scm.com/docs/git-sparse-checkout) feature to efficiently manage your forked extensions. Our goal is to eliminate the need for cloning the entire repository, which can exceed 20 GB in size, by enabling sparse-checkout. With this extension, you can forgo Ray CLI's commands, allowing you to use Git commands directly and regular [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow) for managing your extensions.

## Features

- Explore full extension list
- Only fork the extension you need to save space
- Remove an extension from forked list
- Synchronize the forked repository with the upstream repository on local

## Install

The extension is available on the [Raycast Store](https://www.raycast.com/litomore/forked-extensions).

<p align="center"><a title="Install forked-extensions Raycast Extension" href="https://www.raycast.com/litomore/forked-extensions"><img src="https://www.raycast.com/litomore/forked-extensions/install_button@2x.png?v=1.1" height="64" style="height: 64px;" alt=""></a></p>

## Hint

Please note with this extension you no longer need to use Ray CLI's `pull-contributions` and `publish` commands. Just use Git commands or your favorite Git GUI tool to manage your forked extensions.


# `Manage Extensions` Command

Raycast provides a built-in command to manage your extensions.



For each extensions, there are a few actions to manage them.

## Add New Command

One such action is the `Add New Command` action.



It will prompt you for the information about the new command before updating the manifest of the extension and creating the file for you based on the template you selected.


# Templates

Raycast provides a variety of templates to kickstart your extension.

Raycast provides 3 types of templates:

- **Commands:** These are templates for commands.
- **Tools:** These are templates for tools. You can select a different one for each tool that you add to your extension.
- **Extension Boilerplates:** These are fully built extensions designed to be tweaked by organizations for internal use.

## Commands

### Show Detail

<details>
<summary>Renders a simple Hello World from a markdown string. </summary>


{% hint style="info" %}
See the API Reference for more information about customization.
{% endhint %}

</details>

### Submit Form

<details>
<summary>Renders a form that showcases all available form elements.</summary>


{% hint style="info" %}
See the API Reference for more information about customization.
{% endhint %}

</details>

### Show Grid

<details>

<summary>Renders a grid of Icons available from Raycast.</summary>
Defaults to a large grid, but provides a selection menu to change the size.


{% hint style="info" %}
See the API Reference for more information about customization.

See here for information about Icons.
{% endhint %}

</details>

### Show List and Detail

<details>
<summary>Renders a list of options. When an option is selected, a Detail view is displayed.</summary>


{% hint style="info" %}
See the API Reference for more information about customization.
{% endhint %}

</details>

### Menu Bar Extra

<details>
<summary>Adds a simple Menu Bar Extra with a menu.</summary>


{% hint style="info" %}
See the API Reference for more information about customization.
{% endhint %}

</details>

### Run Script

A example of a no-view command which shows a simple HUD.

### Show List

<details>
<summary>Renders a static list with each entry containing an icon, title, subtitle, and accessory.</summary>


{% hint style="info" %}
See the API Reference for more information about customization.
{% endhint %}

</details>

### Show Typeahead Results

<details>
<summary>Renders a dynamic and searchable list of NPM packages. The command fetches new items as the search is updated by the user.</summary>



</details>

### AI

<details>
<summary>Renders the output of an AI call in a Detail view.</summary>



</details>

## Tools

<details>

<summary>A simple tool which asks for confirmation before executing.</summary>


{% hint style="info" %}
See the API Reference for more information about customization.
{% endhint %}

</details>

## Extension Boilerplates

The Raycast Team has created high-quality templates to reinforce team experiences with the Raycast API.

Run `npm init raycast-extension -t <template-name>` to get started with these extensions. All templates can be found on the [templates page](https://www.raycast.com/templates).

Specific instructions about customizing the template can be found on the relevant [template page](https://www.raycast.com/templates). Simply customize the template as you see fit, then run `npm run publish` in the extension directory to allow your team to install the extension.


# VS Code (community tool)

You can enhance your VS Code development experience by installing the [Raycast extension in the marketplace](https://marketplace.visualstudio.com/items?itemName=tonka3000.raycast). Here's a list of features provided by the extension:

- IntelliSense for image assets
- A tree view for easier navigation (commands and preferences)
- VS Code commands for creating new commands and preferences
- The possibility to attach a Node.js debugger
- VS Code commands for `ray` operations like `build`, `dev`, `lint`, or `fix-lint`


# File Structure

An extension consists of at least an entry point file (e.g. `src/index.ts`) and a `package.json` manifest file. We add a few more support files when scaffolding an extension to streamline development with modern JavaScript tooling.

The typical directory structure of a newly created extension looks like this:

```bash
extension
├── .eslintrc.json
├── .prettierrc
├── assets
│   └── icon.png
├── node_modules
├── package-lock.json
├── package.json
├── src
│   ├── command.tsx
└── tsconfig.json
```

The directory contains all source files, assets, and a few support files. Let's go over each of them:

## Sources

Put all your source files into the `src` folder. We recommend using TypeScript as a programming language. Our API is fully typed, which helps you catch errors at compile time rather than runtime. `ts`, `tsx`, `js` and `jsx` are supported as file extensions. As a rule of thumb, use `tsx` or `jsx` for commands with a UI.

An extension consists of at least an entry point file (e.g. `src/command.ts`) per command and a `package.json` manifest file holding metadata about the extension, its commands, and its tools. The format of the manifest file is very similar to [that of npm packages](https://docs.npmjs.com/cli/v7/configuring-npm/package-json). In addition to some of the standard properties, there are some additional properties, in particular, the `commands` properties which describes the entry points exposed by the extension.

Each command has a property `name` that maps to its main entry point file in the `src` folder. For example, a command with the name `create` in the `package.json` file, maps to the file `src/create{.ts,.tsx,.js,.jsx}`.

## Assets

The optional `assets` folder can contain icons that will be packaged into the extension archive. All bundled assets can be referenced at runtime. Additionally, icons can be used in the `package.json` as extension or command icons.

## Support files

The directory contains a few more files that setup common JavaScript tooling:

- **eslint.config.js** describes rules for [ESLint](https://eslint.org), which you can run with `npm run lint`. It has recommendations for code style and best practices. Usually, you don't have to edit this file.
- **.prettierrc** contains default rules for [Prettier](https://prettier.io) to format your code. We recommend to setup the [VS Code extension](https://prettier.io/docs/en/editors.html#visual-studio-code) to keep your code pretty automatically.
- **node_modules** contains all installed dependencies. You shouldn't make any manual changes to this folder.
- **package-lock.json** is a file generated by npm to install your dependencies. You shouldn't make any manual changes to this file.
- **package.json** is the manifest file containing metadata about your extension such as its title, the commands, and its dependencies.
- **tsconfig.json** configures your project to use TypeScript. Most likely, you don't have to edit this file.


# Lifecycle

A command is typically launched, runs for a while, and then is unloaded.

## Launch

When a command is launched in Raycast, the command code is executed right away. If the extension exports a default function, this function will automatically be called. If you return a React component in the exported default function, it will automatically be rendered as the root component. For commands that don't need a user interface (`mode` property set to "`no-view"` in the manifest), you can export an async function and perform API methods using async/await.

{% tabs %}
{% tab title="View Command" %}

```typescript
import { Detail } from "@raycast/api";

// Returns the main React component for a view command
export default function Command() {
  return <Detail markdown="# Hello" />;
}
```

{% endtab %}

{% tab title="No-View Command" %}

```typescript
import { showHUD } from "@raycast/api";

// Runs async. code in a no-view command
export default async function Command() {
  await showHUD("Hello");
}
```

{% endtab %}
{% endtabs %}

There are different ways to launch a command:

- The user searches for the command in the root search and executes it.
- The user registers an alias for the command and presses it.
- Another command launches the command _via_ `launchCommand`.
- The command was launched in the background.
- A Form's Draft was saved and the user executes it.
- A user registers the command as a [fallback command](https://manual.raycast.com/fallback-commands) and executes it when there are no results in the root search.
- A user clicks a Deeplink

Depending on how the command was launched, different arguments will be passed to the exported default function.

```typescript
import { Detail, LaunchProps } from "@raycast/api";

// Access the different launch properties via the argument passed to the function
export default function Command(props: LaunchProps) {
  return <Detail markdown={props.fallbackText || "# Hello"} />;
}
```

### LaunchProps

| Property | Description | Type |
| :--- | :--- | :--- |
| arguments<mark style="color:red;">*</mark> | Use these values to populate the initial state for your command. | <code>Arguments</code> |
| launchType<mark style="color:red;">*</mark> | The type of launch for the command (user initiated or background). | <code>LaunchType</code> |
| draftValues | When a user enters the command via a draft, this object will contain the user inputs that were saved as a draft.  Use its values to populate the initial state for your Form. | <code>Form.Values</code> |
| fallbackText | When the command is launched as a fallback command, this string contains the text of the root search. | <code>string</code> |
| launchContext | When the command is launched programmatically via `launchCommand`, this object contains the value passed to `context`. | <code>LaunchContext</code> |

## Unloading

When the command is unloaded (typically by popping back to root search for view commands or after the script finishes for no-view commands), Raycast unloads the entire command from memory. Note that there are memory limits for commands, and if those limits are exceeded, the command gets terminated, and users will see an error message.


# Arguments

Raycast supports arguments for your commands so that users can enter values right from Root Search before opening the command.



Arguments are configured in the manifest per command.

{% hint style="info" %}

- **Maximum number of arguments:** 3 (if you have a use case that requires more, please let us know via feedback or in the [Slack community](https://www.raycast.com/community))
- The order of the arguments specified in the manifest is important and is reflected by the fields shown in Root Search. To provide a better UX, put the required arguments before the optional ones.

{% endhint %}

## Example

Let's say we want a command with three arguments. Its `package.json` will look like this:

```json
{
  "name": "arguments",
  "title": "API Arguments",
  "description": "Example of Arguments usage in the API",
  "icon": "command-icon.png",
  "author": "raycast",
  "license": "MIT",
  "commands": [
    {
      "name": "my-command",
      "title": "Arguments",
      "subtitle": "API Examples",
      "description": "Demonstrates usage of arguments",
      "mode": "view",
      "arguments": [
        {
          "name": "title",
          "placeholder": "Title",
          "type": "text",
          "required": true
        },
        {
          "name": "subtitle",
          "placeholder": "Secret Subtitle",
          "type": "password"
        },
        {
          "name": "favoriteColor",
          "type": "dropdown",
          "placeholder": "Favorite Color",
          "required": true,
          "data": [
            {
              "title": "Red",
              "value": "red"
            },
            {
              "title": "Green",
              "value": "green"
            },
            {
              "title": "Blue",
              "value": "blue"
            }
          ]
        }
      ]
    }
  ],
  "dependencies": {
    "@raycast/api": "1.38.0"
  },
  "scripts": {
    "dev": "ray develop",
    "build": "ray build -e dist",
    "lint": "ray lint"
  }
}
```

The command itself will receive the arguments' values via the `arguments` prop:

```typescript
import { Form, LaunchProps } from "@raycast/api";

export default function Todoist(props: LaunchProps<{ arguments: Arguments.MyCommand }>) {
  const { title, subtitle } = props.arguments;
  console.log(`title: ${title}, subtitle: ${subtitle}`);

  return (
    <Form>
      <Form.TextField id="title" title="Title" defaultValue={title} />
      <Form.TextField id="subtitle" title="Subtitle" defaultValue={subtitle} />
    </Form>
  );
}
```

## Types

### Arguments

A command receives the values of its arguments via a top-level prop named `arguments`. It is an object with the arguments' `name` as keys and their values as the property's values.

Depending on the `type` of the argument, the type of its value will be different.

| Argument type         | Value type          |
| :-------------------- | :------------------ |
| <code>text</code>     | <code>string</code> |
| <code>password</code> | <code>string</code> |
| <code>dropdown</code> | <code>string</code> |

{% hint style="info" %}
Raycast provides a global TypeScript namespace called `Arguments` which contains the types of the arguments of all the commands of the extension.

For example, if a command named `show-todos` accepts arguments, its `LaunchProps` can be described as `LaunchProps<{ arguments: Arguments.ShowTodos }>`. This will make sure that the types used in the command stay in sync with the manifest.
{% endhint %}


# Background Refresh

Commands of an extension can be configured to be automatically run in the background, without the user manually opening them.
Background refresh can be useful for:

- dynamically updating the subtitle of a command in Raycast root search
- refreshing menu bar commands
- other supporting functionality for your main commands

This guide helps you understand when and how to use background refresh and learn about the constraints.

## Scheduling Commands

Raycast supports scheduling commands with mode `no-view` and `menu-bar` at a configured interval.

### Manifest

Add a new property `interval` to a command in the manifest

Example:

```json
{
    "name": "unread-notifications",
    "title": "Show Unread Notifications",
    "description": "Shows the number of unread notifications in root search",
    "mode": "no-view",
    "interval": "10m"
},
```

The interval specifies that the command should be launched in the background every X seconds (s), minutes (m), hours (h) or days (d). Examples: `10m`, `12h`, `1d`. The minimum value is 10 seconds (`10s`), which should be used cautiously, also see the section on best practices.

Note that the actual scheduling is not exact and might vary within a tolerance level. macOS determines the best time for running the command in order to optimize energy consumption, and scheduling times can also vary when running on battery. To prevent overlapping background launches of the same command, commands are terminated after a timeout that is dynamically adjusted to the interval.

## Running in the background

The entry point of your command stays the same when launched from the background. For no-view commands, a command will run until the Promise of the main async function resolves. Menu bar commands render a React component and run until the `isLoading` property is set to `false`.

You can use the global `environment.launchType` in your command to determine whether the command has been launched by the user (`LaunchType.UserInitiated`) or via background refresh (`LaunchType.Background`).

```typescript
import { environment, updateCommandMetadata } from "@raycast/api";

async function fetchUnreadNotificationCount() {
  return 10;
}

export default async function Command() {
  console.log("launchType", environment.launchType);
  const count = await fetchUnreadNotificationCount();
  await updateCommandMetadata({ subtitle: `Unread Notifications: ${count}` });
}
```

Raycast auto-terminates the command if it exceeds its maximum execution time. If your command saves some state that is shared with other commands, make sure to use defensive programming, i.e. add handling for errors and data races if the stored state is incomplete or inaccessible.

## Development and Debugging

For local commands under development, errors are shown as usual via the console. Two developer actions in root search help you to run and debug scheduled commands:

- Run in Background: this immediately runs the command with `environment.launchType` set to `LaunchType.Background`.
- Show Error: if the command could not be loaded or an uncaught runtime exception was thrown, the full error can be shown in the Raycast error overlay for development. This action is also shown to users of the installed Store command and provides actions to copy and report the error on the production error overlay.



When the background run leads to an error, users will also see a warning icon on the root search command and a tooltip with a hint to show the error via the Action Panel. The tooltip over the subtitle of a command shows the last run time.

You can launch the built-in root search command "Extension Diagnostics" to see which of your commands run in background and when they last ran.

## Preferences

For scheduled commands, Raycast automatically adds command preferences that give users the options to enable and disable background refresh. Preferences also show the last run time of the command.



When a user installs the command via the Store, background refresh is initially _disabled_ and is activated either when the user opens the command for the first time or enables background refresh in preferences. (This is to avoid automatically running commands in the background without the user being aware of it.)

## Best Practices

- Make sure the command is useful both when manually launched by the user or when launched in the background
- Choose the interval value as high as possible - low values mean the command will run more often and consume more energy
- If your command performs network requests, check the rate limits of the service and handle errors appropriately (e.g. automatically retry later)
- Make sure the command finishes as quickly as possible; for menu bar commands, ensure `isLoading` is set to false as early as possible
- Use defensive programming if state is shared between commands of an extension and handle potential data races and inaccessible data


# Deeplinks

Deeplinks are Raycast-specific URLs you can use to launch any command, as long as it's installed and enabled in Raycast.

They adhere to the following format:

```
raycast://extensions/<author-or-owner>/<extension-name>/<command-name>
```

| Name            | Description                                                                                                                                                                                                                        | Type     |
| :-------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| author-or-owner | For store extensions, it's the value of the `owner` or the `author` field in the extension's manifest, this is always `raycast`.                                   | `string` |
| extension-name  | For store extensions, it's the value of the extension's `name` field in the extension's manifest, this is the "slugified" extension name; in this case `calendar`. | `string` |
| command-name    | For store extensions, it's the value of the command's `name` field in the extension's manifest, this is the "slugified" command name; in this case `my-schedule`. | `string` |

To make fetching a command's Deeplink easier, each command in the Raycast root now has a `Copy Deeplink` action.

{% hint style="info" %}
Whenever a command is launched using a Deeplink, Raycast will ask you to confirm that you want to run the command. This is to ensure that you are aware of the command you are running.
{% endhint %}



## Query Parameters

| Name         | Description                                                                                                                            | Type                                   |
| :----------- | -------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| launchType   | Runs the command in the background, skipping bringing Raycast to the front.                                                            | Either `userInitiated` or `background` |
| arguments    | If the command accepts arguments, they can be passed using this query parameter.                                     | URL-encoded JSON object.               |
| context      | If the command make use of LaunchContext, it can be passed using this query parameter. | URL-encoded JSON object.               |
| fallbackText | Some text to prefill the search bar or first text input of the command                                                                 | `string`                               |


# Manifest

The `package.json` manifest file is a superset of npm's `package.json` file. This way, you only need one file to configure your extension. This document covers only the Raycast specific fields. Refer to [npm's documentation](https://docs.npmjs.com/cli/v7/configuring-npm/package-json) for everything else.

Here is a typical manifest file:

```javascript
{
  "name": "my-extension",
  "title": "My Extension",
  "description": "My extension that can do a lot of things",
  "icon": "icon.png",
  "author": "thomas",
  "platforms": ["macOS", "Windows"],
  "categories": ["Fun", "Communication"],
  "license": "MIT",
  "commands": [
    {
      "name": "index",
      "title": "Send Love",
      "description": "A command to send love to each other",
      "mode": "view"
    }
  ]
}
```

## Extension properties

All Raycast related properties for an extension.

| Property                                      | Description                                                                                                                                                                                                                                         |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name<mark style="color:red;">\*</mark>        | A unique name for the extension. This is used in the Store link to your extension, so keep it short and URL compatible.                                                                                                                             |
| title<mark style="color:red;">\*</mark>       | The title of the extension that is shown to the user in the Store as well as the preferences. Use this title to describe your extension well that users can find it in the Store.                                                                   |
| description<mark style="color:red;">\*</mark> | The full description of the extension shown in the Store.                                                                                                                                                                                           |
| icon<mark style="color:red;">\*</mark>        | A reference to an icon file in the assets folder. Use png format with a size of 512 x 512 pixels. To support light and dark theme, add two icons, one with `@dark` as suffix, e.g. `icon.png` and `icon@dark.png`.                                  |
| author <mark style="color:red;">\*</mark>     | Your Raycast Store handle (username)                                                                                                                                                                                                                |
| platforms <mark style="color:red;">\*</mark>  | An Array of platforms supported by the extension(`"macOS"` or `"Windows"`). If the extension uses some platform-specific APIs, restrict which platform can install it.                                                                              |
| categories<mark style="color:red;">\*</mark>  | An array of categories that your extension belongs in.                                                                                                                                                                                              |
| commands<mark style="color:red;">\*</mark>    | An array of commands.                                                                                                                |
| tools                                         | An array of tools that the AI can use to interact with this extension, see Tool properties.                                                                                                                                     |
| ai                                            | Additional information related to the AI capabilities of the extension, see AI properties.                                                                                                                                        |
| owner                                         | Used for extensions published under an organisation. When defined, the extension will be private.                                                                                  |
| access                                        | Either `"public"` or `"private"`. Public extensions are downloadable by anybody, while private extensions can only be downloaded by a member of a given organization.                                                |
| contributors                                  | An array of Raycast store handles (usernames) of people who have meaningfully contributed and are maintaining to this extension.                                                                                                                    |
| pastContributors                              | An array of Raycast store handles (usernames) of people who have meaningfully contributed to the extension's commands but do not maintain it anymore.                                                                                               |
| keywords                                      | An array of keywords for which the extension can be searched for in the Store.                                                                                                                                                                      |
| preferences                                   | Extensions can contribute preferences that are shown in Raycast Preferences > Extensions. You can use preferences for configuration values and passwords or personal access tokens, see Preference properties. |
| external                                      | An Array of package or file names that should be excluded from the build. The package will not be bundled, but the import is preserved and will be evaluated at runtime.                                                                            |

## Command properties

All properties for a command.

| Property                                      | Description                                                                                                                                                                                                                                                                                                                                                                                                     |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name<mark style="color:red;">\*</mark>        | A unique id for the command. The name directly maps to the entry point file for the command. So a command named "index" would map to `src/index.ts` (or any other supported TypeScript or JavaScript file extension such as `.tsx`, `.js`, `.jsx`).                                                                                                                                                             |
| title<mark style="color:red;">\*</mark>       | The display name of the command, shown to the user in the Store, Preferences, and in Raycast's root search.                                                                                                                                                                                                                                                                                                     |
| subtitle                                      | The optional subtitle of the command in the root search. Usually, this is the service or domain that your command is associated with. You can dynamically update this property using `updateCommandMetadata`.                                                                                                                                              |
| description<mark style="color:red;">\*</mark> | It helps users understand what the command does. It will be displayed in the Store and in Preferences.                                                                                                                                                                                                                                                                                                          |
| icon                                          | <p>An optional reference to an icon file in the assets folder. Use png format with a size of at least 512 x 512 pixels. To support light and dark theme, add two icons, one with <code>@dark</code> as suffix, e.g. <code>icon.png</code> and <code>icon@dark.png</code>.</p><p>If no icon is specified, the extension icon will be used.</p>                                                                   |
| mode<mark style="color:red;">\*</mark>        | A value of `view` indicates that the command will show a main view when performed. `no-view` means that the command does not push a view to the main navigation stack in Raycast. The latter is handy for directly opening a URL or other API functionalities that don't require a user interface. `menu-bar` indicates that this command will return a Menu Bar Extra |
| interval                                      | The value specifies that a `no-view` or `menu-bar` command should be launched in the background every X seconds (s), minutes (m), hours (h) or days (d). Examples: 90s, 1m, 12h, 1d. The minimum value is 1 minute (1m).                                                                                                                                                                                        |
| keywords                                      | An optional array of keywords for which the command can be searched in Raycast.                                                                                                                                                                                                                                                                                                                                 |
| arguments                                     | An optional array of arguments that are requested from user when the command is called, see Argument properties.                                                                                                                                                                                                                                                             |
| preferences                                   | Commands can optionally contribute preferences that are shown in Raycast Preferences > Extensions when selecting the command. You can use preferences for configuration values and passwords or personal access tokens, see Preference properties. Commands automatically "inherit" extension preferences and can also override entries with the same `name`.              |
| disabledByDefault                             | <p>Specify whether the command should be enabled by default or not. By default, all commands are enabled but there are some cases where you might want to include additional commands and let the user enable them if they need it.</p><p><em>Note that this flag is only used when installing a new extension or when there is a new command.</em></p>                                                         |

## Preference properties

All properties for extension or command-specific preferences. Use the Preferences API to access their values.

| Property                                      | Description                                                                                                                                                                                                                                                                                                                                                                                |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| name<mark style="color:red;">\*</mark>        | A unique id for the preference.                                                                                                                                                                                                                                                                                                                                                            |
| title<mark style="color:red;">\*</mark>       | <p>The display name of the preference shown in Raycast preferences.</p><p> For `"checkbox"`, `"textfield"` and `"password"`, it is shown as a section title above the respective input element.</p><p>If you want to group multiple checkboxes into a single section, set the <code>title</code> of the first checkbox and leave the <code>title</code> of the other checkboxes empty.</p> |
| description<mark style="color:red;">\*</mark> | It helps users understand what the preference does. It will be displayed as a tooltip when hovering over it.                                                                                                                                                                                                                                                                               |
| type<mark style="color:red;">\*</mark>        | The preference type. We currently support `"textfield"` and `"password"` (for secure entry), `"checkbox"`, `"dropdown"`, `"appPicker"`, `"file"`, and `"directory"`.                                                                                                                                                                                                                       |
| required<mark style="color:red;">\*</mark>    | Indicates whether the value is required and must be entered by the user before the extension is usable.                                                                                                                                                                                                                                                                                    |
| placeholder                                   | Text displayed in the preference's field when no value has been input.                                                                                                                                                                                                                                                                                                                     |
| default                                       | <p>The optional default value for the field. For textfields, this is a string value; for checkboxes a boolean; for dropdowns the value of an object in the data array; for appPickers an application name, bundle ID or path.</p><p>Additionally, you can specify a different value per plaform by passing an object: <code>{ "macOS": ..., "Windows": ... }</code>`.</p>                  |

Depending on the `type` of the Preference, some additional properties can be required:

### Additional properties for `checkbox` Preference

| Property                                | Description                                            |
| --------------------------------------- | ------------------------------------------------------ |
| label<mark style="color:red;">\*</mark> | The label of the checkbox. Shown next to the checkbox. |

### Additional properties for `dropdown` Preference

| Property                               | Description                                                                                          |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| data<mark style="color:red;">\*</mark> | An array of objects with `title` and `value` properties, e.g.: `[{"title": "Item 1", "value": "1"}]` |

## Argument properties

All properties for command arguments. Use the Arguments API to access their values.

| Property                                      | Description                                                                                                                                                                                                                                      |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| name<mark style="color:red;">\*</mark>        | A unique id for the argument. This value will be used to as the key in the object passed as top-level prop.                                                                                                |
| type<mark style="color:red;">\*</mark>        | The argument type. We currently support `"text"`, `"password"` (for secure entry), and `"dropdown"`. When the type is `password`, entered text will be replaced with asterisks. Most common use case – passing passwords or secrets to commands. |
| placeholder<mark style="color:red;">\*</mark> | Placeholder for the argument's input field.                                                                                                                                                                                                      |
| required                                      | Indicates whether the value is required and must be entered by the user before the command is opened. Default value for this is `false`.                                                                                                         |

Depending on the `type` of the Argument, some additional properties can be required:

### Additional properties for `dropdown` Argument

| Property                               | Description                                                                                          |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| data<mark style="color:red;">\*</mark> | An array of objects with `title` and `value` properties, e.g.: `[{"title": "Item 1", "value": "1"}]` |

#### Tool Properties

All properties for a tool.

| Property                                      | Description                                                                                                                                                                                                                                                                                                                                   |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name<mark style="color:red;">\*</mark>        | A unique id for the tool. The name directly maps to the entry point file for the tool. So a tool named "index" would map to `src/tools/index.ts` (or any other supported TypeScript file extension such as `.tsx`).                                                                                                                           |
| title<mark style="color:red;">\*</mark>       | The display name of the tool, shown to the user in the Store and Preferences.                                                                                                                                                                                                                                                                 |
| description<mark style="color:red;">\*</mark> | It helps users and the AI understand what the tool does. It will be displayed in the Store and in Preferences.                                                                                                                                                                                                                                |
| icon                                          | <p>An optional reference to an icon file in the assets folder. Use png format with a size of at least 512 x 512 pixels. To support light and dark theme, add two icons, one with <code>@dark</code> as suffix, e.g. <code>icon.png</code> and <code>icon@dark.png</code>.</p><p>If no icon is specified, the extension icon will be used.</p> |

#### AI Properties

All properties for the AI capabilities of the extension. Alternatively, this object can be written in a `ai.json` (or `ai.yaml`) file at the root of the extension.

| Property     | Description                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| instructions | A string containing additional instructions for the AI. It will be added as a system message whenever the extension is mentioned. It can for example be used to help the AI respond with a format that makes more sense for the extension: `Always format pull requests and issues as markdown links: [pull-request-title](https://github.com/:org/:repo/pull/:number) and [issue-title](https://github.com/:org/:repo/issues/:number)` |
| evals        | Evals for AI Extension. [More details](https://raycastapp.notion.site/AI-Extensions-Evals-15fd6e4a8215800598cad77d8afb5dc8?pvs=73)                                                                                                                                                                                                                                                                                                      |


# Security

{% hint style="info" %}
Note that this is _not_ a guide on how to create secure Raycast extensions but rather an overview of security-related aspects on how extensions are built, distributed and run.
{% endhint %}

## Raycast

Raycast itself runs outside of the App Store as "Developer ID Application", **signed** with the Raycast certificate and verified by Apple's **notarization service** before the app is distributed. Raycast provides various commands that interact with OS-level functionality, some of which prompt the user for granting **permissions** when required. The app is **automatically kept up-to-date** to minimize the risk of running heavily outdated versions and to ship hotfixes quickly. Raycast is a local-first application that stores user data in a local **encrypted database**, makes use of the system **Keychain** where secure data is stored, and generally connects to third-party APIs directly rather than proxying data through Raycast servers.

## Publishing Process

All extensions are **open source** so the current source code can be inspected at all times. Before an extension gets merged into the **public repository**, members from Raycast and the community collaboratively **review** extensions, and follow our **store guidelines**. After the code review, the Continuous Integration system performs a set of **validations** to make sure that manifest conforms to the defined schema, required assets have the correct format, the author is valid, and no build and type errors are present. (More CI pipeline tooling for automated static security analysis is planned.) The built extension is then **archived and uploaded** to the Raycast Store, and eventually published for a registered user account. When an extension is installed or updated, the extension is downloaded from the store, unarchived to disk, and a record is updated in the local Raycast database. End-users install extensions through the built-in store or the web store.

## Runtime Model

In order to run extensions, Raycast launches a **single child Node.js process** where extensions get loaded and unloaded as needed; inter-process communication with Raycast happens through standard file handles and a thin RPC protocol that only exposes a **defined set of APIs**, that is, an extension cannot just perform any Raycast operation. The **Node runtime is managed** by Raycast and automatically downloaded to the user's machine. We use an official version and **verify the Node binary** to ensure it has not been tampered with.

An extension runs in its own **v8 isolate** (worker thread) and gets its own event loop, JavaScript engine and Node instance, and limited heap memory. That way, we ensure **isolation between extensions** when future Raycast versions may support background executions of multiple extensions running concurrently.

## Permissions

Extensions are **not further sandboxed** as far as policies for file I/O, networking, or other features of the Node runtime are concerned; this might change in the future as we want to carefully balance user/developer experience and security needs. By default and similar to other macOS apps, accessing special directories such as the user Documents directory or performing screen recording first requires users to give **permissions** to Raycast (parent process) via the **macOS Security & Preferences** pane, otherwise programmatic access is not permitted.

## Data Storage

While extensions can access the file system and use their own methods of storing and accessing data, Raycast provides **APIs for securely storing data**: _password_ preferences can be used to ask users for values such as access tokens, and the local storage APIs provide methods for reading and writing data payloads. In both cases, the data is stored in the local encrypted database and can only be accessed by the corresponding extension.

## Automatic Updates

Both Raycast itself and extensions are **automatically updated** and we think of this as a security feature since countless exploits have happened due to outdated and vulnerable software. Our goal is that neither developers nor end-users need to worry about versions, and we **minimize the time from update to distribution** to end-users.


# Terminology

## Action

Actions are accessible via the Action Panel. They are little functionality to control something; for example, to add a label to the selected GitHub issue, copy the link to a Linear issue, or anything else. Actions can have assigned keyboard shortcuts.

## Action Panel

Action Panel is located on the bottom right and can be opened with `⌘` `K`. It contains all currently available actions and makes them easily discoverable.

## AI Extensions

AI Extensions are simply regular extensions. Once an extension has some tools, a user can `@mention` the extension in Quick AI, or the AI Commands, or the AI Chat. When doing so, the AI will have the opportunity to call one or multiple tools of the extensions mentioned.

## Command

Commands are a type of entry point for an extension. Commands are available in the root search of Raycast. They can be a simple script or lists, forms, and more complex UI.

## Extension

Extensions add functionality to Raycast. They consist of one or many commands and can be installed from the Store.

## Manifest

Manifest is the `package.json` file of an extension. It's an npm package mixed with Raycast specific metadata. The latter is necessary to identify the package for Raycast and publish it to the Store.

## Tool

Tools are a type of entry point for an extension. As opposed to a command, they don’t show up in the root search and the user can’t directly interact with them. Instead, they are functionalities that the AI can use to interact with an extension.


# Versioning

Versioning your extensions is straightforward since we've designed the system in a way that **frees you from having to deal with versioning schemes and compatibility**. The model is similar to that of app stores where there's only one implicit _latest_ version that will be updated when the extension is published in the store. Extensions are automatically updated for end users.

## Development

For **development**, this means that you do _not_ declare a version property in the manifest. If you wish to use API features that were added in a later version, you just update your `@raycast/api` npm dependency, start using the feature, and submit an extension update to the store.

## End Users

For **end-users** installing or updating your extension, Raycast automatically checks the compatibility between the API version that the extension actually uses and the user's current Raycast app version (which contains the API runtime and also manages the Node version). If there's a compatibility mismatch such as the user not having the required latest Raycast app version, we show a hint and prompt the user to update Raycast so that the next compatibility check succeeds.

## Version History

Optionally, you can provide a `changelog.md` file in your extension, and give detailed changes with every update. These changes can be viewed by the user on the extension details screen, under Version History, as well as on the [raycast.com/store](https://raycast.com/store).

You can learn more about Version History here, how to add it to your extension, and the required format for the best appearance.

## API Evolution

Generally, we follow an **API evolution** process, meaning that we stay backward-compatible and do not introduce breaking changes within the same major API version. We'll 1) add new functionality and 2) we'll mark certain API methods and components as _deprecated_ over time, which signals to you that you should stop using those features and migrate to the new recommended alternatives. At some point in the future, we may introduce a new breaking major release; however, at this time, you will be notified, and there will be a transition period for migrating extensions.


# Collaborate on Private Extensions

Isn't it more fun to work with your colleagues together on your extension? For this, we recommend to share all your extensions in a single repository, similar to how we organize the [public store](https://raycast.com/store). If you follow the Getting Started guide, we will set up a local repository for you that is optimized for collaboration.

As next steps, create a [new repository](https://github.com/new) and push the existing local repository. Afterwards, your teammates can check out the code and help you improve your extensions and add new ones.


# Getting Started with Raycast for Teams

Raycast for Teams allows you to build, share and discover extensions in a private store. The store is only accessible to members of your organization.

## Create Your Organization

To get started, create your organization. Specify the name of the organization, a handle (used in links, e.g. `https://raycast.com/your_org/some_extension`) and optionally upload an avatar.



{% hint style="info" %}
You can use the Manage Organization command to edit your organization's information later.
{% endhint %}

## Create Your Private Extension Store

After you've created your organization, it's time to set up a private store for your extensions.

### Init a Local Repository

First, select a folder to create a local repository for your private extension store. We create a folder that contains a Getting Started extension. We recommend to store all extensions of your team in a single repository. This makes it easy to collaborate.



### Build The Getting Started Extension

After you have created the local repository, navigate into the `getting-started` folder. The folder contains a simple extension with a command that shows a list with a few useful links. Run `npm run dev` in the folder to build the extension and start development mode. Raycast opens and you can see a new Development section in the root search. The section shows all commands that are under active development. You can open the command and open a few links.



{% hint style="info" %}
See Create Your First Extension for a more detailed guide on how to create an extension.
{% endhint %}

### Publish The Getting Started Extension

Now, we share the extension with your organization. Perform `npm run publish` in the extension folder. The command verifies, builds and publishes the extension to your private extension store. The extension is only accessible to members of your organization.



🎉 Congratulations! You built and published your first private extension. Now it's time to spread the word in your organization.

## Invite Your Teammates

Use the Copy Organization Invite Link command in Raycast to share access to your organization. Send the link to your teammates. You'll receive an email when somebody joins your organization. You can use the Manage Organization command to see who's part of your organization, reset the invite link and edit your organization details.

As a next step, follow this guide to push your local repository to a source control system. This allows you to collaborate with your teammates on your extensions.


# Publish a Private Extension

To publish an extension, run `npm run publish` in the extension directory. The command verifies, builds and publishes the extension to the owner's store. The extension is only available to members of this organization. A link to your extension is copied to your clipboard to share it with your teammates. Happy publishing 🥳

To mark an extension as private, you need to set the `owner` field in your `package.json` to your organization handle. If you don't know your handle, open the Manage Organization command, select your organization in the dropdown on the top right and perform the Copy Organization Handle action (`⌘` `⇧` `.`).

{% hint style="info" %}
Use the Create Extension command to create a private extension for your organization.
{% endhint %}

To be able to publish a private extension to an organization, you need to be logged in. Raycast takes care of logging you in with the CLI as well. In case you aren't logged in or need to switch an account, you can run `npx ray login` and `npx ray logout`.


# Functions


# `createDeeplink`

Function that creates a deeplink for an extension or script command.

## Signature

There are three ways to use the function.

The first one is for creating a deeplink to a command inside the current extension:

```ts
function createDeeplink(options: {
  type?: DeeplinkType.Extension,
  command: string,
  launchType?: LaunchType,
  arguments?: LaunchProps["arguments"],
  fallbackText?: string,
}): string;
```

The second one is for creating a deeplink to an extension that is not the current extension:

```ts
function createDeeplink(options: {
  type?: DeeplinkType.Extension,
  ownerOrAuthorName: string,
  extensionName: string,
  command: string,
  launchType?: LaunchType,
  arguments?: LaunchProps["arguments"],
  fallbackText?: string,
}): string;
```

The third one is for creating a deeplink to a script command:

```ts
function createDeeplink(options: {
  type: DeeplinkType.ScriptCommand,
  command: string,
  arguments?: string[],
}): string;
```

### Arguments

#### Extension

- `type` is the type of the deeplink. It must be `DeeplinkType.Extension`.
- `command` is the name of the command to deeplink to.
- `launchType` is the type of the launch.
- `arguments` is an object that contains the arguments to pass to the command.
- `fallbackText` is the text to show if the command is not available.
- For intra-extension deeplinks:
  - `ownerOrAuthorName` is the name of the owner or author of the extension.
  - `extensionName` is the name of the extension.

#### Script command

- `type` is the type of the deeplink. It must be `DeeplinkType.ScriptCommand`.
- `command` is the name of the script command to deeplink to.
- `arguments` is an array of strings to be passed as arguments to the script command.

### Return

Returns a string.

## Example

```tsx
import { Action, ActionPanel, LaunchProps, List } from "@raycast/api";
import { createDeeplink, DeeplinkType } from "@raycast/utils";

export default function Command(props: LaunchProps<{ launchContext: { message: string } }>) {
  console.log(props.launchContext?.message);

  return (
    <List>
      <List.Item
        title="Extension Deeplink"
        actions={
          <ActionPanel>
            <Action.CreateQuicklink
              title="Create Deeplink"
              quicklink={{
                name: "Extension Deeplink",
                link: createDeeplink({
                  command: "create-deeplink",
                  context: {
                    message: "Hello, world!",
                  },
                }),
              }}
            />
          </ActionPanel>
        }
      />
      <List.Item
        title="External Extension Deeplink"
        actions={
          <ActionPanel>
            <Action.CreateQuicklink
              title="Create Deeplink"
              quicklink={{
                name: "Create Triage Issue for Myself",
                link: createDeeplink({
                  ownerOrAuthorName: "linear",
                  extensionName: "linear",
                  command: "create-issue-for-myself",
                  arguments: {
                    title: "Triage new issues",
                  },
                }),
              }}
            />
          </ActionPanel>
        }
      />
      <List.Item
        title="Script Command Deeplink"
        actions={
          <ActionPanel>
            <Action.CreateQuicklink
              title="Create Deeplink"
              quicklink={{
                name: "Deeplink with Arguments",
                link: createDeeplink({
                  type: DeeplinkType.ScriptCommand,
                  command: "count-chars",
                  arguments: ["a b+c%20d"],
                }),
              }}
            />
          </ActionPanel>
        }
      />
    </List>
  );
}
```

## Types

### DeeplinkType

A type to denote whether the deeplink is for a script command or an extension.

```ts
export enum DeeplinkType {
  /** A script command */
  ScriptCommand = "script-command",
  /** An extension command */
  Extension = "extension",
}
```


# `executeSQL`

A function that executes a SQL query on a local SQLite database and returns the query result in JSON format.

## Signature

```ts
function executeSQL<T = unknown>(databasePath: string, query: string): Promise<T[]>
```

### Arguments

- `databasePath` is the path to the local SQL database.
- `query` is the SQL query to run on the database.

### Return

Returns a `Promise` that resolves to an array of objects representing the query results.

## Example

```typescript
import { closeMainWindow, Clipboard } from "@raycast/api";
import { executeSQL } from "@raycast/utils";

type Message = { body: string; code: string };

const DB_PATH = "/path/to/chat.db";

export default async function Command() {
  const query = `
    SELECT body, code
    FROM message
    ORDER BY date DESC
    LIMIT 1;
  `;

  const messages = await executeSQL<Message>(DB_PATH, query);

  if (messages.length > 0) {
    const latestCode = messages[0].code;
    await Clipboard.paste(latestCode);
    await closeMainWindow();
  }
}
```

# `runAppleScript`

Function that executes an AppleScript script.

{% hint style="info" %}
Only available on macOS
{% endhint %}

## Signature

There are two ways to use the function.

The first one should be preferred when executing a static script.

```ts
function runAppleScript<T>(
  script: string,
  options?: {
    humanReadableOutput?: boolean;
    language?: "AppleScript" | "JavaScript";
    signal?: AbortSignal;
    timeout?: number;
    parseOutput?: ParseExecOutputHandler<T>;
  },
): Promise<T>;
```

The second one can be used to pass arguments to a script.

```ts
function runAppleScript<T>(
  script: string,
  arguments: string[],
  options?: {
    humanReadableOutput?: boolean;
    language?: "AppleScript" | "JavaScript";
    signal?: AbortSignal;
    timeout?: number;
    parseOutput?: ParseExecOutputHandler<T>;
  },
): Promise<T>;
```

### Arguments

- `script` is the script to execute.
- `arguments` is an array of strings to pass as arguments to the script.

With a few options:

- `options.humanReadableOutput` is a boolean to tell the script what form to output. By default, `runAppleScript` returns its results in human-readable form: strings do not have quotes around them, characters are not escaped, braces for lists and records are omitted, etc. This is generally more useful, but can introduce ambiguities. For example, the lists `{"foo", "bar"}` and `{{"foo", {"bar"}}}` would both be displayed as ‘foo, bar’. To see the results in an unambiguous form that could be recompiled into the same value, set `humanReadableOutput` to `false`.
- `options.language` is a string to specify whether the script is using [`AppleScript`](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html#//apple_ref/doc/uid/TP40000983) or [`JavaScript`](https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/Introduction.html#//apple_ref/doc/uid/TP40014508-CH111-SW1). By default, it will assume that it's using `AppleScript`.
- `options.signal` is a Signal object that allows you to abort the request if required via an AbortController object.
- `options.timeout` is a number. If greater than `0`, the parent will send the signal `SIGTERM` if the script runs longer than timeout milliseconds. By default, the execution will timeout after 10000ms (eg. 10s).
- `options.parseOutput` is a function that accepts the output of the script as an argument and returns the data the hooks will return - see ParseExecOutputHandler. By default, the function will return `stdout` as a string.

### Return

Returns a Promise which resolves to a string by default. You can control what it returns by passing `options.parseOutput`.

## Example

```tsx
import { showHUD } from "@raycast/api";
import { runAppleScript } from "@raycast/utils";

export default async function () {
  const res = await runAppleScript(
    `
on run argv
  return "hello, " & item 1 of argv & "."
end run
`,
    ["world"],
  );
  await showHUD(res);
}
```

## Types

### ParseExecOutputHandler

A function that accepts the output of the script as an argument and returns the data the function will return.

```ts
export type ParseExecOutputHandler<T> = (args: {
  /** The output of the script on stdout. */
  stdout: string;
  /** The output of the script on stderr. */
  stderr: string;
  error?: Error | undefined;
  /** The numeric exit code of the process that was run. */
  exitCode: number | null;
  /** The name of the signal that was used to terminate the process. For example, SIGFPE. */
  signal: NodeJS.Signals | null;
  /** Whether the process timed out. */
  timedOut: boolean;
  /** The command that was run, for logging purposes. */
  command: string;
  /** The options passed to the script, for logging purposes. */
  options?: ExecOptions | undefined;
}) => T;
```


# `runPowerShellScript`

Function that executes an PowerShell script.

{% hint style="info" %}
Only available on Windows
{% endhint %}

## Signature

```ts
function runPowerShellScript<T>(
  script: string,
  options?: {
    signal?: AbortSignal;
    timeout?: number;
    parseOutput?: ParseExecOutputHandler<T>;
  },
): Promise<T>;
```

### Arguments

- `script` is the script to execute.

With a few options:

- `options.signal` is a Signal object that allows you to abort the request if required via an AbortController object.
- `options.timeout` is a number. If greater than `0`, the parent will send the signal `SIGTERM` if the script runs longer than timeout milliseconds. By default, the execution will timeout after 10000ms (eg. 10s).
- `options.parseOutput` is a function that accepts the output of the script as an argument and returns the data the hooks will return - see ParseExecOutputHandler. By default, the function will return `stdout` as a string.

### Return

Returns a Promise which resolves to a string by default. You can control what it returns by passing `options.parseOutput`.

## Example

```tsx
import { showHUD } from "@raycast/api";
import { runPowerShellScript } from "@raycast/utils";

export default async function () {
  const res = await runPowerShellScript(
    `
Write-Host "hello, world."
`,
  );
  await showHUD(res);
}
```

## Types

### ParseExecOutputHandler

A function that accepts the output of the script as an argument and returns the data the function will return.

```ts
export type ParseExecOutputHandler<T> = (args: {
  /** The output of the script on stdout. */
  stdout: string;
  /** The output of the script on stderr. */
  stderr: string;
  error?: Error | undefined;
  /** The numeric exit code of the process that was run. */
  exitCode: number | null;
  /** The name of the signal that was used to terminate the process. For example, SIGFPE. */
  signal: NodeJS.Signals | null;
  /** Whether the process timed out. */
  timedOut: boolean;
  /** The command that was run, for logging purposes. */
  command: string;
  /** The options passed to the script, for logging purposes. */
  options?: ExecOptions | undefined;
}) => T;
```


# `showFailureToast`

Function that shows a failure Toast for a given Error.

## Signature

```ts
function showFailureToast(
  error: unknown,
  options?: {
    title?: string;
    primaryAction?: Toast.ActionOptions;
  },
): Promise<T>;
```

### Arguments

- `error` is the error to report.

With a few options:

- `options.title` is a string describing the action that failed. By default, `"Something went wrong"`
- `options.primaryAction` is a Toast Action.

### Return

Returns a Toast.

## Example

```tsx
import { showHUD } from "@raycast/api";
import { runAppleScript, showFailureToast } from "@raycast/utils";

export default async function () {
  try {
    const res = await runAppleScript(
      `
      on run argv
        return "hello, " & item 1 of argv & "."
      end run
      `,
      ["world"],
    );
    await showHUD(res);
  } catch (error) {
    showFailureToast(error, { title: "Could not run AppleScript" });
  }
}
```


# `withCache`

Higher-order function which wraps a function with caching functionality using Raycast's Cache API.
Allows for caching of expensive functions like paginated API calls that rarely change.

## Signature

```tsx
function withCache<Fn extends (...args: any) => Promise<any>>(
  fn: Fn,
  options?: {
    validate?: (data: Awaited<ReturnType<Fn>>) => boolean;
    maxAge?: number;
  },
): Fn & { clearCache: () => void };
```

### Arguments

`options` is an object containing:

- `options.validate`: an optional function that receives the cached data and returns a boolean depending on whether the data is still valid or not.
- `options.maxAge`: Maximum age of cached data in milliseconds after which the data will be considered invalid

### Return

Returns the wrapped function

## Example

```tsx
import { withCache } from "@raycast/utils";

function fetchExpensiveData(query) {
  // ...
}

const cachedFunction = withCache(fetchExpensiveData, {
  maxAge: 5 * 60 * 1000, // Cache for 5 minutes
});

const result = await cachedFunction(query);
```


# Icons


# `getAvatarIcon`

Icon to represent an avatar when you don't have one. The generated avatar will be generated from the initials of the name and have a colorful but consistent background.



## Signature

```ts
function getAvatarIcon(
  name: string,
  options?: {
    background?: string;
    gradient?: boolean;
  },
): Image.Asset;
```

- `name` is a string of the subject's name.
- `options.background` is a hexadecimal representation of a color to be used as the background color. By default, the hook will pick a random but consistent (eg. the same name will the same color) color from a set handpicked to nicely match Raycast.
- `options.gradient` is a boolean to choose whether the background should have a slight gradient or not. By default, it will.

Returns an Image.Asset that can be used where Raycast expects them.

## Example

```tsx
import { List } from "@raycast/api";
import { getAvatarIcon } from "@raycast/utils";

export default function Command() {
  return (
    <List>
      <List.Item icon={getAvatarIcon("John Doe")} title="John Doe" />
    </List>
  );
}
```


# `getFavicon`

Icon showing the favicon of a website.

A favicon (favorite icon) is a tiny icon included along with a website, which is displayed in places like the browser's address bar, page tabs, and bookmarks menu.



## Signature

```ts
function getFavicon(
  url: string | URL,
  options?: {
    fallback?: Image.Fallback;
    size?: boolean;
    mask?: Image.Mask;
  },
): Image.ImageLike;
```

- `name` is a string of the subject's name.
- `options.fallback` is a Image.Fallback icon in case the Favicon is not found. By default, the fallback will be `Icon.Link`.
- `options.size` is the size of the returned favicon. By default, it is 64 pixels.
- `options.mask` is the size of the Image.Mask to apply to the favicon.

Returns an Image.ImageLike that can be used where Raycast expects them.

## Example

```tsx
import { List } from "@raycast/api";
import { getFavicon } from "@raycast/utils";

export default function Command() {
  return (
    <List>
      <List.Item icon={getFavicon("https://raycast.com")} title="Raycast Website" />
    </List>
  );
}
```


# `getProgressIcon`

Icon to represent the progress of a task, a project, _something_.



## Signature

```ts
function getProgressIcon(
  progress: number,
  color?: Color | string,
  options?: {
    background?: Color | string;
    backgroundOpacity?: number;
  },
): Image.Asset;
```

- `progress` is a number between 0 and 1 (0 meaning not started, 1 meaning finished).
- `color` is a Raycast `Color` or a hexadecimal representation of a color. By default it will be `Color.Red`.
- `options.background` is a Raycast `Color` or a hexadecimal representation of a color for the background of the progress icon. By default, it will be `white` if the Raycast's appearance is `dark`, and `black` if the appearance is `light`.
- `options.backgroundOpacity` is the opacity of the background of the progress icon. By default, it will be `0.1`.

Returns an Image.Asset that can be used where Raycast expects them.

## Example

```tsx
import { List } from "@raycast/api";
import { getProgressIcon } from "@raycast/utils";

export default function Command() {
  return (
    <List>
      <List.Item icon={getProgressIcon(0.1)} title="Project" />
    </List>
  );
}
```


# `OAuthService`

The `OAuthService` class is designed to abstract the OAuth authorization process using the PKCE (Proof Key for Code Exchange) flow, simplifying the integration with various OAuth providers such as Asana, GitHub, and others.

Use OAuthServiceOptions to configure the `OAuthService` class.

## Example

```ts
const client = new OAuth.PKCEClient({
  redirectMethod: OAuth.RedirectMethod.Web,
  providerName: "GitHub",
  providerIcon: "extension_icon.png",
  providerId: "github",
  description: "Connect your GitHub account",
});

const github = new OAuthService({
  client,
  clientId: "7235fe8d42157f1f38c0",
  scope: "notifications repo read:org read:user read:project",
  authorizeUrl: "https://github.oauth.raycast.com/authorize",
  tokenUrl: "https://github.oauth.raycast.com/token",
});
```

## Signature

```ts
constructor(options: OAuthServiceOptions): OAuthService
```

### Methods

#### `authorize`

Initiates the OAuth authorization process or refreshes existing tokens if necessary. Returns a promise that resolves with the access token from the authorization flow.

##### Signature

```ts
OAuthService.authorize(): Promise<string>;
```

##### Example

```typescript
const accessToken = await oauthService.authorize();
```

### Built-in Services

Some services are exposed as static properties in `OAuthService` to make it easy to authenticate with them:

- Asana
- GitHub
- Google
- Jira
- Linear
- Slack
- Zoom

Asana, GitHub, Linear, and Slack already have an OAuth app configured by Raycast so that you can use them right of the box by specifing only the permission scopes. You are still free to create an OAuth app for them if you want.

Google, Jira and Zoom don't have an OAuth app configured by Raycast so you'll have to create one if you want to use them.

Use ProviderOptions to configure these built-in services.

#### Asana

##### Signature

```ts
OAuthService.asana: (options: ProviderWithDefaultClientOptions) => OAuthService
```

##### Example

```tsx
const asana = OAuthService.asana({ scope: "default" });
```

#### GitHub

##### Signature

```ts
OAuthService.github: (options: ProviderWithDefaultClientOptions) => OAuthService
```

##### Example

```tsx
const github = OAuthService.github({ scope: "repo user" });
```

#### Google

Google has verification processes based on the required scopes for your extension. Therefore, you need to configure your own client for it.

{% hint style="info" %}
Creating your own Google client ID is more tedious than other processes, so we’ve created a page to assist you: Getting a Google client ID
{% endhint %}


##### Signature

```ts
OAuthService.google: (options: ProviderOptions) => OAuthService
```

##### Example

```tsx
const google = OAuthService.google({
  clientId: "custom-client-id",
  scope: "https://www.googleapis.com/auth/drive.readonly",
});
```

#### Jira

Jira requires scopes to be enabled manually in the OAuth app settings. Therefore, you need to configure your own client for it.

##### Signature

```ts
OAuthService.jira: (options: ProviderOptions) => OAuthService
```

##### Example

```tsx
const jira = OAuthService.jira({
  clientId: "custom-client-id",
  scope: "read:jira-user read:jira-work offline_access",
});
```

#### Linear

##### Signature

```ts
OAuthService.linear: (options: ProviderOptions) => OAuthService
```

##### Example

```tsx
const linear = OAuthService.linear({ scope: "read write" });
```

#### Slack

##### Signature

```ts
OAuthService.slack: (options: ProviderWithDefaultClientOptions) => OAuthService
```

##### Example

```tsx
const slack = OAuthService.slack({ scope: "emoji:read" });
```

#### Zoom

Zoom requires scopes to be enabled manually in the OAuth app settings. Therefore, you need to configure your own client for it.

##### Signature

```ts
OAuthService.zoom: (options: ProviderOptions) => OAuthService
```

##### Example

```tsx
const zoom = OAuthService.zoom({
  clientId: "custom-client-id",
  scope: "meeting:write",
});
```

## Types

### OAuthServiceOptions

| Property Name                                  | Description                                                                                                                        | Type                                         |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| client<mark style="color:red;">\*</mark>       | The PKCE Client defined using `OAuth.PKCEClient` from `@raycast/api`                                                               | `OAuth.PKCEClient`                           |
| clientId<mark style="color:red;">\*</mark>     | The app's client ID                                                                                                                | `string`                                     |
| scope<mark style="color:red;">\*</mark>        | The scope of the access requested from the provider                                                                                | `string` \| `Array<string>`                  |
| authorizeUrl<mark style="color:red;">\*</mark> | The URL to start the OAuth flow                                                                                                    | `string`                                     |
| tokenUrl<mark style="color:red;">\*</mark>     | The URL to exchange the authorization code for an access token                                                                     | `string`                                     |
| refreshTokenUrl                                | The URL to refresh the access token if applicable                                                                                  | `string`                                     |
| personalAccessToken                            | A personal token if the provider supports it                                                                                       | `string`                                     |
| onAuthorize                                    | A callback function that is called once the user has been properly logged in through OAuth when used with `withAccessToken`        | `string`                                     |
| extraParameters                                | The extra parameters you may need for the authorization request                                                                    | `Record<string, string>`                     |
| bodyEncoding                                   | Specifies the format for sending the body of the request.                                                                          | `json` \| `url-encoded`                      |
| tokenResponseParser                            | Some providers returns some non-standard token responses. Specifies how to parse the JSON response to get the access token         | `(response: unknown) => OAuth.TokenResponse` |
| tokenRefreshResponseParser                     | Some providers returns some non-standard refresh token responses. Specifies how to parse the JSON response to get the access token | `(response: unknown) => OAuth.TokenResponse` |

### ProviderOptions

| Property Name                                  | Description                                                                                                                        | Type                                         |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| clientId<mark style="color:red;">\*</mark>     | The app's client ID                                                                                                                | `string`                                     |
| scope<mark style="color:red;">\*</mark>        | The scope of the access requested from the provider                                                                                | `string` \| `Array<string>`                  |
| authorizeUrl<mark style="color:red;">\*</mark> | The URL to start the OAuth flow                                                                                                    | `string`                                     |
| tokenUrl<mark style="color:red;">\*</mark>     | The URL to exchange the authorization code for an access token                                                                     | `string`                                     |
| refreshTokenUrl                                | The URL to refresh the access token if applicable                                                                                  | `string`                                     |
| personalAccessToken                            | A personal token if the provider supports it                                                                                       | `string`                                     |
| onAuthorize                                    | A callback function that is called once the user has been properly logged in through OAuth when used with `withAccessToken`        | `string`                                     |
| bodyEncoding                                   | Specifies the format for sending the body of the request.                                                                          | `json` \| `url-encoded`                      |
| tokenResponseParser                            | Some providers returns some non-standard token responses. Specifies how to parse the JSON response to get the access token         | `(response: unknown) => OAuth.TokenResponse` |
| tokenRefreshResponseParser                     | Some providers returns some non-standard refresh token responses. Specifies how to parse the JSON response to get the access token | `(response: unknown) => OAuth.TokenResponse` |

### ProviderWithDefaultClientOptions

| Property Name                           | Description                                                                                                                        | Type                                         |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| scope<mark style="color:red;">\*</mark> | The scope of the access requested from the provider                                                                                | `string` \| `Array<string>`                  |
| clientId                                | The app's client ID                                                                                                                | `string`                                     |
| authorizeUrl                            | The URL to start the OAuth flow                                                                                                    | `string`                                     |
| tokenUrl                                | The URL to exchange the authorization code for an access token                                                                     | `string`                                     |
| refreshTokenUrl                         | The URL to refresh the access token if applicable                                                                                  | `string`                                     |
| personalAccessToken                     | A personal token if the provider supports it                                                                                       | `string`                                     |
| onAuthorize                             | A callback function that is called once the user has been properly logged in through OAuth when used with `withAccessToken`        | `string`                                     |
| bodyEncoding                            | Specifies the format for sending the body of the request.                                                                          | `json` \| `url-encoded`                      |
| tokenResponseParser                     | Some providers returns some non-standard token responses. Specifies how to parse the JSON response to get the access token         | `(response: unknown) => OAuth.TokenResponse` |
| tokenRefreshResponseParser              | Some providers returns some non-standard refresh token responses. Specifies how to parse the JSON response to get the access token | `(response: unknown) => OAuth.TokenResponse` |


# OAuth

Dealing with OAuth can be tedious. So we've built a set of utilities to make that task way easier. There are two part to our utilities:

1. Authenticating with a service using OAuthService
2. Bringing authentication to Raycast commands using withAccessToken

`OAuthService`, `withAccessToken`, and `getAccessToken` are designed to work together. You'll find below different use cases for which you can use these utils.

## Using a built-in provider

We provide built-in providers that you can use out of the box, such as GitHub or Linear. You don't need to configure anything for them apart from the scope your extension requires.

```tsx
import { Detail, LaunchProps } from "@raycast/api";
import { withAccessToken, getAccessToken, OAuthService } from "@raycast/utils";

const github = OAuthService.github({
  scope: "notifications repo read:org read:user read:project",
});

function AuthorizedComponent(props: LaunchProps) {
  const { token } = getAccessToken();
  return <Detail markdown={`Access token: ${token}`} />;
}

export default withAccessToken(github)(AuthorizedComponent);
```

You can see our different providers on the following page: OAuthService

## Using your own client

```tsx
import { OAuth, Detail, LaunchProps } from "@raycast/api";
import { withAccessToken, getAccessToken, OAuthService } from "@raycast/utils";

const client = new OAuth.PKCEClient({
  redirectMethod: OAuth.RedirectMethod.Web,
  providerName: "Your Provider Name",
  providerIcon: "provider_icon.png",
  providerId: "yourProviderId",
  description: "Connect your {PROVIDER_NAME} account",
});

const provider = new OAuthService({
  client,
  clientId: "YOUR_CLIENT_ID",
  scope: "YOUR_SCOPES",
  authorizeUrl: "YOUR_AUTHORIZE_URL",
  tokenUrl: "YOUR_TOKEN_URL",
});

function AuthorizedComponent(props: LaunchProps) {
  const { token } = getAccessToken();
  return <Detail markdown={`Access token: ${token}`} />;
}

export default withAccessToken(provider)(AuthorizedComponent);
```

## Using `onAuthorize` to initialize an SDK or similar

This example is useful in cases where you want to initialize a third-party client and share it throughout your codebase.

```tsx
import { OAuthService } from "@raycast/utils";
import { LinearClient, LinearGraphQLClient } from "@linear/sdk";

let linearClient: LinearClient | null = null;

export const linear = OAuthService.linear({
  scope: "read write",
  onAuthorize({ token }) {
    linearClient = new LinearClient({ accessToken: token });
  },
});

export function withLinearClient<T>(Component: React.ComponentType<T>) {
  return withAccessToken<T>(linear)(Component);
}

export function getLinearClient(): { linearClient: LinearClient; graphQLClient: LinearGraphQLClient } {
  if (!linearClient) {
    throw new Error("No linear client initialized");
  }

  return { linearClient, graphQLClient: linearClient.client };
}
```


# `getAccessToken`

Utility function designed for retrieving authorization tokens within a component. It ensures that your React components have the necessary authentication state, either through OAuth or a personal access token.

{% hint style="info" %}
`getAccessToken` **must** be used within components that are nested inside a component wrapped with `withAccessToken`. Otherwise, the function will fail with an error.
{% endhint %}

## Signature

```tsx
function getAccessToken(): {
  token: string;
  type: "oauth" | "personal";
};
```

### Return

The function returns an object containing the following properties:

- `token`: A string representing the access token.
- `type`: An optional string that indicates the type of token retrieved. It can either be `oauth` for OAuth tokens or `personal` for personal access tokens.

## Example

```tsx
import { Detail } from "@raycast/api";
import { authorize } from "./oauth";

function AuthorizedComponent() {
  const { token } = getAccessToken();
  return <Detail markdown={`Access token: ${token}`} />;
}

export default withAccessToken({ authorize })(AuthorizedComponent);
```


# Getting a Google Client ID

Follow these steps to get a Google client ID:

## Step 1: Access Google Cloud Console

Navigate to the [Google Cloud Console](https://console.developers.google.com/apis/credentials).

## Step 2: Create a Project (if needed)

1. Click **Create Project**.
2. Provide a **Project Name**.
3. Select an optional **Organization**.
4. Click **Create**.

## Step 3: Enable Required APIs

1. Go to **Enabled APIs & services**.
2. Click **ENABLE APIS AND SERVICES**.
3. Search for and enable the required API (e.g., Google Drive API).

## Step 4: Configure OAuth Consent Screen

1. Click on **OAuth consent screen**.
2. Choose **Internal** or **External** (choose **External** if you intend to publish the extension in the Raycast store).
3. Enter these details:
   - **App name**: Raycast (Your Extension Name)
   - **User support email**: your-email@example.com
   - **Logo**: Paste Raycast's logo over there ([Link to Raycast logo](https://raycastapp.notion.site/Raycast-Press-Kit-ce1ccf8306b14ac8b8d47b3276bf34e0#29cbc2f3841444fdbdcb1fdff2ea2abf))
   - **Application home page**: https://www.raycast.com
   - **Application privacy policy link**: https://www.raycast.com/privacy
   - **Application terms of service link**: https://www.raycast.com/terms-of-service
   - **Authorized domains**: Click **ADD DOMAIN** then add `raycast.com`
   - **Developer contact**: your-email@example.com
4. Add the necessary scopes for your app (visit the [Google OAuth scopes docs](https://developers.google.com/identity/protocols/oauth2/scopes) if you manually need to add scopes)
5. Add your own email as a test user and others if needed
6. Review and go back to the dashboard

## Step 5: Create an OAuth Client ID

1. Go to **Credentials**, click **CREATE CREDENTIALS**, then **OAuth client ID**
2. Choose **iOS** as the application type
3. Set the **Bundle ID** to `com.raycast`.
4. Copy your **Client ID**

## Step 6: Use Your New Client ID 🎉

{% hint style="info" %}
You'll need to publish the app in the **OAuth consent screen** so that everyone can use it (and not only test users). The process can be more or less complex depending on whether you use sensitive or restrictive scopes.
{% endhint %}



# `withAccessToken`

Higher-order function fetching an authorization token to then access it. This makes it easier to handle OAuth in your different commands whether they're `view` commands, `no-view` commands, or `menu-bar` commands.

## Signature

```tsx
function withAccessToken<T = any>(
  options: WithAccessTokenParameters,
): <U extends WithAccessTokenComponentOrFn<T>>(
  fnOrComponent: U,
) => U extends (props: T) => Promise<void> | void ? Promise<void> : React.FunctionComponent<T>;
```

### Arguments

`options` is an object containing:

- `options.authorize`: a function that initiates the OAuth token retrieval process. It returns a promise that resolves to an access token.
- `options.personalAccessToken`: an optional string that represents an already obtained personal access token. When `options.personalAccessToken` is provided, it uses that token. Otherwise, it calls `options.authorize` to fetch an OAuth token asynchronously.
- `options.client`: an optional instance of a PKCE Client that you can create using Raycast API. This client is used to return the `idToken` as part of the `onAuthorize` callback below.
- `options.onAuthorize`: an optional callback function that is called once the user has been properly logged in through OAuth. This function is called with the `token`, its type (`oauth` if it comes from an OAuth flow or `personal` if it's a personal access token), and `idToken` if it's returned from `options.client`'s initial token set.

### Return

Returns the wrapped component if used in a `view` command or the wrapped function if used in a `no-view` command.

{% hint style="info" %}
Note that the access token isn't injected into the wrapped component props. Instead, it's been set as a global variable that you can get with getAccessToken.
{% endhint %}

## Example

{% tabs %}
{% tab title="view.tsx" %}

```tsx
import { List } from "@raycast/api";
import { withAccessToken } from "@raycast/utils";
import { authorize } from "./oauth";

function AuthorizedComponent(props) {
  return; // ...
}

export default withAccessToken({ authorize })(AuthorizedComponent);
```

{% endtab %}

{% tab title="no-view.tsx" %}

```tsx
import { showHUD } from "@raycast/api";
import { withAccessToken } from "@raycast/utils";
import { authorize } from "./oauth";

async function AuthorizedCommand() {
  await showHUD("Authorized");
}

export default withAccessToken({ authorize })(AuthorizedCommand);
```

{% endtab %}

{% tab title="onAuthorize.tsx" %}

```tsx
import { OAuthService } from "@raycast/utils";
import { LinearClient, LinearGraphQLClient } from "@linear/sdk";

let linearClient: LinearClient | null = null;

const linear = OAuthService.linear({
  scope: "read write",
  onAuthorize({ token }) {
    linearClient = new LinearClient({ accessToken: token });
  },
});

function MyIssues() {
  return; // ...
}

export default withAccessToken(linear)(View);
```

{% endtab %}
{% endtabs %}

## Types

### WithAccessTokenParameters

```ts
type OAuthType = "oauth" | "personal";

type OnAuthorizeParams = {
  token: string;
  type: OAuthType;
  idToken: string | null; // only present if `options.client` has been provided
};

type WithAccessTokenParameters = {
  client?: OAuth.PKCEClient;
  authorize: () => Promise<string>;
  personalAccessToken?: string;
  onAuthorize?: (params: OnAuthorizeParams) => void;
};
```

### WithAccessTokenComponentOrFn

```ts
type WithAccessTokenComponentOrFn<T = any> = ((params: T) => Promise<void> | void) | React.ComponentType<T>;
```


# React Hooks


# `useAI`

Hook which asks the AI to answer a prompt and returns the AsyncState corresponding to the execution of the query.

## Signature

```ts
function useAI(
  prompt: string,
  options?: {
    creativity?: AI.Creativity;
    model?: AI.Model;
    stream?: boolean;
    execute?: boolean;
    onError?: (error: Error) => void;
    onData?: (data: T) => void;
    onWillExecute?: (args: Parameters<T>) => void;
    failureToastOptions?: Partial<Pick<Toast.Options, "title" | "primaryAction" | "message">>;
  }
): AsyncState<String> & {
  revalidate: () => void;
};
```

### Arguments

- `prompt` is the prompt to ask the AI.

With a few options:

- `options.creativity` is a number between 0 and 2 to control the creativity of the answer. Concrete tasks, such as fixing grammar, require less creativity while open-ended questions, such as generating ideas, require more.
- `options.model` is a string determining which AI model will be used to answer.
- `options.stream` is a boolean controlling whether to stream the answer or only update the data when the entire answer has been received. By default, the `data` will be streamed.

Including the usePromise's options:

- `options.execute` is a boolean to indicate whether to actually execute the function or not. This is useful for cases where one of the function's arguments depends on something that might not be available right away (for example, depends on some user inputs). Because React requires every hook to be defined on the render, this flag enables you to define the hook right away but wait until you have all the arguments ready to execute the function.
- `options.onError` is a function called when an execution fails. By default, it will log the error and show a generic failure toast with an action to retry.
- `options.onData` is a function called when an execution succeeds.
- `options.onWillExecute` is a function called when an execution will start.
- `options.failureToastOptions` are the options to customize the title, message, and primary action of the failure toast.

### Return

Returns an object with the AsyncState corresponding to the execution of the function as well as a couple of methods to manipulate it.

- `data`, `error`, `isLoading` - see AsyncState.
- `revalidate` is a method to manually call the function with the same arguments again.

## Example

```tsx
import { Detail } from "@raycast/api";
import { useAI } from "@raycast/utils";

export default function Command() {
  const { data, isLoading } = useAI("Suggest 5 jazz songs");

  return <Detail isLoading={isLoading} markdown={data} />;
}
```

## Types

### AsyncState

An object corresponding to the execution state of the function.

```ts
// Initial State
{
  isLoading: true, // or `false` if `options.execute` is `false`
  data: undefined,
  error: undefined
}

// Success State
{
  isLoading: false,
  data: string,
  error: undefined
}

// Error State
{
  isLoading: false,
  data: undefined,
  error: Error
}

// Reloading State
{
  isLoading: true,
  data: string | undefined,
  error: Error | undefined
}
```


# `useCachedPromise`

Hook which wraps an asynchronous function or a function that returns a Promise and returns the AsyncState corresponding to the execution of the function.

It follows the `stale-while-revalidate` cache invalidation strategy popularized by [HTTP RFC 5861](https://tools.ietf.org/html/rfc5861). `useCachedPromise` first returns the data from cache (stale), then executes the promise (revalidate), and finally comes with the up-to-date data again.

The last value will be kept between command runs.

{% hint style="info" %}
The value needs to be JSON serializable.
The function is assumed to be constant (eg. changing it won't trigger a revalidation).
{% endhint %}

## Signature

```ts
type Result<T> = `type of the returned value of the returned Promise`;

function useCachedPromise<T, U>(
  fn: T,
  args?: Parameters<T>,
  options?: {
    initialData?: U;
    keepPreviousData?: boolean;
    abortable?: RefObject<AbortController | null | undefined>;
    execute?: boolean;
    onError?: (error: Error) => void;
    onData?: (data: Result<T>) => void;
    onWillExecute?: (args: Parameters<T>) => void;
    failureToastOptions?: Partial<Pick<Toast.Options, "title" | "primaryAction" | "message">>;
  },
): AsyncState<Result<T>> & {
  revalidate: () => void;
  mutate: MutatePromise<Result<T> | U>;
};
```

### Arguments

- `fn` is an asynchronous function or a function that returns a Promise.
- `args` is the array of arguments to pass to the function. Every time they change, the function will be executed again. You can omit the array if the function doesn't require any argument.

With a few options:

- `options.keepPreviousData` is a boolean to tell the hook to keep the previous results instead of returning the initial value if there aren't any in the cache for the new arguments. This is particularly useful when used for data for a List to avoid flickering. See Promise Argument dependent on List search text for more information.

Including the useCachedState's options:

- `options.initialData` is the initial value of the state if there aren't any in the Cache yet.

Including the usePromise's options:

- `options.abortable` is a reference to an [`AbortController`](https://developer.mozilla.org/en-US/docs/Web/API/AbortController) to cancel a previous call when triggering a new one.
- `options.execute` is a boolean to indicate whether to actually execute the function or not. This is useful for cases where one of the function's arguments depends on something that might not be available right away (for example, depends on some user inputs). Because React requires every hook to be defined on the render, this flag enables you to define the hook right away but wait until you have all the arguments ready to execute the function.
- `options.onError` is a function called when an execution fails. By default, it will log the error and show a generic failure toast with an action to retry.
- `options.onData` is a function called when an execution succeeds.
- `options.onWillExecute` is a function called when an execution will start.
- `options.failureToastOptions` are the options to customize the title, message, and primary action of the failure toast.

### Return

Returns an object with the AsyncState corresponding to the execution of the function as well as a couple of methods to manipulate it.

- `data`, `error`, `isLoading` - see AsyncState.
- `revalidate` is a method to manually call the function with the same arguments again.
- `mutate` is a method to wrap an asynchronous update and gives some control over how the `useCachedPromise`'s data should be updated while the update is going through. By default, the data will be revalidated (eg. the function will be called again) after the update is done. See Mutation and Optimistic Updates for more information.

## Example

```tsx
import { Detail, ActionPanel, Action } from "@raycast/api";
import { useCachedPromise } from "@raycast/utils";

export default function Command() {
  const abortable = useRef<AbortController>();
  const { isLoading, data, revalidate } = useCachedPromise(
    async (url: string) => {
      const response = await fetch(url, { signal: abortable.current?.signal });
      const result = await response.text();
      return result;
    },
    ["https://api.example"],
    {
      initialData: "Some Text",
      abortable,
    },
  );

  return (
    <Detail
      isLoading={isLoading}
      markdown={data}
      actions={
        <ActionPanel>
          <Action title="Reload" onAction={() => revalidate()} />
        </ActionPanel>
      }
    />
  );
}
```

## Promise Argument dependent on List search text

By default, when an argument passed to the hook changes, the function will be executed again and the cache's value for those arguments will be returned immediately. This means that in the case of new arguments that haven't been used yet, the initial data will be returned.

This behaviour can cause some flickering (initial data -> fetched data -> arguments change -> initial data -> fetched data, etc.). To avoid that, we can set `keepPreviousData` to `true` and the hook will keep the latest fetched data if the cache is empty for the new arguments (initial data -> fetched data -> arguments change -> fetched data).

```tsx
import { useState } from "react";
import { List, ActionPanel, Action } from "@raycast/api";
import { useCachedPromise } from "@raycast/utils";

export default function Command() {
  const [searchText, setSearchText] = useState("");
  const { isLoading, data } = useCachedPromise(
    async (url: string) => {
      const response = await fetch(url);
      const result = await response.json();
      return result;
    },
    [`https://api.example?q=${searchText}`],
    {
      // to make sure the screen isn't flickering when the searchText changes
      keepPreviousData: true,
    },
  );

  return (
    <List isLoading={isLoading} searchText={searchText} onSearchTextChange={setSearchText} throttle>
      {(data || []).map((item) => (
        <List.Item key={item.id} title={item.title} />
      ))}
    </List>
  );
}
```

## Mutation and Optimistic Updates

In an optimistic update, the UI behaves as though a change was successfully completed before receiving confirmation from the server that it was - it is being optimistic that it will eventually get the confirmation rather than an error. This allows for a more responsive user experience.

You can specify an `optimisticUpdate` function to mutate the data in order to reflect the change introduced by the asynchronous update.

When doing so, you can specify a `rollbackOnError` function to mutate back the data if the asynchronous update fails. If not specified, the data will be automatically rolled back to its previous value (before the optimistic update).

```tsx
import { Detail, ActionPanel, Action, showToast, Toast } from "@raycast/api";
import { useCachedPromise } from "@raycast/utils";

export default function Command() {
  const { isLoading, data, mutate } = useCachedPromise(
    async (url: string) => {
      const response = await fetch(url);
      const result = await response.text();
      return result;
    },
    ["https://api.example"],
  );

  const appendFoo = async () => {
    const toast = await showToast({ style: Toast.Style.Animated, title: "Appending Foo" });
    try {
      await mutate(
        // we are calling an API to do something
        fetch("https://api.example/append-foo"),
        {
          // but we are going to do it on our local data right away,
          // without waiting for the call to return
          optimisticUpdate(data) {
            return data + "foo";
          },
        },
      );
      // yay, the API call worked!
      toast.style = Toast.Style.Success;
      toast.title = "Foo appended";
    } catch (err) {
      // oh, the API call didn't work :(
      // the data will automatically be rolled back to its previous value
      toast.style = Toast.Style.Failure;
      toast.title = "Could not append Foo";
      toast.message = err.message;
    }
  };

  return (
    <Detail
      isLoading={isLoading}
      markdown={data}
      actions={
        <ActionPanel>
          <Action title="Append Foo" onAction={() => appendFoo()} />
        </ActionPanel>
      }
    />
  );
}
```

## Pagination

{% hint style="info" %}
When paginating, the hook will only cache the result of the first page.
{% endhint %}

The hook has built-in support for pagination. In order to enable pagination, `fn`'s type needs to change from

> an asynchronous function or a function that returns a Promise

to

> a function that returns an asynchronous function or a function that returns a Promise

In practice, this means going from

```ts
const { isLoading, data } = useCachedPromise(
  async (searchText: string) => {
    const response = await fetch(`https://api.example?q=${searchText}`);
    const data = await response.json();
    return data;
  },
  [searchText],
  {
    // to make sure the screen isn't flickering when the searchText changes
    keepPreviousData: true,
  },
);
```

to

```ts
const { isLoading, data, pagination } = useCachedPromise(
  (searchText: string) => async (options) => {
    const response = await fetch(`https://api.example?q=${searchText}&page=${options.page}`);
    const { data } = await response.json();
    const hasMore = options.page < 50;
    return { data, hasMore };
  },
  [searchText],
  {
    // to make sure the screen isn't flickering when the searchText changes
    keepPreviousData: true,
  },
);
```

or, if your data source uses cursor-based pagination, you can return a `cursor` alongside `data` and `hasMore`, and the cursor will be passed as an argument the next time the function gets called:

```ts
const { isLoading, data, pagination } = useCachedPromise(
  (searchText: string) => async (options) => {
    const response = await fetch(`https://api.example?q=${searchText}&cursor=${options.cursor}`);
    const { data, nextCursor } = await response.json();
    const hasMore = nextCursor !== undefined;
    return { data, hasMore, cursor: nextCursor };
  },
  [searchText],
  {
    // to make sure the screen isn't flickering when the searchText changes
    keepPreviousData: true,
  },
);
```

You'll notice that, in the second case, the hook returns an additional item: `pagination`. This can be passed to Raycast's `List` or `Grid` components in order to enable pagination.
Another thing to notice is that the async function receives a PaginationOptions argument, and returns a specific data format:

```ts
{
  data: any[];
  hasMore: boolean;
  cursor?: any;
}
```

Every time the promise resolves, the hook needs to figure out if it should paginate further, or if it should stop, and it uses `hasMore` for this.
In addition to this, the hook also needs `data`, and needs it to be an array, because internally it appends it to a list, thus making sure the `data` that the hook _returns_ always contains the data for all of the pages that have been loaded so far.

### Full Example

```tsx
import { setTimeout } from "node:timers/promises";
import { useState } from "react";
import { List } from "@raycast/api";
import { useCachedPromise } from "@raycast/utils";

export default function Command() {
  const [searchText, setSearchText] = useState("");

  const { isLoading, data, pagination } = useCachedPromise(
    (searchText: string) => async (options: { page: number }) => {
      await setTimeout(200);
      const newData = Array.from({ length: 25 }, (_v, index) => ({
        index,
        page: options.page,
        text: searchText,
      }));
      return { data: newData, hasMore: options.page < 10 };
    },
    [searchText],
  );

  return (
    <List isLoading={isLoading} onSearchTextChange={setSearchText} pagination={pagination}>
      {data?.map((item) => (
        <List.Item
          key={`${item.page} ${item.index} ${item.text}`}
          title={`Page ${item.page} Item ${item.index}`}
          subtitle={item.text}
        />
      ))}
    </List>
  );
}
```

## Types

### AsyncState

An object corresponding to the execution state of the function.

```ts
// Initial State
{
  isLoading: true, // or `false` if `options.execute` is `false`
  data: undefined,
  error: undefined
}

// Success State
{
  isLoading: false,
  data: T,
  error: undefined
}

// Error State
{
  isLoading: false,
  data: undefined,
  error: Error
}

// Reloading State
{
  isLoading: true,
  data: T | undefined,
  error: Error | undefined
}
```

### MutatePromise

A method to wrap an asynchronous update and gives some control about how the `useCachedPromise`'s data should be updated while the update is going through.

```ts
export type MutatePromise<T> = (
  asyncUpdate?: Promise<any>,
  options?: {
    optimisticUpdate?: (data: T) => T;
    rollbackOnError?: boolean | ((data: T) => T);
    shouldRevalidateAfter?: boolean;
  },
) => Promise<any>;
```

### PaginationOptions

An object passed to a `PaginatedPromise`, it has two properties:

- `page`: 0-indexed, this it's incremented every time the promise resolves, and is reset whenever `revalidate()` is called.
- `lastItem`: this is a copy of the last item in the `data` array from the last time the promise was executed. Provided for APIs that implement cursor-based pagination.
- `cursor`: this is the `cursor` property returned after the previous execution of `PaginatedPromise`. Useful when working with APIs that provide the next cursor explicitly.

```ts
export type PaginationOptions<T = any> = {
  page: number;
  lastItem?: T;
  cursor?: any;
};
```


# `useCachedState`

Hook which returns a stateful value, and a function to update it. It is similar to React's `useState` but the value will be kept between command runs.

{% hint style="info" %}
The value needs to be JSON serializable.
{% endhint %}

## Signature

```ts
function useCachedState<T>(
  key: string,
  initialState?: T,
  config?: {
    cacheNamespace?: string;
  },
): [T, (newState: T | ((prevState: T) => T)) => void];
```

### Arguments

- `key` is the unique identifier of the state. This can be used to share the state across components and/or commands (hooks using the same key will share the same state, eg. updating one will update the others).

With a few options:

- `initialState` is the initial value of the state if there aren't any in the Cache yet.
- `config.cacheNamespace` is a string that can be used to namespace the key.

## Example

```tsx
import { List, ActionPanel, Action } from "@raycast/api";
import { useCachedState } from "@raycast/utils";

export default function Command() {
  const [showDetails, setShowDetails] = useCachedState("show-details", false);

  return (
    <List
      isShowingDetail={showDetails}
      actions={
        <ActionPanel>
          <Action title={showDetails ? "Hide Details" : "Show Details"} onAction={() => setShowDetails((x) => !x)} />
        </ActionPanel>
      }
    >
      ...
    </List>
  );
}
```


# `useExec`

Hook that executes a command and returns the AsyncState corresponding to the execution of the command.

It follows the `stale-while-revalidate` cache invalidation strategy popularized by [HTTP RFC 5861](https://tools.ietf.org/html/rfc5861). `useExec` first returns the data from cache (stale), then executes the command (revalidate), and finally comes with the up-to-date data again.

The last value will be kept between command runs.

## Signature

There are two ways to use the hook.

The first one should be preferred when executing a single file. The file and its arguments don't have to be escaped.

```ts
function useExec<T, U>(
  file: string,
  arguments: string[],
  options?: {
    shell?: boolean | string;
    stripFinalNewline?: boolean;
    cwd?: string;
    env?: NodeJS.ProcessEnv;
    encoding?: BufferEncoding | "buffer";
    input?: string | Buffer;
    timeout?: number;
    parseOutput?: ParseExecOutputHandler<T>;
    initialData?: U;
    keepPreviousData?: boolean;
    execute?: boolean;
    onError?: (error: Error) => void;
    onData?: (data: T) => void;
    onWillExecute?: (args: string[]) => void;
    failureToastOptions?: Partial<Pick<Toast.Options, "title" | "primaryAction" | "message">>;
  }
): AsyncState<T> & {
  revalidate: () => void;
  mutate: MutatePromise<T | U | undefined>;
};
```

The second one can be used to execute more complex commands. The file and arguments are specified in a single `command` string. For example, `useExec('echo', ['Raycast'])` is the same as `useExec('echo Raycast')`.

If the file or an argument contains spaces, they must be escaped with backslashes. This matters especially if `command` is not a constant but a variable, for example with `environment.supportPath` or `process.cwd()`. Except for spaces, no escaping/quoting is needed.

The `shell` option must be used if the command uses shell-specific features (for example, `&&` or `||`), as opposed to being a simple file followed by its arguments.

```ts
function useExec<T, U>(
  command: string,
  options?: {
    shell?: boolean | string;
    stripFinalNewline?: boolean;
    cwd?: string;
    env?: NodeJS.ProcessEnv;
    encoding?: BufferEncoding | "buffer";
    input?: string | Buffer;
    timeout?: number;
    parseOutput?: ParseExecOutputHandler<T>;
    initialData?: U;
    keepPreviousData?: boolean;
    execute?: boolean;
    onError?: (error: Error) => void;
    onData?: (data: T) => void;
    onWillExecute?: (args: string[]) => void;
    failureToastOptions?: Partial<Pick<Toast.Options, "title" | "primaryAction" | "message">>;
  }
): AsyncState<T> & {
  revalidate: () => void;
  mutate: MutatePromise<T | U | undefined>;
};
```

### Arguments

- `file` is the path to the file to execute.
- `arguments` is an array of strings to pass as arguments to the file.

or

- `command` is the string to execute.

With a few options:

- `options.shell` is a boolean or a string to tell whether to run the command inside of a shell or not. If `true`, uses `/bin/sh`. A different shell can be specified as a string. The shell should understand the `-c` switch.

  We recommend against using this option since it is:

  - not cross-platform, encouraging shell-specific syntax.
  - slower, because of the additional shell interpretation.
  - unsafe, potentially allowing command injection.

- `options.stripFinalNewline` is a boolean to tell the hook to strip the final newline character from the output. By default, it will.
- `options.cwd` is a string to specify the current working directory of the child process. By default, it will be `process.cwd()`.
- `options.env` is a key-value pairs to set as the environment of the child process. It will extend automatically from `process.env`.
- `options.encoding` is a string to specify the character encoding used to decode the `stdout` and `stderr` output. If set to `"buffer"`, then `stdout` and `stderr` will be a `Buffer` instead of a string.
- `options.input` is a string or a Buffer to write to the `stdin` of the file.
- `options.timeout` is a number. If greater than `0`, the parent will send the signal `SIGTERM` if the child runs longer than timeout milliseconds. By default, the execution will timeout after 10000ms (eg. 10s).
- `options.parseOutput` is a function that accepts the output of the child process as an argument and returns the data the hooks will return - see ParseExecOutputHandler. By default, the hook will return `stdout`.

Including the useCachedPromise's options:

- `options.keepPreviousData` is a boolean to tell the hook to keep the previous results instead of returning the initial value if there aren't any in the cache for the new arguments. This is particularly useful when used for data for a List to avoid flickering. See Argument dependent on user input for more information.

Including the useCachedState's options:

- `options.initialData` is the initial value of the state if there aren't any in the Cache yet.

Including the usePromise's options:

- `options.execute` is a boolean to indicate whether to actually execute the function or not. This is useful for cases where one of the function's arguments depends on something that might not be available right away (for example, depends on some user inputs). Because React requires every hook to be defined on the render, this flag enables you to define the hook right away but wait until you have all the arguments ready to execute the function.
- `options.onError` is a function called when an execution fails. By default, it will log the error and show a generic failure toast with an action to retry.
- `options.onData` is a function called when an execution succeeds.
- `options.onWillExecute` is a function called when an execution will start.
- `options.failureToastOptions` are the options to customize the title, message, and primary action of the failure toast.

### Return

Returns an object with the AsyncState corresponding to the execution of the command as well as a couple of methods to manipulate it.

- `data`, `error`, `isLoading` - see AsyncState.
- `revalidate` is a method to manually call the function with the same arguments again.
- `mutate` is a method to wrap an asynchronous update and gives some control over how the `useFetch`'s data should be updated while the update is going through. By default, the data will be revalidated (eg. the function will be called again) after the update is done. See Mutation and Optimistic Updates for more information.

## Example

```tsx
import { List } from "@raycast/api";
import { useExec } from "@raycast/utils";
import { cpus } from "os";
import { useMemo } from "react";

const brewPath = cpus()[0].model.includes("Apple") ? "/opt/homebrew/bin/brew" : "/usr/local/bin/brew";

export default function Command() {
  const { isLoading, data } = useExec(brewPath, ["info", "--json=v2", "--installed"]);
  const results = useMemo<{ id: string; name: string }[]>(() => JSON.parse(data || "{}").formulae || [], [data]);

  return (
    <List isLoading={isLoading}>
      {results.map((item) => (
        <List.Item key={item.id} title={item.name} />
      ))}
    </List>
  );
}
```

## Argument dependent on user input

By default, when an argument passed to the hook changes, the function will be executed again and the cache's value for those arguments will be returned immediately. This means that in the case of new arguments that haven't been used yet, the initial data will be returned.

This behaviour can cause some flickering (initial data -> fetched data -> arguments change -> initial data -> fetched data, etc.). To avoid that, we can set `keepPreviousData` to `true` and the hook will keep the latest fetched data if the cache is empty for the new arguments (initial data -> fetched data -> arguments change -> fetched data).

```tsx
import { useState } from "react";
import { Detail, ActionPanel, Action } from "@raycast/api";
import { useFetch } from "@raycast/utils";

export default function Command() {
  const [searchText, setSearchText] = useState("");
  const { isLoading, data } = useExec("brew", ["info", searchText]);

  return <Detail isLoading={isLoading} markdown={data} />;
}
```

{% hint style="info" %}
When passing a user input to a command, be very careful about using the `shell` option as it could be potentially dangerous.
{% endhint %}

## Mutation and Optimistic Updates

In an optimistic update, the UI behaves as though a change was successfully completed before receiving confirmation from the server that it was - it is being optimistic that it will eventually get the confirmation rather than an error. This allows for a more responsive user experience.

You can specify an `optimisticUpdate` function to mutate the data in order to reflect the change introduced by the asynchronous update.

When doing so, you can specify a `rollbackOnError` function to mutate back the data if the asynchronous update fails. If not specified, the data will be automatically rolled back to its previous value (before the optimistic update).

```tsx
import { Detail, ActionPanel, Action, showToast, Toast } from "@raycast/api";
import { useFetch } from "@raycast/utils";

export default function Command() {
  const { isLoading, data, revalidate } = useExec("brew", ["info", "--json=v2", "--installed"]);
  const results = useMemo<{}[]>(() => JSON.parse(data || "[]"), [data]);

  const installFoo = async () => {
    const toast = await showToast({ style: Toast.Style.Animated, title: "Installing Foo" });
    try {
      await mutate(
        // we are calling an API to do something
        installBrewCask("foo"),
        {
          // but we are going to do it on our local data right away,
          // without waiting for the call to return
          optimisticUpdate(data) {
            return data?.concat({ name: "foo", id: "foo" });
          },
        },
      );
      // yay, the API call worked!
      toast.style = Toast.Style.Success;
      toast.title = "Foo installed";
    } catch (err) {
      // oh, the API call didn't work :(
      // the data will automatically be rolled back to its previous value
      toast.style = Toast.Style.Failure;
      toast.title = "Could not install Foo";
      toast.message = err.message;
    }
  };

  return (
    <List isLoading={isLoading}>
      {(data || []).map((item) => (
        <List.Item
          key={item.id}
          title={item.name}
          actions={
            <ActionPanel>
              <Action title="Install Foo" onAction={() => installFoo()} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
```

## Types

### AsyncState

An object corresponding to the execution state of the function.

```ts
// Initial State
{
  isLoading: true, // or `false` if `options.execute` is `false`
  data: undefined,
  error: undefined
}

// Success State
{
  isLoading: false,
  data: T,
  error: undefined
}

// Error State
{
  isLoading: false,
  data: undefined,
  error: Error
}

// Reloading State
{
  isLoading: true,
  data: T | undefined,
  error: Error | undefined
}
```

### MutatePromise

A method to wrap an asynchronous update and gives some control about how the `useFetch`'s data should be updated while the update is going through.

```ts
export type MutatePromise<T> = (
  asyncUpdate?: Promise<any>,
  options?: {
    optimisticUpdate?: (data: T) => T;
    rollbackOnError?: boolean | ((data: T) => T);
    shouldRevalidateAfter?: boolean;
  },
) => Promise<any>;
```

### ParseExecOutputHandler

A function that accepts the output of the child process as an argument and returns the data the hooks will return.

```ts
export type ParseExecOutputHandler<T> = (args: {
  /** The output of the process on stdout. */
  stdout: string | Buffer; // depends on the encoding option
  /** The output of the process on stderr. */
  stderr: string | Buffer; // depends on the encoding option
  error?: Error | undefined;
  /** The numeric exit code of the process that was run. */
  exitCode: number | null;
  /** The name of the signal that was used to terminate the process. For example, SIGFPE. */
  signal: NodeJS.Signals | null;
  /** Whether the process timed out. */
  timedOut: boolean;
  /** The command that was run, for logging purposes. */
  command: string;
  /** The options passed to the child process, for logging purposes. */
  options?: ExecOptions | undefined;
}) => T;
```


# `useFetch`

Hook which fetches the URL and returns the AsyncState corresponding to the execution of the fetch.

It follows the `stale-while-revalidate` cache invalidation strategy popularized by [HTTP RFC 5861](https://tools.ietf.org/html/rfc5861). `useFetch` first returns the data from cache (stale), then sends the request (revalidate), and finally comes with the up-to-date data again.

The last value will be kept between command runs.

## Signature

```ts
export function useFetch<V, U, T = V>(
  url: RequestInfo,
  options?: RequestInit & {
    parseResponse?: (response: Response) => Promise<V>;
    mapResult?: (result: V) => { data: T };
    initialData?: U;
    keepPreviousData?: boolean;
    execute?: boolean;
    onError?: (error: Error) => void;
    onData?: (data: T) => void;
    onWillExecute?: (args: [string, RequestInit]) => void;
    failureToastOptions?: Partial<Pick<Toast.Options, "title" | "primaryAction" | "message">>;
  },
): AsyncState<T> & {
  revalidate: () => void;
  mutate: MutatePromise<T | U | undefined>;
};
```

### Arguments

- `url` is the string representation of the URL to fetch.

With a few options:

- `options` extends [`RequestInit`](https://github.com/nodejs/undici/blob/v5.7.0/types/fetch.d.ts#L103-L117) allowing you to specify a body, headers, etc. to apply to the request.
- `options.parseResponse` is a function that accepts the Response as an argument and returns the data the hook will return. By default, the hook will return `response.json()` if the response has a JSON `Content-Type` header or `response.text()` otherwise.
- `options.mapResult` is an optional function that accepts whatever `options.parseResponse` returns as an argument, processes the response, and returns an object wrapping the result, i.e. `(response) => { return { data: response> } };`.

Including the useCachedPromise's options:

- `options.keepPreviousData` is a boolean to tell the hook to keep the previous results instead of returning the initial value if there aren't any in the cache for the new arguments. This is particularly useful when used for data for a List to avoid flickering. See Argument dependent on List search text for more information.

Including the useCachedState's options:

- `options.initialData` is the initial value of the state if there aren't any in the Cache yet.

Including the usePromise's options:

- `options.execute` is a boolean to indicate whether to actually execute the function or not. This is useful for cases where one of the function's arguments depends on something that might not be available right away (for example, depends on some user inputs). Because React requires every hook to be defined on the render, this flag enables you to define the hook right away but wait until you have all the arguments ready to execute the function.
- `options.onError` is a function called when an execution fails. By default, it will log the error and show a generic failure toast with an action to retry.
- `options.onData` is a function called when an execution succeeds.
- `options.onWillExecute` is a function called when an execution will start.
- `options.failureToastOptions` are the options to customize the title, message, and primary action of the failure toast.

### Return

Returns an object with the AsyncState corresponding to the execution of the fetch as well as a couple of methods to manipulate it.

- `data`, `error`, `isLoading` - see AsyncState.
- `revalidate` is a method to manually call the function with the same arguments again.
- `mutate` is a method to wrap an asynchronous update and gives some control over how the `useFetch`'s data should be updated while the update is going through. By default, the data will be revalidated (eg. the function will be called again) after the update is done. See Mutation and Optimistic Updates for more information.

## Example

```tsx
import { Detail, ActionPanel, Action } from "@raycast/api";
import { useFetch } from "@raycast/utils";

export default function Command() {
  const { isLoading, data, revalidate } = useFetch("https://api.example");

  return (
    <Detail
      isLoading={isLoading}
      markdown={data}
      actions={
        <ActionPanel>
          <Action title="Reload" onAction={() => revalidate()} />
        </ActionPanel>
      }
    />
  );
}
```

## Argument dependent on List search text

By default, when an argument passed to the hook changes, the function will be executed again and the cache's value for those arguments will be returned immediately. This means that in the case of new arguments that haven't been used yet, the initial data will be returned.

This behaviour can cause some flickering (initial data -> fetched data -> arguments change -> initial data -> fetched data, etc.). To avoid that, we can set `keepPreviousData` to `true` and the hook will keep the latest fetched data if the cache is empty for the new arguments (initial data -> fetched data -> arguments change -> fetched data).

```tsx
import { useState } from "react";
import { List, ActionPanel, Action } from "@raycast/api";
import { useFetch } from "@raycast/utils";

export default function Command() {
  const [searchText, setSearchText] = useState("");
  const { isLoading, data } = useFetch(`https://api.example?q=${searchText}`, {
    // to make sure the screen isn't flickering when the searchText changes
    keepPreviousData: true,
  });

  return (
    <List isLoading={isLoading} searchText={searchText} onSearchTextChange={setSearchText} throttle>
      {(data || []).map((item) => (
        <List.Item key={item.id} title={item.title} />
      ))}
    </List>
  );
}
```

## Mutation and Optimistic Updates

In an optimistic update, the UI behaves as though a change was successfully completed before receiving confirmation from the server that it was - it is being optimistic that it will eventually get the confirmation rather than an error. This allows for a more responsive user experience.

You can specify an `optimisticUpdate` function to mutate the data in order to reflect the change introduced by the asynchronous update.

When doing so, you can specify a `rollbackOnError` function to mutate back the data if the asynchronous update fails. If not specified, the data will be automatically rolled back to its previous value (before the optimistic update).

```tsx
import { Detail, ActionPanel, Action, showToast, Toast } from "@raycast/api";
import { useFetch } from "@raycast/utils";

export default function Command() {
  const { isLoading, data, mutate } = useFetch("https://api.example");

  const appendFoo = async () => {
    const toast = await showToast({ style: Toast.Style.Animated, title: "Appending Foo" });
    try {
      await mutate(
        // we are calling an API to do something
        fetch("https://api.example/append-foo"),
        {
          // but we are going to do it on our local data right away,
          // without waiting for the call to return
          optimisticUpdate(data) {
            return data + "foo";
          },
        },
      );
      // yay, the API call worked!
      toast.style = Toast.Style.Success;
      toast.title = "Foo appended";
    } catch (err) {
      // oh, the API call didn't work :(
      // the data will automatically be rolled back to its previous value
      toast.style = Toast.Style.Failure;
      toast.title = "Could not append Foo";
      toast.message = err.message;
    }
  };

  return (
    <Detail
      isLoading={isLoading}
      markdown={data}
      actions={
        <ActionPanel>
          <Action title="Append Foo" onAction={() => appendFoo()} />
        </ActionPanel>
      }
    />
  );
}
```

## Pagination

{% hint style="info" %}
When paginating, the hook will only cache the result of the first page.
{% endhint %}

The hook has built-in support for pagination. In order to enable pagination, `url`s type needs to change from `RequestInfo` to a function that receives a PaginationOptions argument, and returns a `RequestInfo`.

In practice, this means going from

```ts
const { isLoading, data } = useFetch(
  "https://api.ycombinator.com/v0.1/companies?" + new URLSearchParams({ q: searchText }).toString(),
  {
    mapResult(result: SearchResult) {
      return {
        data: result.companies,
      };
    },
    keepPreviousData: true,
    initialData: [],
  },
);
```

to

```ts
const { isLoading, data, pagination } = useFetch(
  (options) =>
    "https://api.ycombinator.com/v0.1/companies?" +
    new URLSearchParams({ page: String(options.page + 1), q: searchText }).toString(),
  {
    mapResult(result: SearchResult) {
      return {
        data: result.companies,
        hasMore: result.page < result.totalPages,
      };
    },
    keepPreviousData: true,
    initialData: [],
  },
);
```

or, if your data source uses cursor-based pagination, you can return a `cursor` alongside `data` and `hasMore`, and the cursor will be passed as an argument the next time the function gets called:

```ts
const { isLoading, data, pagination } = useFetch(
  (options) =>
    "https://api.ycombinator.com/v0.1/companies?" +
    new URLSearchParams({ cursor: options.cursor, q: searchText }).toString(),
  {
    mapResult(result: SearchResult) {
      const { companies, nextCursor } = result;
      const hasMore = nextCursor !== undefined;
      return { data: companies, hasMore, cursor: nextCursor, };
    },
    keepPreviousData: true,
    initialData: [],
  },
);
```

You'll notice that, in the second case, the hook returns an additional item: `pagination`. This can be passed to Raycast's `List` or `Grid` components in order to enable pagination.
Another thing to notice is that `mapResult`, which is normally optional, is actually required when using pagination. Furthermore, its return type is

```ts
{
  data: any[],
  hasMore?: boolean;
  cursor?: any;
}
```

Every time the URL is fetched, the hook needs to figure out if it should paginate further, or if it should stop, and it uses the `hasMore` for this.
In addition to this, the hook also needs `data`, and needs it to be an array, because internally it appends it to a list, thus making sure the `data` that the hook _returns_ always contains the data for all of the pages that have been fetched so far.

### Full Example

```tsx
import { Icon, Image, List } from "@raycast/api";
import { useFetch } from "@raycast/utils";
import { useState } from "react";

type SearchResult = { companies: Company[]; page: number; totalPages: number };
type Company = { id: number; name: string; smallLogoUrl?: string };
export default function Command() {
  const [searchText, setSearchText] = useState("");
  const { isLoading, data, pagination } = useFetch(
    (options) =>
      "https://api.ycombinator.com/v0.1/companies?" +
      new URLSearchParams({ page: String(options.page + 1), q: searchText }).toString(),
    {
      mapResult(result: SearchResult) {
        return {
          data: result.companies,
          hasMore: result.page < result.totalPages,
        };
      },
      keepPreviousData: true,
      initialData: [],
    },
  );

  return (
    <List isLoading={isLoading} pagination={pagination} onSearchTextChange={setSearchText}>
      {data.map((company) => (
        <List.Item
          key={company.id}
          icon={{ source: company.smallLogoUrl ?? Icon.MinusCircle, mask: Image.Mask.RoundedRectangle }}
          title={company.name}
        />
      ))}
    </List>
  );
}
```

## Types

### AsyncState

An object corresponding to the execution state of the function.

```ts
// Initial State
{
  isLoading: true, // or `false` if `options.execute` is `false`
  data: undefined,
  error: undefined
}

// Success State
{
  isLoading: false,
  data: T,
  error: undefined
}

// Error State
{
  isLoading: false,
  data: undefined,
  error: Error
}

// Reloading State
{
  isLoading: true,
  data: T | undefined,
  error: Error | undefined
}
```

### MutatePromise

A method to wrap an asynchronous update and gives some control about how the `useFetch`'s data should be updated while the update is going through.

```ts
export type MutatePromise<T> = (
  asyncUpdate?: Promise<any>,
  options?: {
    optimisticUpdate?: (data: T) => T;
    rollbackOnError?: boolean | ((data: T) => T);
    shouldRevalidateAfter?: boolean;
  },
) => Promise<any>;
```

### PaginationOptions

An object passed to a `PaginatedRequestInfo`, it has two properties:

- `page`: 0-indexed, this it's incremented every time the promise resolves, and is reset whenever `revalidate()` is called.
- `lastItem`: this is a copy of the last item in the `data` array from the last time the promise was executed. Provided for APIs that implement cursor-based pagination.
- `cursor`: this is the `cursor` property returned after the previous execution of `PaginatedPromise`. Useful when working with APIs that provide the next cursor explicitly.

```ts
export type PaginationOptions<T = any> = {
  page: number;
  lastItem?: T;
  cursor?: any;
};
```


# `useForm`

Hook that provides a high-level interface to work with Forms, and more particularly, with Form validations. It incorporates all the good practices to provide a great User Experience for your Forms.

## Signature

```ts
function useForm<T extends Form.Values>(props: {
  onSubmit: (values: T) => void | boolean | Promise<void | boolean>;
  initialValues?: Partial<T>;
  validation?: {
    [id in keyof T]?: ((value: T[id]) => string | undefined | null) | FormValidation;
  };
}): {
  handleSubmit: (values: T) => void | boolean | Promise<void | boolean>;
  itemProps: {
    [id in keyof T]: Partial<Form.ItemProps<T[id]>> & {
      id: string;
    };
  };
  setValidationError: (id: keyof T, error: ValidationError) => void;
  setValue: <K extends keyof T>(id: K, value: T[K]) => void;
  values: T;
  focus: (id: keyof T) => void;
  reset: (initialValues?: Partial<T>) => void;
};
```

### Arguments

- `onSubmit` is a callback that will be called when the form is submitted and all validations pass.

With a few options:

- `initialValues` are the initial values to set when the Form is first rendered.
- `validation` are the validation rules for the Form. A validation for a Form item is a function that takes the current value of the item as an argument and must return a string when the validation is failing. We also provide some shorthands for common cases, see FormValidation.

### Return

Returns an object which contains the necessary methods and props to provide a good User Experience in your Form.

- `handleSubmit` is a function to pass to the `onSubmit` prop of the `<Action.SubmitForm>` element. It wraps the initial `onSubmit` argument with some goodies related to the validation.
- `itemProps` are the props that must be passed to the `<Form.Item>` elements to handle the validations.

It also contains some additions for easy manipulation of the Form's data.

- `values` is the current values of the Form.
- `setValue` is a function that can be used to programmatically set the value of a specific field.
- `setValidationError` is a function that can be used to programmatically set the validation of a specific field.
- `focus` is a function that can be used to programmatically focus a specific field.
- `reset` is a function that can be used to reset the values of the Form. Optionally, you can specify the values to set when the Form is reset.

## Example

```tsx
import { Action, ActionPanel, Form, showToast, Toast } from "@raycast/api";
import { useForm, FormValidation } from "@raycast/utils";

interface SignUpFormValues {
  firstName: string;
  lastName: string;
  birthday: Date | null;
  password: string;
  number: string;
  hobbies: string[];
}

export default function Command() {
  const { handleSubmit, itemProps } = useForm<SignUpFormValues>({
    onSubmit(values) {
      showToast({
        style: Toast.Style.Success,
        title: "Yay!",
        message: `${values.firstName} ${values.lastName} account created`,
      });
    },
    validation: {
      firstName: FormValidation.Required,
      lastName: FormValidation.Required,
      password: (value) => {
        if (value && value.length < 8) {
          return "Password must be at least 8 symbols";
        } else if (!value) {
          return "The item is required";
        }
      },
      number: (value) => {
        if (value && value !== "2") {
          return "Please select '2'";
        }
      },
    },
  });
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit" onSubmit={handleSubmit} />
        </ActionPanel>
      }
    >
      <Form.TextField title="First Name" placeholder="Enter first name" {...itemProps.firstName} />
      <Form.TextField title="Last Name" placeholder="Enter last name" {...itemProps.lastName} />
      <Form.DatePicker title="Date of Birth" {...itemProps.birthday} />
      <Form.PasswordField
        title="Password"
        placeholder="Enter password at least 8 characters long"
        {...itemProps.password}
      />
      <Form.Dropdown title="Your Favorite Number" {...itemProps.number}>
        {[1, 2, 3, 4, 5, 6, 7].map((num) => {
          return <Form.Dropdown.Item value={String(num)} title={String(num)} key={num} />;
        })}
      </Form.Dropdown>
    </Form>
  );
}
```

## Types

### FormValidation

Shorthands for common validation cases

#### Enumeration members

| Name     | Description                                       |
| :------- | :------------------------------------------------ |
| Required | Show an error when the value of the item is empty |


# `useFrecencySorting`

Hook to sort an array by its frecency and provide methods to update the frecency of its items.

Frecency is a measure that combines frequency and recency. The more often an item is visited, and the more recently an item is visited, the higher it will rank.

## Signature

```ts
function useFrecencySorting<T>(
  data?: T[],
  options?: {
    namespace?: string;
    key?: (item: T) => string;
    sortUnvisited?: (a: T, b: T) => number;
  },
): {
  data: T[];
  visitItem: (item: T) => Promise<void>;
  resetRanking: (item: T) => Promise<void>;
};
```

### Arguments

- `data` is the array to sort

With a few options:

- `options.namespace` is a string that can be used to namespace the frecency data (if you have multiple arrays that you want to sort in the same extension).
- `options.key` is a function that should return a unique string for each item of the array to sort. By default, it will use `item.id`. If the items do not have an `id` field, this option is required.
- `options.sortUnvisited` is a function to sort the items that have never been visited. By default, the order of the input will be preserved.

### Return

Returns an object with the sorted array and some methods to update the frecency of the items.

- `data` is the sorted array. The order will be preserved for items that have never been visited
- `visitItem` is a method to use when an item is visited/used. It will increase its frecency.
- `resetRanking` is a method that can be used to reset the frecency of an item.

## Example

```tsx
import { List, ActionPanel, Action, Icon } from "@raycast/api";
import { useFetch, useFrecencySorting } from "@raycast/utils";

export default function Command() {
  const { isLoading, data } = useFetch("https://api.example");
  const { data: sortedData, visitItem, resetRanking } = useFrecencySorting(data);

  return (
    <List isLoading={isLoading}>
      {sortedData.map((item) => (
        <List.Item
          key={item.id}
          title={item.title}
          actions={
            <ActionPanel>
              <Action.OpenInBrowser url={item.url} onOpen={() => visitItem(item)} />
              <Action.CopyToClipboard title="Copy Link" content={item.url} onCopy={() => visitItem(item)} />
              <Action title="Reset Ranking" icon={Icon.ArrowCounterClockwise} onAction={() => resetRanking(item)} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
```


# `useLocalStorage`

A hook to manage a value in the local storage.

## Signature

```ts
function useLocalStorage<T>(key: string, initialValue?: T): {
  value: T | undefined;
  setValue: (value: T) => Promise<void>;
  removeValue: () => Promise<void>;
  isLoading: boolean;
}
```

### Arguments

- `key` - The key to use for the value in the local storage.
- `initialValue` - The initial value to use if the key doesn't exist in the local storage.

### Return

Returns an object with the following properties:

- `value` - The value from the local storage or the initial value if the key doesn't exist.
- `setValue` - A function to update the value in the local storage.
- `removeValue` - A function to remove the value from the local storage.
- `isLoading` - A boolean indicating if the value is loading.

## Example

```tsx
import { Action, ActionPanel, Color, Icon, List } from "@raycast/api";
import { useLocalStorage } from "@raycast/utils";

const exampleTodos = [
  { id: "1", title: "Buy milk", done: false },
  { id: "2", title: "Walk the dog", done: false },
  { id: "3", title: "Call mom", done: false },
];

export default function Command() {
  const { value: todos, setValue: setTodos, isLoading } = useLocalStorage("todos", exampleTodos);

  async function toggleTodo(id: string) {
    const newTodos = todos?.map((todo) => (todo.id === id ? { ...todo, done: !todo.done } : todo)) ?? [];
    await setTodos(newTodos);
  }

  return (
    <List isLoading={isLoading}>
      {todos?.map((todo) => (
        <List.Item
          icon={todo.done ? { source: Icon.Checkmark, tintColor: Color.Green } : Icon.Circle}
          key={todo.id}
          title={todo.title}
          actions={
            <ActionPanel>
              <Action title={todo.done ? "Uncomplete" : "Complete"} onAction={() => toggleTodo(todo.id)} />
              <Action title="Delete" style={Action.Style.Destructive} onAction={() => toggleTodo(todo.id)} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
```


# `usePromise`

Hook which wraps an asynchronous function or a function that returns a Promise and returns the AsyncState corresponding to the execution of the function.

{% hint style="info" %}
The function is assumed to be constant (eg. changing it won't trigger a revalidation).
{% endhint %}

## Signature

```ts
type Result<T> = `type of the returned value of the returned Promise`;

function usePromise<T>(
  fn: T,
  args?: Parameters<T>,
  options?: {
    abortable?: RefObject<AbortController | null | undefined>;
    execute?: boolean;
    onError?: (error: Error) => void;
    onData?: (data: Result<T>) => void;
    onWillExecute?: (args: Parameters<T>) => void;
    failureToastOptions?: Partial<Pick<Toast.Options, "title" | "primaryAction" | "message">>;
  },
): AsyncState<Result<T>> & {
  revalidate: () => void;
  mutate: MutatePromise<Result<T> | undefined>;
};
```

### Arguments

- `fn` is an asynchronous function or a function that returns a Promise.
- `args` is the array of arguments to pass to the function. Every time they change, the function will be executed again. You can omit the array if the function doesn't require any argument.

With a few options:

- `options.abortable` is a reference to an [`AbortController`](https://developer.mozilla.org/en-US/docs/Web/API/AbortController) to cancel a previous call when triggering a new one.
- `options.execute` is a boolean to indicate whether to actually execute the function or not. This is useful for cases where one of the function's arguments depends on something that might not be available right away (for example, depends on some user inputs). Because React requires every hook to be defined on the render, this flag enables you to define the hook right away but wait until you have all the arguments ready to execute the function.
- `options.onError` is a function called when an execution fails. By default, it will log the error and show a generic failure toast with an action to retry.
- `options.onData` is a function called when an execution succeeds.
- `options.onWillExecute` is a function called when an execution will start.
- `options.failureToastOptions` are the options to customize the title, message, and primary action of the failure toast.

### Returns

Returns an object with the AsyncState corresponding to the execution of the function as well as a couple of methods to manipulate it.

- `data`, `error`, `isLoading` - see AsyncState.
- `revalidate` is a method to manually call the function with the same arguments again.
- `mutate` is a method to wrap an asynchronous update and gives some control about how the `usePromise`'s data should be updated while the update is going through. By default, the data will be revalidated (eg. the function will be called again) after the update is done. See Mutation and Optimistic Updates for more information.

## Example

```tsx
import { Detail, ActionPanel, Action } from "@raycast/api";
import { usePromise } from "@raycast/utils";

export default function Command() {
  const abortable = useRef<AbortController>();
  const { isLoading, data, revalidate } = usePromise(
    async (url: string) => {
      const response = await fetch(url, { signal: abortable.current?.signal });
      const result = await response.text();
      return result;
    },
    ["https://api.example"],
    {
      abortable,
    },
  );

  return (
    <Detail
      isLoading={isLoading}
      markdown={data}
      actions={
        <ActionPanel>
          <Action title="Reload" onAction={() => revalidate()} />
        </ActionPanel>
      }
    />
  );
}
```

## Mutation and Optimistic Updates

In an optimistic update, the UI behaves as though a change was successfully completed before receiving confirmation from the server that it was - it is being optimistic that it will eventually get the confirmation rather than an error. This allows for a more responsive user experience.

You can specify an `optimisticUpdate` function to mutate the data in order to reflect the change introduced by the asynchronous update.

When doing so, you can specify a `rollbackOnError` function to mutate back the data if the asynchronous update fails. If not specified, the data will be automatically rolled back to its previous value (before the optimistic update).

```tsx
import { Detail, ActionPanel, Action, showToast, Toast } from "@raycast/api";
import { usePromise } from "@raycast/utils";

export default function Command() {
  const { isLoading, data, mutate } = usePromise(
    async (url: string) => {
      const response = await fetch(url);
      const result = await response.text();
      return result;
    },
    ["https://api.example"],
  );

  const appendFoo = async () => {
    const toast = await showToast({ style: Toast.Style.Animated, title: "Appending Foo" });
    try {
      await mutate(
        // we are calling an API to do something
        fetch("https://api.example/append-foo"),
        {
          // but we are going to do it on our local data right away,
          // without waiting for the call to return
          optimisticUpdate(data) {
            return data + "foo";
          },
        },
      );
      // yay, the API call worked!
      toast.style = Toast.Style.Success;
      toast.title = "Foo appended";
    } catch (err) {
      // oh, the API call didn't work :(
      // the data will automatically be rolled back to its previous value
      toast.style = Toast.Style.Failure;
      toast.title = "Could not append Foo";
      toast.message = err.message;
    }
  };

  return (
    <Detail
      isLoading={isLoading}
      markdown={data}
      actions={
        <ActionPanel>
          <Action title="Append Foo" onAction={() => appendFoo()} />
        </ActionPanel>
      }
    />
  );
}
```

## Pagination

The hook has built-in support for pagination. In order to enable pagination, `fn`'s type needs to change from

> an asynchronous function or a function that returns a Promise

to

> a function that returns an asynchronous function or a function that returns a Promise

In practice, this means going from

```ts
const { isLoading, data } = usePromise(
  async (searchText: string) => {
    const data = await getUser(); // or any asynchronous logic you need to perform
    return data;
  },
  [searchText],
);
```

to

```ts
const { isLoading, data, pagination } = usePromise(
  (searchText: string) =>
    async ({ page, lastItem, cursor }) => {
      const { data } = await getUsers(page); // or any other asynchronous logic you need to perform
      const hasMore = page < 50;
      return { data, hasMore };
    },
  [searchText],
);
```

or, if your data source uses cursor-based pagination, you can return a `cursor` alongside `data` and `hasMore`, and the cursor will be passed as an argument the next time the function gets called:

```ts
const { isLoading, data, pagination } = usePromise(
  (searchText: string) =>
    async ({ page, lastItem, cursor }) => {
      const { data, nextCursor } = await getUsers(cursor); // or any other asynchronous logic you need to perform
      const hasMore = nextCursor !== undefined;
      return { data, hasMore, cursor: nextCursor };
    },
  [searchText],
);
```

You'll notice that, in the second case, the hook returns an additional item: `pagination`. This can be passed to Raycast's `List` or `Grid` components in order to enable pagination.
Another thing to notice is that the async function receives a PaginationOptions argument, and returns a specific data format:

```ts
{
  data: any[];
  hasMore: boolean;
  cursor?: any;
}
```

Every time the promise resolves, the hook needs to figure out if it should paginate further, or if it should stop, and it uses `hasMore` for this.
In addition to this, the hook also needs `data`, and needs it to be an array, because internally it appends it to a list, thus making sure the `data` that the hook _returns_ always contains the data for all of the pages that have been loaded so far.
Additionally, you can also pass a `cursor` property, which will be included along with `page` and `lastItem` in the next pagination call.

### Full Example

```tsx
import { setTimeout } from "node:timers/promises";
import { useState } from "react";
import { List } from "@raycast/api";
import { usePromise } from "@raycast/utils";

export default function Command() {
  const [searchText, setSearchText] = useState("");

  const { isLoading, data, pagination } = usePromise(
    (searchText: string) => async (options: { page: number }) => {
      await setTimeout(200);
      const newData = Array.from({ length: 25 }, (_v, index) => ({
        index,
        page: options.page,
        text: searchText,
      }));
      return { data: newData, hasMore: options.page < 10 };
    },
    [searchText],
  );

  return (
    <List isLoading={isLoading} onSearchTextChange={setSearchText} pagination={pagination}>
      {data?.map((item) => (
        <List.Item
          key={`${item.page} ${item.index} ${item.text}`}
          title={`Page ${item.page} Item ${item.index}`}
          subtitle={item.text}
        />
      ))}
    </List>
  );
}
```

## Types

### AsyncState

An object corresponding to the execution state of the function.

```ts
// Initial State
{
  isLoading: true, // or `false` if `options.execute` is `false`
  data: undefined,
  error: undefined
}

// Success State
{
  isLoading: false,
  data: T,
  error: undefined
}

// Error State
{
  isLoading: false,
  data: undefined,
  error: Error
}

// Reloading State
{
  isLoading: true,
  data: T | undefined,
  error: Error | undefined
}
```

### MutatePromise

A method to wrap an asynchronous update and gives some control about how the `usePromise`'s data should be updated while the update is going through.

```ts
export type MutatePromise<T> = (
  asyncUpdate?: Promise<any>,
  options?: {
    optimisticUpdate?: (data: T) => T;
    rollbackOnError?: boolean | ((data: T) => T);
    shouldRevalidateAfter?: boolean;
  },
) => Promise<any>;
```

### PaginationOptions

An object passed to a `PaginatedPromise`, it has two properties:

- `page`: 0-indexed, this it's incremented every time the promise resolves, and is reset whenever `revalidate()` is called.
- `lastItem`: this is a copy of the last item in the `data` array from the last time the promise was executed. Provided for APIs that implement cursor-based pagination.
- `cursor`: this is the `cursor` property returned after the previous execution of `PaginatedPromise`. Useful when working with APIs that provide the next cursor explicitly.

```ts
export type PaginationOptions<T = any> = {
  page: number;
  lastItem?: T;
  cursor?: any;
};
```


# `useSQL`

Hook which executes a query on a local SQL database and returns the AsyncState corresponding to the execution of the query.

## Signature

```ts
function useSQL<T>(
  databasePath: string,
  query: string,
  options?: {
    permissionPriming?: string;
    execute?: boolean;
    onError?: (error: Error) => void;
    onData?: (data: T) => void;
    onWillExecute?: (args: string[]) => void;
    failureToastOptions?: Partial<Pick<Toast.Options, "title" | "primaryAction" | "message">>;
  }
): AsyncState<T> & {
  revalidate: () => void;
  mutate: MutatePromise<T | U | undefined>;
  permissionView: React.ReactNode | undefined;
};
```

### Arguments

- `databasePath` is the path to the local SQL database.
- `query` is the SQL query to run on the database.

With a few options:

- `options.permissionPriming` is a string explaining why the extension needs full disk access. For example, the Apple Notes extension uses `"This is required to search your Apple Notes."`. While it is optional, we recommend setting it to help users understand.

Including the usePromise's options:

- `options.execute` is a boolean to indicate whether to actually execute the function or not. This is useful for cases where one of the function's arguments depends on something that might not be available right away (for example, depends on some user inputs). Because React requires every hook to be defined on the render, this flag enables you to define the hook right away but wait until you have all the arguments ready to execute the function.
- `options.onError` is a function called when an execution fails. By default, it will log the error and show a generic failure toast with an action to retry.
- `options.onData` is a function called when an execution succeeds.
- `options.onWillExecute` is a function called when an execution will start.
- `options.failureToastOptions` are the options to customize the title, message, and primary action of the failure toast.

### Return

Returns an object with the AsyncState corresponding to the execution of the function as well as a couple of methods to manipulate it.

- `data`, `error`, `isLoading` - see AsyncState.
- `permissionView` is a React Node that should be returned when present. It will prompt users to grant full disk access (which is required for the hook to work).
- `revalidate` is a method to manually call the function with the same arguments again.
- `mutate` is a method to wrap an asynchronous update and gives some control over how the `useSQL`'s data should be updated while the update is going through. By default, the data will be revalidated (eg. the function will be called again) after the update is done. See Mutation and Optimistic Updates for more information.

## Example

```tsx
import { useSQL } from "@raycast/utils";
import { resolve } from "path";
import { homedir } from "os";

const NOTES_DB = resolve(homedir(), "Library/Group Containers/group.com.apple.notes/NoteStore.sqlite");
const notesQuery = `SELECT id, title FROM ...`;
type NoteItem = {
  id: string;
  title: string;
};

export default function Command() {
  const { isLoading, data, permissionView } = useSQL<NoteItem>(NOTES_DB, notesQuery);

  if (permissionView) {
    return permissionView;
  }

  return (
    <List isLoading={isLoading}>
      {(data || []).map((item) => (
        <List.Item key={item.id} title={item.title} />
      ))}
    </List>
  );
}
```

## Mutation and Optimistic Updates

In an optimistic update, the UI behaves as though a change was successfully completed before receiving confirmation from the server that it was - it is being optimistic that it will eventually get the confirmation rather than an error. This allows for a more responsive user experience.

You can specify an `optimisticUpdate` function to mutate the data in order to reflect the change introduced by the asynchronous update.

When doing so, you can specify a `rollbackOnError` function to mutate back the data if the asynchronous update fails. If not specified, the data will be automatically rolled back to its previous value (before the optimistic update).

```tsx
import { Detail, ActionPanel, Action, showToast, Toast } from "@raycast/api";
import { useSQL } from "@raycast/utils";

const NOTES_DB = resolve(homedir(), "Library/Group Containers/group.com.apple.notes/NoteStore.sqlite");
const notesQuery = `SELECT id, title FROM ...`;
type NoteItem = {
  id: string;
  title: string;
};

export default function Command() {
  const { isLoading, data, mutate, permissionView } = useFetch("https://api.example");

  if (permissionView) {
    return permissionView;
  }

  const createNewNote = async () => {
    const toast = await showToast({ style: Toast.Style.Animated, title: "Creating new Note" });
    try {
      await mutate(
        // we are calling an API to do something
        somehowCreateANewNote(),
        {
          // but we are going to do it on our local data right away,
          // without waiting for the call to return
          optimisticUpdate(data) {
            return data?.concat([{ id: "" + Math.random(), title: "New Title" }]);
          },
        },
      );
      // yay, the API call worked!
      toast.style = Toast.Style.Success;
      toast.title = "Note created";
    } catch (err) {
      // oh, the API call didn't work :(
      // the data will automatically be rolled back to its previous value
      toast.style = Toast.Style.Failure;
      toast.title = "Could not create Note";
      toast.message = err.message;
    }
  };

  return (
    <List isLoading={isLoading}>
      {(data || []).map((item) => (
        <List.Item
          key={item.id}
          title={item.title}
          actions={
            <ActionPanel>
              <Action title="Create new Note" onAction={() => createNewNote()} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
```

## Types

### AsyncState

An object corresponding to the execution state of the function.

```ts
// Initial State
{
  isLoading: true, // or `false` if `options.execute` is `false`
  data: undefined,
  error: undefined
}

// Success State
{
  isLoading: false,
  data: T,
  error: undefined
}

// Error State
{
  isLoading: false,
  data: undefined,
  error: Error
}

// Reloading State
{
  isLoading: true,
  data: T | undefined,
  error: Error | undefined
}
```

### MutatePromise

A method to wrap an asynchronous update and gives some control about how the `useSQL`'s data should be updated while the update is going through.

```ts
export type MutatePromise<T> = (
  asyncUpdate?: Promise<any>,
  options?: {
    optimisticUpdate?: (data: T) => T;
    rollbackOnError?: boolean | ((data: T) => T);
    shouldRevalidateAfter?: boolean;
  },
) => Promise<any>;
```


# `useStreamJSON`

Hook which takes a `http://`, `https://` or `file:///` URL pointing to a JSON resource, caches it to the command's support folder, and streams through its content. Useful when dealing with large JSON arrays which would be too big to fit in the command's memory.

## Signature

```ts
export function useStreamJSON<T, U>(
  url: RequestInfo,
  options: RequestInit & {
    filter?: (item: T) => boolean;
    transform?: (item: any) => T;
    pageSize?: number;
    initialData?: U;
    keepPreviousData?: boolean;
    execute?: boolean;
    onError?: (error: Error) => void;
    onData?: (data: T) => void;
    onWillExecute?: (args: [string, RequestInit]) => void;
    failureToastOptions?: Partial<Pick<Toast.Options, "title" | "primaryAction" | "message">>;
  },
): AsyncState<Result<T>> & {
  revalidate: () => void;
};
```

### Arguments

- `url` - The [`RequestInfo`](https://github.com/nodejs/undici/blob/v5.7.0/types/fetch.d.ts#L12) describing the resource that needs to be fetched. Strings starting with `http://`, `https://` and `Request` objects will use `fetch`, while strings starting with `file:///` will be copied to the cache folder.

With a few options:

- `options` extends [`RequestInit`](https://github.com/nodejs/undici/blob/v5.7.0/types/fetch.d.ts#L103-L117) allowing you to specify a body, headers, etc. to apply to the request.
- `options.pageSize` the amount of items to fetch at a time. By default, 20 will be used
- `options.dataPath` is a string or regular expression informing the hook that the array (or arrays) of data you want to stream through is wrapped inside one or multiple objects, and it indicates the path it needs to take to get to it.
- `options.transform` is a function called with each top-level object encountered while streaming. If the function returns an array, the hook will end up streaming through its children, and each array item will be passed to `options.filter`. If the function returns something other than an array, _it_ will be passed to `options.filter`. Note that the hook will revalidate every time the filter function changes, so you need to use [useCallback](https://react.dev/reference/react/useCallback) to make sure it only changes when it needs to.
- `options.filter` is a function called with each object encountered while streaming. If it returns `true`, the object will be kept, otherwise it will be discarded. Note that the hook will revalidate every time the filter function changes, so you need to use [useCallback](https://react.dev/reference/react/useCallback) to make sure it only changes when it needs to.

Including the useCachedPromise's options:

- `options.keepPreviousData` is a boolean to tell the hook to keep the previous results instead of returning the initial value if there aren't any in the cache for the new arguments. This is particularly useful when used for data for a List to avoid flickering.

Including the useCachedState's options:

- `options.initialData` is the initial value of the state if there aren't any in the Cache yet.

Including the usePromise's options:

- `options.execute` is a boolean to indicate whether to actually execute the function or not. This is useful for cases where one of the function's arguments depends on something that might not be available right away (for example, depends on some user inputs). Because React requires every hook to be defined on the render, this flag enables you to define the hook right away but wait until you have all the arguments ready to execute the function.
- `options.onError` is a function called when an execution fails. By default, it will log the error and show a generic failure toast with an action to retry.
- `options.onData` is a function called when an execution succeeds.
- `options.onWillExecute` is a function called when an execution will start.
- `options.failureToastOptions` are the options to customize the title, message, and primary action of the failure toast.

### Return

Returns an object with the AsyncState corresponding to the execution of the fetch as well as a couple of methods to manipulate it.

- `data`, `error`, `isLoading` - see AsyncState.
- `pagination` - the pagination object that Raycast [`List`s](https://developers.raycast.com/api-reference/user-interface/list#props) and [`Grid`s](https://developers.raycast.com/api-reference/user-interface/grid#props) expect.
- `revalidate` is a method to manually call the function with the same arguments again.
- `mutate` is a method to wrap an asynchronous update and gives some control over how the hook's data should be updated while the update is going through. By default, the data will be revalidated (eg. the function will be called again) after the update is done. See Mutation and Optimistic Updates for more information.

## Example

```ts
import { Action, ActionPanel, List, environment } from "@raycast/api";
import { useStreamJSON } from "@raycast/utils";
import { join } from "path";
import { useCallback, useState } from "react";

type Formula = { name: string; desc?: string };

export default function Main(): React.JSX.Element {
  const [searchText, setSearchText] = useState("");

  const formulaFilter = useCallback(
    (item: Formula) => {
      if (!searchText) return true;
      return item.name.toLocaleLowerCase().includes(searchText);
    },
    [searchText],
  );

  const formulaTransform = useCallback((item: any): Formula => {
    return { name: item.name, desc: item.desc };
  }, []);

  const { data, isLoading, pagination } = useStreamJSON("https://formulae.brew.sh/api/formula.json", {
    initialData: [] as Formula[],
    pageSize: 20,
    filter: formulaFilter,
    transform: formulaTransform
  });

  return (
    <List isLoading={isLoading} pagination={pagination} onSearchTextChange={setSearchText}>
      <List.Section title="Formulae">
        {data.map((d) => (
          <List.Item key={d.name} title={d.name} subtitle={d.desc} />
        ))}
      </List.Section>
    </List>
  );
}
```

## Mutation and Optimistic Updates

In an optimistic update, the UI behaves as though a change was successfully completed before receiving confirmation from the server that it was - it is being optimistic that it will eventually get the confirmation rather than an error. This allows for a more responsive user experience.

You can specify an `optimisticUpdate` function to mutate the data in order to reflect the change introduced by the asynchronous update.

When doing so, you can specify a `rollbackOnError` function to mutate back the data if the asynchronous update fails. If not specified, the data will be automatically rolled back to its previous value (before the optimistic update).

```tsx
import { Action, ActionPanel, List, environment } from "@raycast/api";
import { useStreamJSON } from "@raycast/utils";
import { join } from "path";
import { useCallback, useState } from "react";
import { setTimeout } from "timers/promises";

type Formula = { name: string; desc?: string };

export default function Main(): React.JSX.Element {
  const [searchText, setSearchText] = useState("");

  const formulaFilter = useCallback(
    (item: Formula) => {
      if (!searchText) return true;
      return item.name.toLocaleLowerCase().includes(searchText);
    },
    [searchText],
  );

  const formulaTransform = useCallback((item: any): Formula => {
    return { name: item.name, desc: item.desc };
  }, []);

  const { data, isLoading, mutate, pagination } = useStreamJSON("https://formulae.brew.sh/api/formula.json", {
    initialData: [] as Formula[],
    pageSize: 20,
    filter: formulaFilter,
    transform: formulaTransform,
  });

  return (
    <List isLoading={isLoading} pagination={pagination} onSearchTextChange={setSearchText}>
      <List.Section title="Formulae">
        {data.map((d) => (
          <List.Item
            key={d.name}
            title={d.name}
            subtitle={d.desc}
            actions={
              <ActionPanel>
                <Action
                  title="Delete All Items But This One"
                  onAction={async () => {
                    mutate(setTimeout(1000), {
                      optimisticUpdate: () => {
                        return [d];
                      },
                    });
                  }}
                />
              </ActionPanel>
            }
          />
        ))}
      </List.Section>
    </List>
  );
}
```

## Types

### AsyncState

An object corresponding to the execution state of the function.

```ts
// Initial State
{
  isLoading: true, // or `false` if `options.execute` is `false`
  data: undefined,
  error: undefined
}

// Success State
{
  isLoading: false,
  data: T,
  error: undefined
}

// Error State
{
  isLoading: false,
  data: undefined,
  error: Error
}

// Reloading State
{
  isLoading: true,
  data: T | undefined,
  error: Error | undefined
}
```

