# 🚀 Guide de Déploiement Baana Backend — VPS Ubuntu

## Prérequis sur le serveur
- Ubuntu 20.04+ ou Debian 11+
- Node.js 18+ (`curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs`)
- PostgreSQL (`sudo apt install postgresql postgresql-contrib`)
- PM2 (`npm install -g pm2`)
- Nginx (`sudo apt install nginx`)
- Certbot (`sudo snap install --classic certbot`)

## Étapes de déploiement

### 1. Cloner le projet sur le serveur
```bash
git clone https://github.com/maarley11/Application-mobile-E-Commerce.git /var/www/baana
cd /var/www/baana
npm install --production
```

### 2. Créer la base de données PostgreSQL
```bash
sudo -u postgres psql
CREATE USER baana_user WITH PASSWORD 'ton_mot_de_passe_fort';
CREATE DATABASE baana_db OWNER baana_user;
\q
```

### 3. Configurer le .env de production
```bash
cp .env .env.production
nano .env.production
# → Modifier : DB_PASSWORD, JWT_SECRET, WEBHOOK_SECRET, FIREBASE_PROJECT_ID
# → Modifier : PORT=5000, NODE_ENV=production
```

### 4. Initialiser la base de données
```bash
node src/seeders/init_seed.js
```

### 5. Lancer avec PM2
```bash
pm2 start ecosystem.config.js --env production
pm2 startup
pm2 save
```

### 6. Configurer Nginx
```bash
sudo cp nginx.conf.example /etc/nginx/sites-available/baana-api
sudo ln -s /etc/nginx/sites-available/baana-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 7. Générer le certificat SSL (HTTPS)
```bash
sudo certbot --nginx -d api.baana.sn
```

### 8. Vérifier que tout fonctionne
```bash
curl https://api.baana.sn/api/products
pm2 logs baana-api
```

## Commandes PM2 utiles
```bash
pm2 status          # État de l'app
pm2 logs baana-api  # Voir les logs en temps réel
pm2 restart baana-api  # Redémarrer après un git pull
pm2 monit           # Dashboard de monitoring
```

## Mettre à jour l'application en production
```bash
cd /var/www/baana
git pull origin main
npm install --production
pm2 restart baana-api
```
