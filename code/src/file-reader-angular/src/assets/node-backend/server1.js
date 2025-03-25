const express = require("express");
const fs = require("fs").promises;
const path = require("path");

const app = express();
const PORT = 3000; // Change if needed

// Function to read files in a folder
async function readFilesInFolder(folderPath) {
    try {
        await fs.access(folderPath);
        const files = await fs.readdir(folderPath);
        const contents = await Promise.all(
            files.map(file => fs.readFile(path.join(folderPath, file), "utf8"))
        );
        return contents;
    } catch (err) {
        console.error("Error reading files:", err);
        return [];
    }
}

// API Endpoint to get file contents
app.get("/read-files", async (req, res) => {
    const folderPath = path.resolve(__dirname, "./files"); // Adjust this path
    const contents = await readFilesInFolder(folderPath);
    res.json({ files: contents });
});

// Start server
app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
