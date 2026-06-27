#!/bin/bash

# =============================================================
# 🧪 SCRIPT DE TEST BACKEND — BAANA APP
# =============================================================
# Lance ce script APRÈS avoir démarré le serveur (node src/server.js)
# Usage : bash test_backend.sh
# =============================================================

BASE_URL="http://localhost:3000/api"
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "======================================================"
echo "   🚀 BAANA - Tests Backend Phase 6"
echo "======================================================"
echo ""

# --- Fonction utilitaire pour afficher les résultats ---
check_status() {
  local label=$1
  local http_code=$2
  local expected=$3
  if [ "$http_code" = "$expected" ]; then
    echo -e "  ${GREEN}✅ PASS${NC} — $label (HTTP $http_code)"
  else
    echo -e "  ${RED}❌ FAIL${NC} — $label (HTTP $http_code, attendu: $expected)"
  fi
}

# ============================================================
# TEST 1 : CATÉGORIES
# ============================================================
echo -e "${BLUE}📦 TEST 1 : Catégories${NC}"
CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/categories)
check_status "GET /api/categories" $CODE "200"
echo -e "  → Contenu :"
curl -s $BASE_URL/categories | python3 -c "
import sys, json
data = json.load(sys.stdin)
for c in data[:5]:
    print(f\"     - {c.get('name', c.get('id', '?'))}\")
" 2>/dev/null || curl -s $BASE_URL/categories | head -c 300
echo ""

# ============================================================
# TEST 2 : PRODUITS
# ============================================================
echo -e "${BLUE}🛒 TEST 2 : Produits${NC}"
CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/products)
check_status "GET /api/products" $CODE "200"

# Vérifier les en-têtes de cache (Innovation 5)
echo -e "  → En-têtes de cache :"
CACHE=$(curl -sI $BASE_URL/products | grep -i "cache-control")
ETAG=$(curl -sI $BASE_URL/products | grep -i "etag")
if [ -n "$CACHE" ]; then
  echo -e "  ${GREEN}✅ Cache-Control:${NC} $CACHE"
else
  echo -e "  ${RED}❌ Cache-Control manquant${NC}"
fi
if [ -n "$ETAG" ]; then
  echo -e "  ${GREEN}✅ ETag:${NC} $ETAG"
else
  echo -e "  ${RED}❌ ETag manquant${NC}"
fi

echo -e "  → Aperçu des produits :"
curl -s $BASE_URL/products | python3 -c "
import sys, json
data = json.load(sys.stdin)
products = data if isinstance(data, list) else data.get('products', data.get('data', []))
for p in products[:5]:
    name = p.get('name','?')
    pub = p.get('publicPrice', '?')
    pro = p.get('proPrice', '?')
    print(f'     - {name} | Prix public: {pub} FCFA | Prix pro: {pro} FCFA')
" 2>/dev/null || curl -s $BASE_URL/products | head -c 300
echo ""

# ============================================================
# TEST 3 : AUTHENTIFICATION — Register (envoi OTP)
# ============================================================
echo -e "${BLUE}🔐 TEST 3 : Authentification — Envoi OTP${NC}"
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone": "+221770000000"}')
REGISTER_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone": "+221770000000"}')
check_status "POST /api/auth/register (numéro de test)" $REGISTER_CODE "200"
echo -e "  → Réponse : $(echo $REGISTER_RESPONSE | head -c 150)"
echo ""

