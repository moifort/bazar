# Bazar

A smart household inventory app — scan your stuff, know where everything is.

## Features

- **AI scan** — photograph items, get names, categories and quantities automatically (Gemini 2.5 Flash vision)
- **Batch detection** — multiple items identified in a single photo
- **4-level location hierarchy** — place > room > zone > storage for precise organization
- **Dashboard** — total items, category breakdown, items per location, recent activity
- **Search & filter** — full-text search, filter by category or location, multiple sort options
- **16 item categories** — tools, electronics, kitchen, clothing, books, furniture, and more

## Tech Stack

| Layer | Stack |
|-------|-------|
| iOS | SwiftUI, Swift 6, iOS 26 |
| Backend | Nitro, TypeScript, Zod, file-based storage |
| AI | Gemini 2.5 Flash (vision) |

## Getting Started

### Backend

The server is available on Docker Hub at [moifort/bazar](https://hub.docker.com/r/moifort/bazar).

```yaml
services:
  bazar:
    image: moifort/bazar:latest
    container_name: bazar
    restart: unless-stopped
    environment:
      HOST: 0.0.0.0
      PORT: "3000"
      NITRO_API_TOKEN: "your-secret-token"
      NITRO_GOOGLE_API_KEY: "your-gemini-api-key"
    ports:
      - "3000:3000"
    volumes:
      - ./data:/app/.data
```

```bash
docker compose up -d
```

Or run locally with Bun:

```bash
cp .env.example .env  # then fill in your API keys
bun install
bun run dev
```

### iOS App

1. Copy the Secrets template:
   ```bash
   cp ios/Bazar/Shared/Secrets.swift.example ios/Bazar/Shared/Secrets.swift
   ```
2. Replace `YOUR-API-TOKEN-HERE` with your `NITRO_API_TOKEN` value
3. Open `ios/Bazar.xcodeproj` in Xcode, set the server URL in Settings, and run on your device
