import type { APIRoute, GetStaticPaths } from "astro";
import icon from "@/assets/images/icons/favicon.svg?raw";

// Favicons have no surrounding text color, so each variant sets one for the icon's currentColor.
// They're separate files because browsers don't re-render an SVG favicon when the color scheme changes,
// but they do re-evaluate the media attribute on <link rel="icon">.
const colors = {
    light: "#18181b",
    dark: "#fafafa",
};

export const getStaticPaths = (() =>
    Object.keys(colors).map((scheme) => ({ params: { scheme } }))) satisfies GetStaticPaths;

export const GET: APIRoute = ({ params }) =>
    new Response(
        icon.replace(
            /<svg[^>]*>/,
            (tag) => `${tag}<style>svg{color:${colors[params.scheme as keyof typeof colors]}}</style>`,
        ),
        {
            headers: { "Content-Type": "image/svg+xml" },
        },
    );
