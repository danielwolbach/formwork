import { links } from "@/config";
import type { Translations } from "@/i18n/en";

export default {
    description:
        "Formwork ist ein schöner und einfacher Workout-Tracker für iPhone. Plane deine Workouts, verfolge deine Sessions und sieh deinen Fortschritt über die Zeit.",
    header: {
        home: "/de/",
        appIcon: "App-Icon",
        download: "Download",
        switchTo: { lang: "en", home: "/" },
    },
    appStore: {
        alt: "Laden im App Store",
        light: "/badges/app-store-light-de.svg",
        dark: "/badges/app-store-dark-de.svg",
    },
    footer: {
        sections: [
            {
                title: "App",
                links: [
                    { label: "Download", href: links.appStore },
                    { label: "Roadmap", href: "/de/roadmap" },
                    { label: "Support", href: "/de/support" },
                ],
            },
            {
                title: "Rechtliches",
                links: [
                    { label: "Datenschutzerklärung", href: "/de/legal/privacy-policy" },
                    { label: "Nutzungsbedingungen", href: "/de/legal/terms-of-service" },
                    { label: "Impressum", href: "/de/legal/imprint" },
                ],
            },
            {
                title: "Social Media",
                links: [
                    { label: "Instagram", href: links.instagram },
                    { label: "Bluesky", href: links.bluesky },
                    { label: "Mastodon", href: links.mastodon },
                ],
            },
        ],
        rights: "Alle Rechte vorbehalten.",
        trademarks:
            "Apple, the Apple logo and iPhone are trademarks of Apple Inc., registered in the U.S. and other countries and regions. App Store is a service mark of Apple Inc.",
    },
    roadmap: {
        done: "Erledigt",
        planned: "Geplant",
    },
    featureStep: {
        step: "Schritt",
    },
} satisfies Translations;
