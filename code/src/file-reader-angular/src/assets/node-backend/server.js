const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');

const app = express();
app.use(cors());

app.get('/files', (req, res) => {
    const directoryPath = path.join(__dirname, '../');
    fs.readdir(directoryPath, (err, files) => {
        if (err) {
            return res.status(500).send('Unable to scan directory');
        }
        res.json({ files });
    });
});

app.listen(3000, () => console.log('Server running on port 3000'));
