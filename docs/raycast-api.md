# Raycast Extension Development Documentation

## Overview

Raycast extensions are built with React, TypeScript, and Node.js, providing a powerful platform for creating productivity tools with beautiful native UI components.

## Requirements

- **Raycast**: Version 1.26.0+
- **Node.js**: Version 22.14+ (recommended: use nvm)
- **npm**: Version 7+
- **TypeScript & React knowledge**

## Getting Started

### 1. Create Your First Extension

```bash
# Open Raycast and run:
Create Extension

# Or via CLI:
npx create-raycast-extension
```

Follow the prompts:
- Extension name (e.g., "AI Assistant")
- Template selection (choose based on UI needs)
- Parent folder location

### 2. Project Structure

```
my-extension/
├── src/
│   ├── index.tsx          # Main command file
│   ├── utils.ts           # Helper functions
│   └── types.ts           # TypeScript definitions
├── assets/
│   └── icon.png           # Extension icon
├── package.json           # Node.js dependencies
├── package-lock.json      # Locked dependencies
├── tsconfig.json          # TypeScript config
└── README.md              # Documentation
```

### 3. Package.json Configuration

```json
{
  "name": "ai-assistant",
  "title": "AI Assistant",
  "description": "AI that controls your computer",
  "icon": "icon.png",
  "author": "your-name",
  "categories": ["Productivity", "Developer Tools"],
  "license": "MIT",
  "commands": [
    {
      "name": "assistant",
      "title": "AI Assistant",
      "subtitle": "Chat with AI",
      "description": "Open the AI assistant",
      "mode": "view"
    }
  ],
  "dependencies": {
    "@raycast/api": "^1.83.2",
    "@raycast/utils": "^1.17.0"
  },
  "devDependencies": {
    "@raycast/eslint-config": "^1.0.11",
    "@types/node": "22.14.0",
    "@types/react": "18.3.3",
    "eslint": "^8.57.0",
    "prettier": "^3.3.3",
    "react": "^18.3.1",
    "typescript": "^5.5.4"
  },
  "scripts": {
    "build": "ray build --skip-types -e dist -o dist",
    "dev": "ray develop",
    "fix-lint": "ray lint --fix",
    "lint": "ray lint",
    "prepublishOnly": "echo 'Do not publish to npm'"
  }
}
```

## Development Workflow

### Running in Development

```bash
# Install dependencies
npm install

# Start development mode with hot reload
npm run dev

# The extension appears in Raycast root search
```

### Building for Production

```bash
# Create distribution build
npm run build

# Lint code
npm run lint

# Fix linting issues
npm run fix-lint
```

## UI Components

### List Component

Display searchable lists of items:

```typescript
import { List, ActionPanel, Action, Icon } from "@raycast/api";
import { useState } from "react";

export default function Command() {
  const [searchText, setSearchText] = useState("");

  return (
    <List
      searchText={searchText}
      onSearchTextChange={setSearchText}
      searchBarPlaceholder="Search items..."
      isLoading={false}
      throttle={true}
    >
      <List.Section title="Results" subtitle="3 items">
        <List.Item
          title="Item Title"
          subtitle="Item description"
          icon={Icon.Document}
          accessories={[
            { text: "Label", icon: Icon.Tag },
            { date: new Date() }
          ]}
          actions={
            <ActionPanel>
              <Action.CopyToClipboard
                title="Copy"
                content="item content"
              />
            </ActionPanel>
          }
        />
      </List.Section>
    </List>
  );
}
```

### Form Component

Create forms for user input:

