require('dotenv').config();
const app = require('./app');
const { sequelize } = require('./models');
const startCronJobs = require('./jobs/cronJobs');
const PORT = process.env.PORT || 3000;

sequelize.authenticate().then(() => {
  console.log('Database connected.');
  startCronJobs();
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}).catch((error) => {
  console.error('Unable to connect to the database:', error);
});
