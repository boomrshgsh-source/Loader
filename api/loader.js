export default function handler(req, res) {
    const info = {
        ip: req.headers["x-forwarded-for"] || "Unknown",
        userAgent: req.headers["user-agent"] || "None",
        referer: req.headers["referer"] || "None",
        host: req.headers["host"] || "None",
        method: req.method,
        headers: req.headers
    };

    res.setHeader("Content-Type", "application/json");
    res.status(200).send(JSON.stringify(info, null, 2));
}