```typescript
import {
  Form,
  ActionPanel,
  Action,
  showToast,
  Toast,
  popToRoot
} from "@raycast/api";
import { useState } from "react";

interface FormValues {
  title: string;
  description: string;
  priority: string;
  dueDate?: Date;
}

export default function Command() {
  const [isLoading, setIsLoading] = useState(false);

  async function handleSubmit(values: FormValues) {
    setIsLoading(true);
    try {
      // Process form data
      await processData(values);
      await showToast({
        style: Toast.Style.Success,
        title: "Success",
        message: "Form submitted"
      });
      await popToRoot();
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Error",
        message: String(error)
      });
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <Form
      isLoading={isLoading}
      actions={
        <ActionPanel>
          <Action.SubmitForm
            title="Submit"
            onSubmit={handleSubmit}
          />
        </ActionPanel>
      }
    >
      <Form.TextField
        id="title"
        title="Title"
        placeholder="Enter title"
        error="Title is required"
        storeValue
      />
      <Form.TextArea
        id="description"
        title="Description"
        placeholder="Enter description"
        enableMarkdown
      />
      <Form.Dropdown
        id="priority"
        title="Priority"
        defaultValue="medium"
      >
        <Form.Dropdown.Item value="low" title="Low" />
        <Form.Dropdown.Item value="medium" title="Medium" />
        <Form.Dropdown.Item value="high" title="High" />
      </Form.Dropdown>
      <Form.DatePicker
        id="dueDate"
        title="Due Date"
        type={Form.DatePicker.Type.Date}
      />
    </Form>
  );
}
```

### Detail Component

Display rich content with markdown:

```typescript
import { Detail, ActionPanel, Action } from "@raycast/api";

export default function Command() {
  const markdown = `
# Title

## Features
- Feature 1
- Feature 2

\`\`\`typescript
const code = "example";
\`\`\`

![Image](https://example.com/image.png)
  `;

  return (
    <Detail
      markdown={markdown}
      isLoading={false}
      navigationTitle="Details"
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.Label title="Author" text="John Doe" />
          <Detail.Metadata.TagList title="Tags">
            <Detail.Metadata.TagList.Item text="TypeScript" />
            <Detail.Metadata.TagList.Item text="React" />
          </Detail.Metadata.TagList>
          <Detail.Metadata.Separator />
          <Detail.Metadata.Link
            title="Documentation"
            target="https://developers.raycast.com"
            text="View Docs"
          />
        </Detail.Metadata>
      }
      actions={
        <ActionPanel>
          <Action.OpenInBrowser url="https://raycast.com" />
        </ActionPanel>
      }
    />
  );
}
```

### Grid Component

Display items in a grid layout:

```typescript
import { Grid, ActionPanel, Action } from "@raycast/api";

export default function Command() {
  return (
    <Grid
      columns={5}
      fit={Grid.Fit.Fill}
      aspectRatio="1"
      searchBarPlaceholder="Search items..."
    >
      <Grid.Item
        title="Item"
        subtitle="Description"
        content={{
          type: "image",
          source: "https://example.com/image.png"
        }}
        actions={
          <ActionPanel>
            <Action.CopyToClipboard content="item" />
          </ActionPanel>
        }
      />
    </Grid>
  );
}
```

## Storage API

### LocalStorage

Persist data locally with encryption:

```typescript
import { LocalStorage } from "@raycast/api";

// Save data
await LocalStorage.setItem("user-preferences", JSON.stringify({
  theme: "dark",
  language: "en"
}));

// Retrieve data
const stored = await LocalStorage.getItem<string>("user-preferences");
const preferences = stored ? JSON.parse(stored) : {};

// Remove data
await LocalStorage.removeItem("user-preferences");

// Get all items
const allItems = await LocalStorage.allItems();

// Clear all data
await LocalStorage.clear();
```

### Cache

Temporary data storage:

```typescript
import { Cache } from "@raycast/api";

const cache = new Cache();

// Set with TTL (in milliseconds)
cache.set("api-response", JSON.stringify(data), {
  ttl: 1000 * 60 * 5 // 5 minutes
});

// Get cached data
const cached = cache.get("api-response");
const data = cached ? JSON.parse(cached) : null;

// Remove from cache
cache.remove("api-response");

// Clear cache
cache.clear();
```

## Preferences API

### Extension Preferences

Define in package.json:

```json
{
  "preferences": [
    {
      "name": "apiKey",
      "title": "API Key",
      "description": "Your API key",
      "type": "password",
      "required": true
    },
    {
      "name": "model",
      "title": "Model",
      "type": "dropdown",
      "data": [
        { "title": "GPT-4", "value": "gpt-4" },
        { "title": "GPT-3.5", "value": "gpt-3.5-turbo" }
      ],
      "default": "gpt-3.5-turbo",
      "required": false
    },
    {
      "name": "autoSave",
      "title": "Auto Save",
      "type": "checkbox",
      "label": "Enable auto-save",
      "default": true,
      "required": false
    }
  ]
}
```

### Accessing Preferences

```typescript
import { getPreferenceValues, openExtensionPreferences } from "@raycast/api";

