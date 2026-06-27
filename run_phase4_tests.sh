#!/usr/bin/env bash
set -e

# Start server in background
npm run dev > server.log 2>&1 &
SERVER_PID=$!
# Give DB time to sync
echo "Waiting for server to start..."
sleep 5

# Helper function for curl POST with JSON
curl_json() {
  METHOD=$1
  URL=$2
  DATA=$3
  curl -s -X "$METHOD" "$URL" -H "Content-Type: application/json" -d "$DATA"
}

# 1. Register normal user
echo "=== REGISTER USER ==="
curl_json POST http://localhost:3000/api/auth/register '{"phone":"+221123456789","name":"Test User"}'

# 2. Verify OTP & capture token
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/verify-otp -H "Content-Type: application/json" -d '{"phone":"+221123456789","otpCode":"1234"}' | jq -r .token)
echo "TOKEN=$TOKEN"

# 3. List notifications (should be empty)
echo "=== NOTIFICATIONS (empty) ==="
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/notifications | jq .

# 4. Rate‑limit test (6 attempts)
echo "=== RATE LIMIT TEST ==="
for i in {1..6}; do
  CODE=$(curl -o /dev/null -s -w "%{http_code}" -X POST http://localhost:3000/api/auth/register -H "Content-Type: application/json" -d '{"phone":"+221999999999","name":"Fake"}')
  echo "Attempt $i → HTTP $CODE"
done

# 5. Product search (pagination) – empty DB now
echo "=== PRODUCT SEARCH ==="
curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:3000/api/products?page=1&limit=5" | jq .

# 6. PATCH order status without admin (should be 403)
echo "=== PATCH STATUS (no admin) ==="
curl -s -X PATCH http://localhost:3000/api/orders/1/status -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"status":"SHIPPING"}' | jq .

# 7. Create admin user & promote via SQLite
curl_json POST http://localhost:3000/api/auth/register '{"phone":"+221222222222","name":"Admin User"}'
ADMIN_TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/verify-otp -H "Content-Type: application/json" -d '{"phone":"+221222222222","otpCode":"1234"}' | jq -r .token)
# Promote to admin directly in DB
sqlite3 database.sqlite "UPDATE Users SET isAdmin = 1 WHERE phone = '+221222222222';"
# Refresh token after promotion
ADMIN_TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/verify-otp -H "Content-Type: application/json" -d '{"phone":"+221222222222","otpCode":"1234"}' | jq -r .token)

echo "ADMIN_TOKEN=$ADMIN_TOKEN"

# 8. Create a dummy order (requires at least one product, so we create one quickly)
# Create dummy product if none exists
PRODUCT_COUNT=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "http://localhost:3000/api/products?page=1&limit=1" | jq '.totalProducts')
if [ "$PRODUCT_COUNT" -eq 0 ]; then
  echo "Creating dummy product..."
  curl -s -X POST http://localhost:3000/api/products -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Dummy","publicPrice":100,"proPrice":80,"stock":10,"category":"Test"}' > /dev/null
fi
# Grab first product id
PRODUCT_ID=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "http://localhost:3000/api/products?page=1&limit=1" | jq -r '.products[0].id')
# Create order
ORDER_ID=$(curl -s -X POST http://localhost:3000/api/orders -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d "{\"paymentMethod\":\"WAVE\",\"items\":[{\"productId\":$PRODUCT_ID,\"quantity\":1}]}" | jq -r .order.id)

echo "Created order ID: $ORDER_ID"

# 9. Patch status as admin
echo "=== PATCH STATUS (admin) ==="
curl -s -X PATCH http://localhost:3000/api/orders/$ORDER_ID/status -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"status":"SHIPPING"}' | jq .

# 10. List notifications (should contain one)
echo "=== NOTIFICATIONS (after status) ==="
curl -s -H "Authorization: Bearer $ADMIN_TOKEN" http://localhost:3000/api/notifications | jq .

# 11. Mark all as read
echo "=== MARK ALL READ ==="
curl -s -X PATCH http://localhost:3000/api/notifications/read-all -H "Authorization: Bearer $ADMIN_TOKEN" | jq .

# 12. Run Jest test suite
echo "=== RUNNING JEST TESTS ==="
npm test

# Cleanup
kill $SERVER_PID || true
echo "Server stopped."
