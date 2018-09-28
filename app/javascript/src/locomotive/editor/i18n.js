import i18next from 'i18next';

i18next
  .init({
    interpolation: {
      // React already does escaping
      escapeValue: false
    },
    lng: Locomotive.data.locale, // 'en' | 'es'
    // Using simple hardcoded resources for simple example
    resources: {
      [Locomotive.data.locale]: {
        translation: Locomotive.i18n
      }
    }
  })

export default i18next;
