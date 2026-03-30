# FinanceFlix

A personal finance management app that automatically creates transactions from receipt emails using AI categorization. Built with a .NET 10 backend and Flutter mobile frontend.

## Features

- **Automated Email-to-Transaction** — Connect IMAP mailboxes and let the app listen for new emails via IMAP IDLE. Incoming receipts are parsed, categorized by a local LLM (Ollama), and turned into transactions automatically. Product images are extracted and attached.
- **Recurring Transactions** — Schedule repeating transactions (daily, weekly, bi-weekly, monthly, quarterly, yearly) with optional end dates. A background service executes them automatically.
- **Multi-Account Support** — Manage multiple financial accounts, each with its own balance, transactions, and mail inboxes.
- **Transaction Images** — Attach photos to transactions via the app or have them extracted automatically from emails.
- **AI Categorization** — Uses a local Ollama LLM to categorize transactions into: Income, Housing, Groceries, Transport, Entertainment, Health, Shopping, Savings, Other.
- **JWT Authentication** — Built-in auth with refresh token rotation, or plug in an external SSO provider.

## State of Development

This project is in active development. Current status:

- Account and transaction management (CRUD) — done
- AI-powered email-to-transaction pipeline — done
- Recurring transactions with automatic execution — done
- Authentication (built-in JWT + SSO support) — done
- Transaction image attachments (manual upload + email extraction) — done
- Dynamic mail inbox registration (listener starts immediately on add) — done
- Flutter mobile app with full feature parity — done

On Development:

- Transaction Search
- Dashboard for getting finance tipps
- Scanning Pictures for documents/receipts
- Selection of Databseoptions
- Better UI XD
- AI Optimization

## Getting Started

### Prerequisites
- [.NET 10 SDK](https://dotnet.microsoft.com/)
- [Flutter SDK](https://flutter.dev/)
- [Ollama](https://ollama.ai/) with `gemma3:4b` model (for AI features)
- PostgreSQL (production) or SQLite (development)

### Backend

```bash
cd FinanceFlix

dotnet restore
dotnet run
```

### Flutter App

```bash
cd app_financeflix

flutter pub get
flutter run
```

On first launch, enter the backend URL (e.g. `http://localhost:5000`), then register or log in.

### Docker

```bash
docker compose up
```

This starts the API and a PostgreSQL 17 instance.
