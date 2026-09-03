// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: false },
  ssr: false,

  modules: ['@nuxt/ui'],

  css: ['~/assets/css/main.css'],

  colorMode: {
    preference: 'dark',
    fallback: 'dark',
  },

  experimental: {
    appManifest: false,
  },

  components: [
    {
      path: '~/components',
      pathPrefix: true,
    },
  ],

  vite: {
    optimizeDeps: {
      include: [
        'monaco-editor',
        '@vue-flow/core',
        '@vue-flow/background',
        'elkjs/lib/elk.bundled.js',
        'html-to-image',
      ],
      exclude: ['pg-query-emscripten'],
    },
  },

  devServer: {
    port: 9000,
  },

  app: {
    head: {
      title: 'SchemaCraft - Database Diagram Visual Editor',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        {
          name: 'description',
          content: 'Interactive Database Diagram Visual Editor with SQL Monaco IDE',
        },
      ],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        {
          rel: 'preconnect',
          href: 'https://fonts.gstatic.com',
          crossorigin: '',
        },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,400;0,500;0,600;0,700;1,400&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Public+Sans:ital,wght@0,400;0,500;0,600;0,700;1,400&display=swap',
        },
      ],
    },
  },
})
