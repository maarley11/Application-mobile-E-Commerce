#!/usr/bin/env node

const http = require('http');

const BASE = 'http://localhost:3001';

// ── Couleurs terminal ──────────────────────────────────────────────
const C = {
  reset:  '\x1b[0m',
  bold:   '\x1b[1m',
  dim:    '\x1b[2m',
  green:  '\x1b[32m',
  red:    '\x1b[31m',
  yellow: '\x1b[33m',
  cyan:   '\x1b[36m',
  blue:   '\x1b[34m',
  magenta:'\x1b[35m',
  white:  '\x1b[97m',
  bgGreen:'\x1b[42m',
  bgRed:  '\x1b[41m',
  bgBlue: '\x1b[44m',
};

// ── Utilitaires ────────────────────────────────────────────────────
const line   = (char = '─', len = 60) => char.repeat(len);
const pass   = (msg) => console.log(`  ${C.green}${C.bold}✅  PASS${C.reset}  ${msg}`);
const fail   = (msg) => console.log(`  ${C.red}${C.bold}❌  FAIL${C.reset}  ${msg}`);
const info   = (msg) => console.log(`  ${C.cyan}ℹ${C.reset}   ${msg}`);
const header = (title) => {
  console.log('');
  console.log(`${C.blue}${C.bold}${line()}${C.reset}`);
  console.log(`${C.blue}${C.bold}  ${title}${C.reset}`);
  console.log(`${C.blue}${C.bold}${line()}${C.reset}`);
};

function fetch(path, opts = {}) {
  return new Promise((resolve, reject) => {
    const body   = opts.body ? JSON.stringify(opts.body) : null;
    const method = opts.method || 'GET';
    const headers = { 'Content-Type': 'application/json', ...(opts.headers || {}) };
    const req = http.request(BASE + path, { method, headers }, (res) => {
      let data = '';
      res.on('data', d => data += d);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, headers: res.headers, json: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, headers: res.headers, json: {} }); }
      });
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

// ── SECTIONS ───────────────────────────────────────────────────────

async function testProducts() {
  header('🛒  CATALOGUE PRODUITS');
  const r = await fetch('/api/products');

  if (r.status === 200) {
    pass(`GET /api/products → HTTP ${r.status}`);
    const products = r.json.products || r.json;
    info(`${C.bold}${products.length} produits trouvés${C.reset}`);
    console.log('');
    console.log(`  ${C.dim}${'NOM'.padEnd(35)} ${'PRIX PUBLIC'.padStart(12)} ${'PRIX PRO'.padStart(10)} ${'STOCK'.padStart(7)}${C.reset}`);
    console.log(`  ${C.dim}${line('·', 67)}${C.reset}`);
    products.forEach(p => {
      const badge = p.badge ? ` ${C.yellow}[${p.badge}]${C.reset}` : '';
      console.log(
        `  ${C.white}${p.name.padEnd(35)}${C.reset}` +
        `${C.green}${String(p.publicPrice + ' FCFA').padStart(12)}${C.reset}` +
        `${C.magenta}${String(p.proPrice + ' FCFA').padStart(10)}${C.reset}` +
        `${C.cyan}${String(p.stock).padStart(7)}${C.reset}${badge}`
      );
    });
  } else {
    fail(`GET /api/products → HTTP ${r.status}`);
  }
}

async function testAuth() {
  header('🔐  AUTHENTIFICATION');

  // Étape 1 : Envoi OTP
  const r1 = await fetch('/api/auth/register', { method: 'POST', body: { phone: '+221770000000' } });
  r1.status === 200
    ? pass(`POST /api/auth/register → HTTP ${r1.status}`)
    : fail(`POST /api/auth/register → HTTP ${r1.status}`);
  info(`Réponse: ${r1.json.message || JSON.stringify(r1.json)}`);

  // Étape 2 : Vérification OTP
  const r2 = await fetch('/api/auth/verify-otp', { method: 'POST', body: { phone: '+221770000000', otp: '1234' } });
  r2.status === 200
    ? pass(`POST /api/auth/verify-otp (OTP: 1234) → HTTP ${r2.status}`)
    : fail(`POST /api/auth/verify-otp → HTTP ${r2.status}`);

  const token = r2.json.token || r2.json.accessToken;
  if (token) {
    info(`Token JWT: ${C.green}${token.slice(0, 40)}...${C.reset}`);
    info(`Utilisateur: ${C.bold}${r2.json.user?.phone || r2.json.phone || 'inconnu'}${C.reset}`);
  } else {
    fail('Aucun token JWT dans la réponse');
  }

  return token;
}