interface Preferences {
  apiKey: string;
  model: string;
  autoSave: boolean;
}

export default function Command() {
  const preferences = getPreferenceValues<Preferences>();

  // Use preferences
  console.log(preferences.apiKey);

  // Open preferences UI
  await openExtensionPreferences();
}
```

## Actions & Keyboard Shortcuts

### Action Types

```typescript
import { ActionPanel, Action, Keyboard } from "@raycast/api";

<ActionPanel>
  <ActionPanel.Section title="Actions">
    <Action
      title="Custom Action"
      icon={Icon.Star}
      onAction={() => console.log("Action triggered")}
      shortcut={{ modifiers: ["cmd"], key: "k" }}
    />

    <Action.CopyToClipboard
      title="Copy"
      content="text to copy"
      shortcut={{ modifiers: ["cmd"], key: "c" }}
    />

    <Action.OpenInBrowser
      title="Open in Browser"
      url="https://raycast.com"
    />

    <Action.Push
      title="Show Details"
      target={<DetailView />}
      shortcut={{ modifiers: ["cmd"], key: "d" }}
    />

    <Action.SubmitForm
      title="Submit"
      onSubmit={(values) => handleSubmit(values)}
    />
  </ActionPanel.Section>
</ActionPanel>
```

### Keyboard Shortcuts

```typescript
const shortcuts = {
  primary: { modifiers: ["cmd"], key: "return" },
  secondary: { modifiers: ["cmd", "shift"], key: "return" },
  delete: { modifiers: ["cmd"], key: "delete" },
  refresh: { modifiers: ["cmd"], key: "r" },
  copy: { modifiers: ["cmd"], key: "c" },
  paste: { modifiers: ["cmd"], key: "v" }
};
```

## Hooks & Utilities

### usePromise Hook

Handle async operations:

```typescript
import { usePromise } from "@raycast/utils";

function MyComponent() {
  const { isLoading, data, error, revalidate } = usePromise(
    async (searchText: string) => {
      return await fetchData(searchText);
    },
    ["initial search"],
    {
      keepPreviousData: true,
      initialData: [],
      onError: (error) => {
        console.error(error);
      }
    }
  );

  if (error) return <Detail markdown={`Error: ${error.message}`} />;
  if (isLoading) return <List isLoading={true} />;

  return <List>{/* Render data */}</List>;
}
```

### useCachedPromise Hook

Cache async results:

```typescript
import { useCachedPromise } from "@raycast/utils";

function MyComponent() {
  const { isLoading, data, error } = useCachedPromise(
    async (query: string) => {
      const response = await fetch(`/api/search?q=${query}`);
      return response.json();
    },
    ["search query"],
    {
      cacheKey: "search-results",
      ttl: 1000 * 60 * 5, // 5 minutes
      failureToastOptions: {
        title: "Failed to fetch"
      }
    }
  );
}
```

### useForm Hook

Manage form state:

```typescript
import { useForm } from "@raycast/utils";

interface FormValues {
  name: string;
  email: string;
}

function MyForm() {
  const { handleSubmit, itemProps, values, reset } = useForm<FormValues>({
    initialValues: {
      name: "",
      email: ""
    },
    validation: {
      name: (value) => {
        if (!value) return "Name is required";
        if (value.length < 2) return "Too short";
      },
      email: (value) => {
        if (!value) return "Email is required";
        if (!value.includes("@")) return "Invalid email";
      }
    },
    onSubmit: async (values) => {
      await saveData(values);
      reset();
    }
  });

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm onSubmit={handleSubmit} />
        </ActionPanel>
      }
    >
      <Form.TextField {...itemProps.name} title="Name" />
      <Form.TextField {...itemProps.email} title="Email" />
    </Form>
  );
}
```

## Navigation

### Push & Pop Navigation

```typescript
import {
  ActionPanel,
  Action,
  pushToPage,
  popToPage,
  popToRoot
} from "@raycast/api";

// Push new view
<Action.Push
  title="Show Details"
  target={<DetailView item={item} />}
/>

// Or programmatically
await pushToPage(<DetailView item={item} />);

// Pop to previous
await popToPage();

// Pop to root
await popToRoot();
```

### Navigation Context

```typescript
import { useNavigation } from "@raycast/api";

