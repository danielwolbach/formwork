import { links } from "@/config";

const en = {
    /** Default meta description; pages can override it via the Layout's `description` prop. */
    description:
        "Formwork is a beautiful and simple workout tracker for iPhone. Plan your workouts, track your sessions and see your progress over time.",
    header: {
        home: "/",
        appIcon: "App icon",
        download: "Download",
        switchTo: { lang: "de", home: "/de/" },
    },
    appStore: {
        alt: "Download on the App Store",
        light: "/badges/app-store-light.svg",
        dark: "/badges/app-store-dark.svg",
    },
    footer: {
        sections: [
            {
                title: "App",
                links: [
                    { label: "Download", href: links.appStore },
                    { label: "Roadmap", href: "/roadmap" },
                    { label: "Support", href: "/support" },
                ],
            },
            {
                title: "Legal",
                links: [
                    { label: "Privacy Policy", href: "/legal/privacy-policy" },
                    { label: "Terms of Service", href: "/legal/terms-of-service" },
                    { label: "Imprint", href: "/legal/imprint" },
                ],
            },
            {
                title: "Social",
                links: [
                    { label: "Instagram", href: links.instagram },
                    { label: "Bluesky", href: links.bluesky },
                    { label: "Mastodon", href: links.mastodon },
                ],
            },
        ],
        rights: "All rights reserved.",
        trademarks:
            "Apple, the Apple logo and iPhone are trademarks of Apple Inc., registered in the U.S. and other countries and regions. App Store is a service mark of Apple Inc.",
    },
    roadmap: {
        done: "Done",
        planned: "Planned",
    },
    featureStep: {
        step: "Step",
    },
};

export type Translations = typeof en;
export default en;
