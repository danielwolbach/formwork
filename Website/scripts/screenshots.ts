/**
 * Renders the App Store screenshots from the feature steps (src/pages/app-store) into app-store-screenshots/.
 * Run with `npm run screenshots`.
 */
import { mkdir } from "node:fs/promises";
import { dev } from "astro";
import { chromium } from "playwright";
import config from "../astro.config.mjs";

// 440×956 at 3× is 1320×2868, the 6.9" iPhone size App Store Connect requires.
const viewport = { width: 440, height: 956 };
const deviceScaleFactor = 3;
const schemes = ["light", "dark"] as const;
const outDir = "app-store-screenshots";
const locales = config.i18n?.locales as string[];

const server = await dev({ logLevel: "error", server: { port: 4399 } });
const browser = await chromium.launch();

try {
    const base = `http://localhost:${server.address.port}`;

    for (const scheme of schemes) {
        const page = await browser.newPage({ viewport, deviceScaleFactor, colorScheme: scheme });

        for (const locale of locales) {
            await mkdir(`${outDir}/${locale}`, { recursive: true });

            // Walk the steps until the page runs out of them.
            for (let step = 1; ; step++) {
                const response = await page.goto(`${base}/app-store/${locale}-${step}`, { waitUntil: "networkidle" });
                if (response?.status() === 404) break;
                if (!response?.ok()) throw new Error(`${response?.url()} returned ${response?.status()}`);

                await page.evaluate(() => document.fonts.ready);

                const path = `${outDir}/${locale}/${step}-${scheme}.png`;
                await page.screenshot({ path });
                console.log(path);
            }
        }

        await page.close();
    }
} finally {
    await browser.close();
    await server.stop();
}