function MyComponent() {
  const { push, pop } = useNavigation();

  return (
    <List>
      <List.Item
        title="Item"
        actions={
          <ActionPanel>
            <Action
              title="Details"
              onAction={() => push(<Details />)}
            />
            <Action
              title="Back"
              onAction={() => pop()}
            />
          </ActionPanel>
        }
      />
    </List>
  );
}
```

## Toast Notifications

```typescript
import { showToast, Toast, showHUD } from "@raycast/api";

// Success toast
await showToast({
  style: Toast.Style.Success,
  title: "Success",
  message: "Operation completed",
  primaryAction: {
    title: "Undo",
    onAction: () => console.log("Undo")
  }
});

// Loading toast
const toast = await showToast({
  style: Toast.Style.Animated,
  title: "Loading..."
});

// Update toast
toast.style = Toast.Style.Success;
toast.title = "Done!";

// HUD notification (brief message)
await showHUD("Copied to clipboard");
```

## Alert Dialogs

```typescript
import { confirmAlert, Alert, Icon } from "@raycast/api";

const confirmed = await confirmAlert({
  title: "Are you sure?",
  message: "This action cannot be undone",
  icon: Icon.Trash,
  primaryAction: {
    title: "Delete",
    style: Alert.ActionStyle.Destructive
  },
  dismissAction: {
    title: "Cancel"
  }
});

if (confirmed) {
  // Perform deletion
}
```

## Environment & Paths

```typescript
import { environment, getSelectedFinderItems } from "@raycast/api";
import path from "path";

// Extension paths
const extensionPath = environment.assetsPath;
const supportPath = environment.supportPath;
const isDevelopment = environment.isDevelopment;
const commandName = environment.commandName;
const commandMode = environment.commandMode;

// Get selected Finder items
const selectedItems = await getSelectedFinderItems();
for (const item of selectedItems) {
  console.log(item.path);
}
```

## OAuth Integration

```typescript
import { OAuth } from "@raycast/api";

const client = new OAuth.PKCEClient({
  redirectMethod: OAuth.RedirectMethod.Web,
  providerName: "GitHub",
  providerIcon: Icon.GitHub,
  providerId: "github",
  description: "Connect your GitHub account"
});

// Authorize
const authRequest = await client.authorizationRequest({
  endpoint: "https://github.com/login/oauth/authorize",
  clientId: "your-client-id",
  scope: "repo user"
});

const { authorizationCode } = await client.authorize(authRequest);

// Exchange for token
const tokens = await client.exchangeAuthorizationCode({
  code: authorizationCode,
  endpoint: "https://github.com/login/oauth/access_token",
  clientId: "your-client-id",
  clientSecret: "your-client-secret"
});
```

## AI Integration

```typescript
import { AI } from "@raycast/api";

// Check if available
if (!AI.isAvailable()) {
  throw new Error("AI not available");
}

// Ask AI
const answer = await AI.ask("Explain quantum computing");

// Stream response
const stream = AI.stream("Write a poem about coding");
stream.on("data", (data) => {
  console.log(data);
});
```

## Menu Bar Extensions

Create menu bar commands:

```json
{
  "commands": [
    {
      "name": "menubar",
      "title": "Menu Bar Item",
      "mode": "menu-bar",
      "interval": "10m"
    }
  ]
}
```

```typescript
import { MenuBarExtra, open } from "@raycast/api";

export default function Command() {
  return (
    <MenuBarExtra icon="🔔" tooltip="Notifications">
      <MenuBarExtra.Section>
        <MenuBarExtra.Item
          title="Open Dashboard"
          onAction={() => open("https://dashboard.com")}
        />
      </MenuBarExtra.Section>
    </MenuBarExtra>
  );
}
```

## Window Management

```typescript
import {
  getFrontmostApplication,
  getApplications,
  showInFinder,
  open,
  closeMainWindow
} from "@raycast/api";

// Get frontmost app
const app = await getFrontmostApplication();
console.log(app.name, app.bundleId);

// Get all apps
const apps = await getApplications();

// Show file in Finder
await showInFinder("/path/to/file");

// Open URL or file
await open("https://raycast.com");
await open("/path/to/file");

// Close Raycast window
await closeMainWindow();
```

## Error Handling

```typescript
import { showToast, Toast } from "@raycast/api";

