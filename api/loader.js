import fs from "fs";
import path from "path";

export default function handler(req, res) {
    const { script } = req.query;

    if (!script) {
        return res.status(400).send("Missing script");
    }

    const file = path.join(process.cwd(), "scripts", `${script}.lua`);

    if (!fs.existsSync(file)) {
        return res.status(404).send("Script not found");
    }

    const code = fs.readFileSync(file, "utf8");

    res.setHeader("Content-Type", "text/plain");
    res.status(200).send(code);
}
