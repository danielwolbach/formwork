import overviewLight from "@/assets/images/screenshots/overview-light.png";
import overviewDark from "@/assets/images/screenshots/overview-dark.png";

const text = {
    en: {
        title: "Meet Formwork",
        description: "Your fast and straightforward workout tracker that gets out of the way.",
        alt: "Formwork overview screen",
    },
    de: {
        title: "Lerne Formwork kennen",
        description: "Dein schneller und unkomplizierter Workout-Tracker, der nie im Weg ist.",
        alt: "Formwork Übersichtsbildschirm",
    },
};

/** The homepage hero, shared with the App Store screenshots. Pass `Astro.currentLocale`. */
export function getHero(locale: string | undefined) {
    const { alt, ...localized } = text[locale as keyof typeof text] ?? text.en;
    return { ...localized, screenshot: { light: overviewLight, dark: overviewDark, alt } };
}