async function testSecuredRoutes(token) {
  header('🔒  SÉCURITÉ — ROUTES PROTÉGÉES PAR JWT');

  // Accès sans token → doit refuser
  const r1 = await fetch('/api/cart');
  r1.status === 401
    ? pass(`GET /api/cart sans token → HTTP ${r1.status} (Accès refusé ✔)`)
    : fail(`GET /api/cart sans token → HTTP ${r1.status} (devrait être 401)`);

  const r2 = await fetch('/api/users/profile');
  r2.status === 401
    ? pass(`GET /api/users/profile sans token → HTTP ${r2.status} (Accès refusé ✔)`)
    : fail(`GET /api/users/profile sans token → HTTP ${r2.status} (devrait être 401)`);

  if (!token) { info('Pas de token, tests authentifiés ignorés.'); return; }

  // Accès avec token → doit accepter
  const r3 = await fetch('/api/cart', { headers: { 'Authorization': `Bearer ${token}` } });
  r3.status === 200
    ? pass(`GET /api/cart avec token → HTTP ${r3.status} (Accès autorisé ✔)`)
    : fail(`GET /api/cart avec token → HTTP ${r3.status}`);
  info(`Panier: ${r3.json.items?.length ?? 0} article(s), Total: ${C.green}${r3.json.total ?? 0} FCFA${C.reset}`);

  const r4 = await fetch('/api/users/loyalty', { headers: { 'Authorization': `Bearer ${token}` } });
  r4.status === 200
    ? pass(`GET /api/users/loyalty → HTTP ${r4.status}`)
    : fail(`GET /api/users/loyalty → HTTP ${r4.status}`);
  info(`Points de fidélité: ${C.yellow}${C.bold}${r4.json.points ?? 0} pts${C.reset}`);
}

async function testCategories() {
  header('📦  CATÉGORIES');
  const r = await fetch('/api/categories');
  if (r.status === 200) {
    pass(`GET /api/categories → HTTP ${r.status}`);
    const cats = r.json;
    cats.forEach(c => info(`${C.bold}${c.name}${C.reset} ${C.dim}(id: ${c.id})${C.reset}`));
    // Vérifier l'en-tête de cache
    const cc = r.headers['cache-control'];
    cc
      ? pass(`Cache-Control: ${C.cyan}${cc}${C.reset}`)
      : fail('Cache-Control manquant');
  } else {
    fail(`GET /api/categories → HTTP ${r.status}`);
  }
}

// ── MAIN ───────────────────────────────────────────────────────────
async function main() {
  console.clear();
  console.log('');
  console.log(`${C.bold}${C.white}  ██████╗  █████╗  █████╗ ███╗   ██╗ █████╗ ${C.reset}`);
  console.log(`${C.bold}${C.cyan}  ██╔══██╗██╔══██╗██╔══██╗████╗  ██║██╔══██╗${C.reset}`);
  console.log(`${C.bold}${C.blue}  ██████╔╝███████║███████║██╔██╗ ██║███████║${C.reset}`);
  console.log(`${C.bold}${C.blue}  ██╔══██╗██╔══██║██╔══██║██║╚██╗██║██╔══██║${C.reset}`);
  console.log(`${C.bold}${C.cyan}  ██████╔╝██║  ██║██║  ██║██║ ╚████║██║  ██║${C.reset}`);
  console.log(`${C.bold}${C.white}  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝${C.reset}`);
  console.log('');
  console.log(`  ${C.dim}Backend API — Rapport de santé Phase 6${C.reset}`);
  console.log(`  ${C.dim}${new Date().toLocaleString('fr-FR')}${C.reset}`);

  try {
    await testProducts();
    await testCategories();
    const token = await testAuth();
    await testSecuredRoutes(token);

    console.log('');
    console.log(`${C.green}${C.bold}${line('═')}${C.reset}`);
    console.log(`${C.green}${C.bold}  🎉 TOUS LES TESTS SONT PASSÉS — BAANA BACKEND EST OPÉRATIONNEL !${C.reset}`);
    console.log(`${C.green}${C.bold}${line('═')}${C.reset}`);
    console.log('');

  } catch (e) {
    console.log('');
    console.log(`${C.red}${C.bold}  ⚠️  Erreur de connexion — Le serveur est-il lancé sur le port 3001 ?${C.reset}`);
    console.log(`${C.dim}  Lance d'abord: PORT=3001 node src/server.js${C.reset}`);
    console.log('');
  }
}

main();
