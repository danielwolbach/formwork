import { getHero } from "@/data/hero";
import { getSteps } from "@/data/steps";

/** The App Store screenshots in order: the homepage hero first, then one per feature step. */
export function getAppStorePages(locale: string) {
    const hero = getHero(locale);
    return [
        { title: hero.title, screenshot: hero.screenshot, color: "zinc" as const },
        ...getSteps(locale).map(({ title, front, color }) => ({ title, screenshot: front, color })),
    ];
}
