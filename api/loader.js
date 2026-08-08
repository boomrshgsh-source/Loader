import fs from "fs";
import path from "path";
import crypto from "crypto";

const SECRET_SALT = process.env.SECRET_SALT || "FallbackKey_If_Env_Missing";

export default function handler(req, res) {
    const ua = req.headers["user-agent"] || "";
    if (!/ROBLOX|RobloxApp/i.test(ua)) {
        return res.redirect(302, "https://fusions.info/boom_b");
    }
    const { script } = req.query;

    if (!script || !/^[a-zA-Z0-9_\/-]+$/.test(script)) {
        return res.status(400).send("Invalid Request");
    }

    if (script.includes("..")) {
        return res.status(400).send("Access Denied");
    }

    const filePath = path.join(process.cwd(), "scripts", `${script}.lua`);
    if (!fs.existsSync(filePath)) return res.status(404).send("Not Found");

    try {
        const rawScript = fs.readFileSync(filePath, "utf8");

        const timeBucket = Math.floor(Date.now() / 10000); 
        const validToken = crypto.createHash("md5").update(`${timeBucket}_${SECRET_SALT}`).digest("hex");

        const injectedHeader = `_G.__L_TOKEN = "${validToken}"; _G.__L_TIME = ${timeBucket};\n`;

        res.setHeader("Content-Type", "text/plain; charset=utf-8");
        res.setHeader("Cache-Control", "no-store");
        return res.status(200).send(injectedHeader + rawScript);
    } catch (e) {
        return res.status(500).send("Server Error");
    }
}
