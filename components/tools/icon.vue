<script setup lang="ts">
import { normalizeClass } from "vue";

defineOptions({
  inheritAttrs: false,
});

export type IconLibProps = {
  icon: string;
  dir?: string;
  stroke?: string;
  rectStroke?: string;
  circleStroke?: string;
  fill?: string;
  height?: number | string;
  width?: number | string;
  pathFill?: string;
  rectFill?: string;
  pathClass?: string | string[] | Record<string, boolean>;
  rectClass?: string | string[] | Record<string, boolean>;
  svgClass?: string | string[] | Record<string, boolean>;
  circleFill?: string;
  circleClass?: string | string[] | Record<string, boolean>;
};

const props = defineProps<IconLibProps>();

/**
 * Load all SVGs at build time.
 *
 * Important:
 * - eager: true means the SVG content is available during SSR.
 * - ?raw means we receive the SVG as a string.
 *
 * No browser APIs are required.
 */
const iconModules = import.meta.glob("~/assets/icons/**/*.svg", {
  eager: true,
  query: "?raw",
  import: "default",
}) as Record<string, string>;

const iconRegistry = Object.create(null) as Record<string, string>;

for (const [path, svg] of Object.entries(iconModules)) {
  const normalizedPath = path
    .replace(/\\/g, "/")
    .replace(/^.*\/app\/assets\/icons\//, "")
    .replace(/\.svg$/i, "");

  iconRegistry[normalizedPath] = svg;
}

/**
 * Fallback icon.
 */
const fallbackSvg = `
<svg
  xmlns="http://www.w3.org/2000/svg"
  width="24"
  height="24"
  viewBox="0 0 24 24"
  fill="none"
  stroke="currentColor"
  stroke-width="2"
  stroke-linecap="round"
  stroke-linejoin="round"
>
  <circle cx="12" cy="12" r="10"/>
  <line x1="12" y1="8" x2="12" y2="12"/>
  <line x1="12" y1="16" x2="12.01" y2="16"/>
</svg>
`;

/**
 * Convert Vue class values into an actual class string.
 *
 * This correctly handles:
 *
 * string
 * string[]
 * Record<string, boolean>
 */
function resolveClass(
  value: IconLibProps[keyof IconLibProps],
): string | undefined {
  if (!value) {
    return undefined;
  }

  const result = normalizeClass(value as any);

  return result || undefined;
}

/**
 * Escape values before putting them into an SVG attribute.
 */
function escapeAttribute(value: string | number): string {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/"/g, "&quot;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

/**
 * Convert the requested icon into the same format used
 * by import.meta.glob().
 *
 * We don't assume that Vite/Nuxt will preserve the alias
 * exactly as "~/app/assets/..." at runtime.
 */
function getIconSource(): string | undefined {
  const dir = props.dir ? props.dir.replace(/^\/+|\/+$/g, "") : "";

  const icon = props.icon.replace(/^\/+|\/+$/g, "");

  const lookupKey = dir ? `${dir}/${icon}` : icon;
  const registryKeys = Object.keys(iconRegistry);
  const findKey = registryKeys.find((key) => key.includes(lookupKey));

  if (findKey) {
    return iconRegistry[findKey];
  }
  return "";
}

/**
 * Replace/add an attribute on the SVG root.
 */
function setSvgAttribute(
  svg: string,
  attribute: string,
  value: string | number | undefined,
): string {
  if (value === undefined || value === null || value === "") {
    return svg;
  }

  const escapedValue = escapeAttribute(value);

  const attributeRegex = new RegExp(`\\s${attribute}="[^"]*"`, "i");

  if (attributeRegex.test(svg)) {
    return svg.replace(attributeRegex, ` ${attribute}="${escapedValue}"`);
  }

  return svg.replace(
    /<svg\b([^>]*)>/i,
    `<svg$1 ${attribute}="${escapedValue}">`,
  );
}

/**
 * Add/replace the class attribute on matching SVG elements.
 */
function setElementClass(
  svg: string,
  element: "path" | "rect" | "circle",
  className: string | undefined,
): string {
  if (!className) {
    return svg;
  }

  const escapedClass = escapeAttribute(className);

  const elementRegex = new RegExp(`<${element}\\b([^>]*)>`, "gi");

  return svg.replace(elementRegex, (_match, attributes: string) => {
    const classRegex = /\sclass="[^"]*"/i;

    if (classRegex.test(attributes)) {
      attributes = attributes.replace(classRegex, ` class="${escapedClass}"`);
    } else {
      attributes += ` class="${escapedClass}"`;
    }

    return `<${element}${attributes}>`;
  });
}

/**
 * Set an attribute on every matching SVG element.
 */
function setElementAttribute(
  svg: string,
  element: "path" | "rect" | "circle",
  attribute: string,
  value: string | undefined,
): string {
  if (!value) {
    return svg;
  }

  const escapedValue = escapeAttribute(value);

  const elementRegex = new RegExp(`<${element}\\b([^>]*)>`, "gi");

  return svg.replace(elementRegex, (_match, attributes: string) => {
    const attributeRegex = new RegExp(`\\s${attribute}="[^"]*"`, "i");

    if (attributeRegex.test(attributes)) {
      attributes = attributes.replace(
        attributeRegex,
        ` ${attribute}="${escapedValue}"`,
      );
    } else {
      attributes += ` ${attribute}="${escapedValue}"`;
    }

    return `<${element}${attributes}>`;
  });
}

/**
 * Process an SVG string.
 *
 * This function is completely SSR-safe.
 *
 * It does NOT use:
 * - window
 * - document
 * - DOMParser
 * - XMLSerializer
 */
function buildSvg(source: string): string {
  let svg = source.trim();

  /**
   * Make sure we actually received an SVG.
   */
  if (!/^<svg[\s>]/i.test(svg)) {
    return fallbackSvg;
  }

  /**
   * Root SVG attributes.
   */
  svg = setSvgAttribute(svg, "width", props.width);
  svg = setSvgAttribute(svg, "height", props.height);
  svg = setSvgAttribute(svg, "fill", props.fill);

  const svgClass = resolveClass(props.svgClass);

  if (svgClass) {
    svg = setSvgAttribute(svg, "class", svgClass);
  }

  /**
   * PATH
   */
  const pathClass = resolveClass(props.pathClass);

  if (pathClass) {
    svg = setElementClass(svg, "path", pathClass);
  }

  if (props.stroke) {
    svg = setElementAttribute(svg, "path", "stroke", props.stroke);

    svg = setElementAttribute(svg, "path", "fill", "none");
  }

  if (props.pathFill) {
    svg = setElementAttribute(svg, "path", "fill", props.pathFill);

    svg = setElementAttribute(svg, "path", "stroke", "none");
  }

  /**
   * RECT
   */
  const rectClass = resolveClass(props.rectClass);

  if (rectClass) {
    svg = setElementClass(svg, "rect", rectClass);
  }

  if (props.rectStroke) {
    svg = setElementAttribute(svg, "rect", "stroke", props.rectStroke);

    svg = setElementAttribute(svg, "rect", "fill", "none");
  }

  if (props.rectFill) {
    svg = setElementAttribute(svg, "rect", "fill", props.rectFill);

    svg = setElementAttribute(svg, "rect", "stroke", "none");
  }

  /**
   * CIRCLE
   */
  const circleClass = resolveClass(props.circleClass);

  if (circleClass) {
    svg = setElementClass(svg, "circle", circleClass);
  }

  if (props.circleStroke) {
    svg = setElementAttribute(svg, "circle", "stroke", props.circleStroke);

    svg = setElementAttribute(svg, "circle", "fill", "none");
  }

  if (props.circleFill) {
    svg = setElementAttribute(svg, "circle", "fill", props.circleFill);

    svg = setElementAttribute(svg, "circle", "stroke", "none");
  }

  return svg;
}

/**
 * Cache only the original SVG lookup.
 *
 * We don't cache the final result because the final SVG
 * depends on reactive props.
 */
const sourceSvg = computed(() => {
  return getIconSource() ?? fallbackSvg;
});

/**
 * Final SVG.
 *
 * Because this is computed from reactive props, it automatically
 * recalculates whenever ANY relevant prop changes.
 */
const svgString = computed(() => {
  return buildSvg(sourceSvg.value);
});
</script>

<template>
  <ClientOnly>
    <span v-bind="$attrs" v-html="svgString" />
  </ClientOnly>
</template>
