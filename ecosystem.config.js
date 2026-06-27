/**
 * ecosystem.config.js — Configuration PM2 pour le déploiement en production
 *
 * Usage :
 *   pm2 start ecosystem.config.js          → Lancer l'app
 *   pm2 restart baana-api                  → Redémarrer
 *   pm2 logs baana-api                     → Voir les logs
 *   pm2 monit                              → Dashboard de monitoring
 *   pm2 startup && pm2 save               → Démarrage automatique au reboot serveur
 */

module.exports = {
  apps: [
    {
      name: 'baana-api',
      script: 'src/server.js',

      // Nombre d'instances (cluster mode pour la performance)
      // Mettre "max" pour utiliser tous les cœurs du serveur VPS
      instances: 1,
      exec_mode: 'fork',

      // Variables d'environnement de PRODUCTION
      // (à surcharger par le vrai .env sur le serveur)
      env_production: {
        NODE_ENV: 'production',
        PORT: 5000,
      },

      // Redémarrage automatique en cas de crash
      autorestart: true,
      watch: false,

      // Redémarre si l'app dépasse 512 Mo de RAM
      max_memory_restart: '512M',

      // Logs
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      error_file: './logs/pm2-error.log',
      out_file: './logs/pm2-out.log',
      merge_logs: true,
    },
  ],
};
