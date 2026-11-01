import catalogLight from "@/assets/images/screenshots/catalog-light.png";
import catalogDark from "@/assets/images/screenshots/catalog-dark.png";
import exerciseLight from "@/assets/images/screenshots/exercise-light.png";
import exerciseDark from "@/assets/images/screenshots/exercise-dark.png";
import workoutListLight from "@/assets/images/screenshots/workout-list-light.png";
import workoutListDark from "@/assets/images/screenshots/workout-list-dark.png";
import workoutLight from "@/assets/images/screenshots/workout-light.png";
import workoutDark from "@/assets/images/screenshots/workout-dark.png";
import sessionLight from "@/assets/images/screenshots/session-light.png";
import sessionDark from "@/assets/images/screenshots/session-dark.png";
import sessionRecapLight from "@/assets/images/screenshots/session-recap-light.png";
import sessionRecapDark from "@/assets/images/screenshots/session-recap-dark.png";
import statisticsLight from "@/assets/images/screenshots/statistics-light.png";
import statisticsDark from "@/assets/images/screenshots/statistics-dark.png";
import statisticDetailLight from "@/assets/images/screenshots/statistic-detail-light.png";
import statisticDetailDark from "@/assets/images/screenshots/statistic-detail-dark.png";

/** Screenshots and accent color (a Tailwind palette name) per step. */
const screenshots = [
    {
        color: "orange",
        front: { light: catalogLight, dark: catalogDark },
        back: { light: exerciseLight, dark: exerciseDark },
    },
    {
        color: "blue",
        front: { light: workoutLight, dark: workoutDark },
        back: { light: workoutListLight, dark: workoutListDark },
    },
    {
        color: "green",
        front: { light: sessionLight, dark: sessionDark },
        back: { light: sessionRecapLight, dark: sessionRecapDark },
    },
    {
        color: "purple",
        front: { light: statisticsLight, dark: statisticsDark },
        back: { light: statisticDetailLight, dark: statisticDetailDark },
    },
] as const;

const text = {
    en: [
        {
            title: "Create Your Exercises",
            description: "Build your personal catalog of exercises that match your training goals.",
        },
        {
            title: "Plan Your Workouts",
            description:
                "Combine exercises into workouts and give each one a target, so you always know what you're aiming for.",
        },
        {
            title: "Track Your Session",
            description:
                "Start a session at the gym and log every exercise as you go. The live tracker shows your target and what's next.",
        },
        {
            title: "See Your Progress",
            description:
                "Every finished session feeds your statistics, so you can see how your training develops over time and where you're getting stronger.",
        },
    ],
    de: [
        {
            title: "Erstelle deine Übungen",
            description: "Erstelle deinen persönlichen Katalog an Übungen, die zu deinen Trainingszielen passen.",
        },
        {
            title: "Plane deine Workouts",
            description:
                "Kombiniere Übungen zu Workouts und setze dir für jede einzelne ein Ziel, damit du immer weißt, was du anstrebst.",
        },
        {
            title: "Verfolge deine Session",
            description:
                "Starte eine Session im Fitnessstudio und protokolliere jede Übung, während du sie durchführst. Der Live-Tracker zeigt dein Ziel und was als nächstes kommt.",
        },
        {
            title: "Sieh deinen Fortschritt",
            description:
                "Jede beendete Session füttert deine Statistiken, sodass du sehen kannst, wie sich dein Training über die Zeit entwickelt und wo du stärker wirst.",
        },
    ],
};

export const locales = Object.keys(text) as (keyof typeof text)[];

/** The "How It Works" steps, shared by the homepage and the App Store screenshots. Pass `Astro.currentLocale`. */
export function getSteps(locale: string | undefined) {
    const localized = text[locale as keyof typeof text] ?? text.en;
    return localized.map((step, index) => ({ ...step, ...screenshots[index] }));
}
