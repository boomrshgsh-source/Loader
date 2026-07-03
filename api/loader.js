import fs from "fs";
import path from "path";

export default function handler(req, res) {
    const ua = req.headers["user-agent"] || "";
    if (!/ROBLOX|RobloxApp/i.test(ua)) {
        return res.redirect(302, "https://mybioboom.vercel.app");
    }

    const { script } = req.query;

    if (!script) {
        return res.status(400).send("Missing script");
    }

    const file = path.join(process.cwd(), "scripts", `${script}.lua`);

    if (!fs.existsSync(file)) {
        return res.status(404).send("Script not found");
    }

    res.setHeader("Content-Type", "text/plain; charset=utf-8");
    res.send(fs.readFileSync(file, "utf8"));
}
