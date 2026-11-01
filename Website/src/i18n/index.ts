import en from "@/i18n/en";
import de from "@/i18n/de";

const translations = { en, de };

/** Pass `Astro.currentLocale`. */
export function getTranslations(locale: string | undefined) {
    return translations[locale as keyof typeof translations] ?? en;
}