try {
  // Risky operation
  await riskyOperation();
} catch (error) {
  console.error("Operation failed:", error);

  await showToast({
    style: Toast.Style.Failure,
    title: "Error",
    message: error instanceof Error ? error.message : "Unknown error",
    primaryAction: {
      title: "Retry",
      onAction: () => retryOperation()
    }
  });
}
```

## Testing

```typescript
// Use @raycast/api mock
jest.mock("@raycast/api", () => ({
  List: jest.fn(),
  showToast: jest.fn(),
  getPreferenceValues: jest.fn(() => ({
    apiKey: "test-key"
  }))
}));

// Test component
import { render } from "@testing-library/react";
import Command from "./index";

test("renders without crashing", () => {
  const { getByText } = render(<Command />);
  expect(getByText("Loading...")).toBeInTheDocument();
});
```

## Store Submission

### Prerequisites

1. **Build and test**: `npm run build`
2. **Lint check**: `npm run lint`
3. **Icon**: 512x512px PNG
4. **Screenshots**: At least 2
5. **README**: Clear documentation

### Manifest Requirements

```json
{
  "name": "extension-name",
  "title": "Extension Title",
  "description": "Clear description under 160 characters",
  "icon": "icon.png",
  "author": "username",
  "categories": ["Productivity"],
  "license": "MIT",
  "contributors": ["user1", "user2"],
  "keywords": ["keyword1", "keyword2"]
}
```

### Review Guidelines

- No external analytics
- Clear permission requests
- Proper error handling
- Responsive UI (< 1s load)
- Follow Raycast design patterns
- No duplicate functionality

### Publishing Process

```bash
# 1. Build for production
npm run build

# 2. Publish to store
npx @raycast/api publish

# 3. Follow the prompts
```

## Best Practices

### 1. Performance

```typescript
// Use loading states
const [isLoading, setIsLoading] = useState(true);

// Implement pagination
const PAGE_SIZE = 20;
const [page, setPage] = useState(0);
const items = allItems.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE);

// Debounce search
import { useDebouncedCallback } from "use-debounce";

const debouncedSearch = useDebouncedCallback((text: string) => {
  performSearch(text);
}, 500);
```

### 2. User Experience

```typescript
// Provide feedback
await showToast({
  style: Toast.Style.Success,
  title: "Saved"
});

// Handle empty states
if (items.length === 0) {
  return (
    <List>
      <List.EmptyView
        icon={Icon.MagnifyingGlass}
        title="No Results"
        description="Try a different search term"
      />
    </List>
  );
}

// Progressive disclosure
<List.Item
  detail={
    <List.Item.Detail
      markdown={detailedInfo}
      isLoading={loadingDetails}
    />
  }
/>
```

### 3. Security

```typescript
// Never expose sensitive data in logs
console.log("API call made"); // ✅
console.log(`API key: ${apiKey}`); // ❌

// Validate user input
function sanitizeInput(input: string): string {
  return input.replace(/[<>]/g, "");
}

// Use secure storage for credentials
await LocalStorage.setItem("token", encrypt(token));
```

### 4. Accessibility

```typescript
// Provide clear labels
<Form.TextField
  id="email"
  title="Email Address"
  placeholder="john@example.com"
  info="We'll never share your email"
/>

// Use semantic icons
import { Icon } from "@raycast/api";

<List.Item
  icon={Icon.CheckCircle} // ✅
  // icon="✓" // ❌
/>
```

## Troubleshooting

### Common Issues

1. **Extension not appearing**: Check `npm run dev` is running
2. **Hot reload not working**: Restart dev server
3. **Preferences not saving**: Ensure correct types in manifest
4. **API calls failing**: Check network and error handling
5. **Performance issues**: Implement pagination and caching

### Debug Tips

```typescript
// Enable verbose logging
if (environment.isDevelopment) {
  console.log("Debug info:", data);
}

// Use debugger
debugger; // Pause execution

// Check environment
console.log({
  mode: environment.commandMode,
  command: environment.commandName,
  isDev: environment.isDevelopment
});
```

## Resources

- [Official Documentation](https://developers.raycast.com)
- [API Reference](https://developers.raycast.com/api-reference)
- [Extension Examples](https://github.com/raycast/extensions)
- [Discord Community](https://discord.gg/raycast)
- [Blog & Tutorials](https://raycast.com/blog)