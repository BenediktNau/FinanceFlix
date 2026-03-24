#!/bin/bash
# Seed data script for FinanceFlix
# Usage: Start the app first (dotnet run), then run ./seed-data.sh

BASE_URL="http://localhost:3000"
EMAIL="demo@financeflix.com"
PASSWORD="Password123"

echo "=== Registering user ==="
curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}"
echo ""

echo ""
echo "=== Logging in ==="
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
echo "$LOGIN_RESPONSE"

TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"value":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "ERROR: Failed to get token. Is the app running on $BASE_URL?"
  exit 1
fi

AUTH="Authorization: Bearer $TOKEN"
echo ""
echo "Token acquired."

# --- Create Accounts ---
echo ""
echo "=== Creating Checking Account ==="
curl -s -X POST "$BASE_URL/account" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"accountName":"Girokonto","balance":2500.00}'
echo ""

echo ""
echo "=== Creating Savings Account ==="
curl -s -X POST "$BASE_URL/account" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"accountName":"Sparkonto","balance":10000.00}'
echo ""

# --- Fetch accounts to get IDs ---
echo ""
echo "=== Fetching accounts ==="
ACCOUNTS=$(curl -s "$BASE_URL/account" -H "$AUTH")
echo "$ACCOUNTS"

# Extract first two account IDs (simple parsing)
ACC1=$(echo "$ACCOUNTS" | grep -o '"accountId":[0-9]*' | head -1 | cut -d: -f2)
ACC2=$(echo "$ACCOUNTS" | grep -o '"accountId":[0-9]*' | tail -1 | cut -d: -f2)

echo ""
echo "Girokonto ID: $ACC1, Sparkonto ID: $ACC2"

# --- Transactions for Girokonto (checking) ---
# Categories: 0=Einkommen, 1=Wohnen, 2=Lebensmittel, 3=Transport, 4=Unterhaltung,
#             5=Gesundheit, 6=Shopping, 7=Sparen, 8=Sonstiges
echo ""
echo "=== Adding transactions to Girokonto ==="

# Salary deposit
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC1,\"amount\":3200.00,\"category\":0,\"date\":\"2026-03-01T00:00:00\"}"
echo " <- Gehalt (Einkommen)"

# Rent withdrawal
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC1,\"amount\":-850.00,\"category\":1,\"date\":\"2026-03-02T00:00:00\"}"
echo " <- Miete (Wohnen)"

# Groceries
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC1,\"amount\":-67.50,\"category\":2,\"date\":\"2026-03-05T00:00:00\"}"
echo " <- REWE Einkauf (Lebensmittel)"

curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC1,\"amount\":-42.30,\"category\":2,\"date\":\"2026-03-12T00:00:00\"}"
echo " <- Aldi Einkauf (Lebensmittel)"

# Transport
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC1,\"amount\":-49.00,\"category\":3,\"date\":\"2026-03-03T00:00:00\"}"
echo " <- Deutschlandticket (Transport)"

# Entertainment
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC1,\"amount\":-12.99,\"category\":4,\"date\":\"2026-03-07T00:00:00\"}"
echo " <- Netflix (Unterhaltung)"

# Health
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC1,\"amount\":-25.00,\"category\":5,\"date\":\"2026-03-10T00:00:00\"}"
echo " <- Apotheke (Gesundheit)"

# Shopping
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC1,\"amount\":-129.99,\"category\":6,\"date\":\"2026-03-15T00:00:00\"}"
echo " <- Amazon Bestellung (Shopping)"

# Transfer to savings
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC1,\"amount\":-500.00,\"category\":7,\"date\":\"2026-03-01T00:00:00\"}"
echo " <- Sparueberweisung (Sparen)"

# Misc
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC1,\"amount\":-15.00,\"category\":8,\"date\":\"2026-03-20T00:00:00\"}"
echo " <- Paketgebühr (Sonstiges)"

# --- Transactions for Sparkonto (savings) ---
echo ""
echo "=== Adding transactions to Sparkonto ==="

# Transfer from checking
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC2,\"amount\":500.00,\"category\":7,\"date\":\"2026-03-01T00:00:00\"}"
echo " <- Einzahlung vom Girokonto (Sparen)"

# Interest
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC2,\"amount\":12.50,\"category\":0,\"date\":\"2026-03-15T00:00:00\"}"
echo " <- Zinsen (Einkommen)"

# Emergency withdrawal
curl -s -X POST "$BASE_URL/transaction" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"accountId\":$ACC2,\"amount\":-200.00,\"category\":8,\"date\":\"2026-03-18T00:00:00\"}"
echo " <- Notfall-Abhebung (Sonstiges)"

echo ""
echo "=== Done! Seed data created. ==="
echo ""
echo "Login credentials:"
echo "  Email:    $EMAIL"
echo "  Password: $PASSWORD"
