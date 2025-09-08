const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const port = 80;

const pool = new Pool({
  host: 'db',
  user: 'postgres',
  password: 'postgres',
  database: 'votes',
  port: 5432,
});

app.use(express.static('public'));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/votes', async (req, res) => {
  try {
    const result = await pool.query('SELECT vote, COUNT(*) as count FROM votes GROUP BY vote');
    const votes = { Cats: 0, Dogs: 0 };
    
    result.rows.forEach(row => {
      votes[row.vote] = parseInt(row.count);
    });
    
    res.json(votes);
  } catch (err) {
    console.error(err);
    res.json({ Cats: 0, Dogs: 0 });
  }
});

app.listen(port, () => {
  console.log(`Results app listening on port ${port}`);
});