# ============================================================
# TEST 4 : AUTHENTIFICATION — Verify OTP (obtenir le token JWT)
# ============================================================
echo -e "${BLUE}🔑 TEST 4 : Authentification — Vérification OTP (1234)${NC}"
OTP_RESPONSE=$(curl -s -X POST $BASE_URL/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+221770000000", "otp": "1234"}')
OTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+221770000000", "otp": "1234"}')
check_status "POST /api/auth/verify-otp avec OTP 1234" $OTP_CODE "200"

# Extraire le token JWT
TOKEN=$(echo $OTP_RESPONSE | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('token', data.get('accessToken', data.get('jwt', ''))))" 2>/dev/null)
if [ -n "$TOKEN" ]; then
  echo -e "  ${GREEN}✅ Token JWT reçu :${NC} ${TOKEN:0:50}..."
else
  echo -e "  ${RED}❌ Aucun token JWT trouvé dans la réponse${NC}"
  echo -e "  → Réponse brute : $(echo $OTP_RESPONSE | head -c 300)"
fi
echo ""

# ============================================================
# TEST 5 : PROFIL UTILISATEUR (avec JWT)
# ============================================================
echo -e "${BLUE}👤 TEST 5 : Profil utilisateur (route protégée JWT)${NC}"
if [ -n "$TOKEN" ]; then
  PROFILE_CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/users/profile \
    -H "Authorization: Bearer $TOKEN")
  check_status "GET /api/users/profile" $PROFILE_CODE "200"
else
  echo -e "  ${YELLOW}⏭ Skipped — pas de token JWT disponible${NC}"
fi
echo ""

# ============================================================
# TEST 6 : POINTS DE FIDÉLITÉ (Innovation 3)
# ============================================================
echo -e "${BLUE}🌟 TEST 6 : Points de fidélité (Innovation 3)${NC}"
if [ -n "$TOKEN" ]; then
  LOYALTY_CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/users/loyalty \
    -H "Authorization: Bearer $TOKEN")
  LOYALTY_BODY=$(curl -s $BASE_URL/users/loyalty \
    -H "Authorization: Bearer $TOKEN")
  check_status "GET /api/users/loyalty" $LOYALTY_CODE "200"
  echo -e "  → Réponse : $(echo $LOYALTY_BODY | head -c 200)"
else
  echo -e "  ${YELLOW}⏭ Skipped — pas de token JWT disponible${NC}"
fi
echo ""

# ============================================================
# TEST 7 : PANIER (Innovation 1)
# ============================================================
echo -e "${BLUE}🛍️ TEST 7 : Panier serveur (Innovation 1)${NC}"
if [ -n "$TOKEN" ]; then
  CART_CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/cart \
    -H "Authorization: Bearer $TOKEN")
  CART_BODY=$(curl -s $BASE_URL/cart \
    -H "Authorization: Bearer $TOKEN")
  check_status "GET /api/cart" $CART_CODE "200"
  echo -e "  → Réponse : $(echo $CART_BODY | head -c 200)"
else
  echo -e "  ${YELLOW}⏭ Skipped — pas de token JWT disponible${NC}"
fi
echo ""

# ============================================================
# TEST 8 : HISTORIQUE COMMANDES
# ============================================================
echo -e "${BLUE}📜 TEST 8 : Historique des commandes${NC}"
if [ -n "$TOKEN" ]; then
  ORDERS_CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/orders/history \
    -H "Authorization: Bearer $TOKEN")
  check_status "GET /api/orders/history" $ORDERS_CODE "200"
else
  echo -e "  ${YELLOW}⏭ Skipped — pas de token JWT disponible${NC}"
fi
echo ""

# ============================================================
# TEST 9 : NOTIFICATIONS
# ============================================================
echo -e "${BLUE}🔔 TEST 9 : Notifications${NC}"
if [ -n "$TOKEN" ]; then
  NOTIF_CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/notifications \
    -H "Authorization: Bearer $TOKEN")
  check_status "GET /api/notifications" $NOTIF_CODE "200"
else
  echo -e "  ${YELLOW}⏭ Skipped — pas de token JWT disponible${NC}"
fi
echo ""

# ============================================================
# TEST 10 : DASHBOARD PRO
# ============================================================
echo -e "${BLUE}📊 TEST 10 : Dashboard Pro${NC}"
if [ -n "$TOKEN" ]; then
  DASH_CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/dashboard/stats \
    -H "Authorization: Bearer $TOKEN")
  check_status "GET /api/dashboard/stats" $DASH_CODE "200"
else
  echo -e "  ${YELLOW}⏭ Skipped — pas de token JWT disponible${NC}"
fi
echo ""

# ============================================================
# RÉSUMÉ
# ============================================================
echo "======================================================"
echo "   ✅ Tests terminés — Vérifie les résultats ci-dessus"
echo "======================================================"
echo ""
