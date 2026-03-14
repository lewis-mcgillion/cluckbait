module ApplicationHelper
  LOCALE_NAMES = {
    en: "English",
    zh: "中文",
    hi: "हिन्दी",
    es: "Español",
    fr: "Français",
    ar: "العربية",
    pt: "Português",
    ru: "Русский",
    ja: "日本語",
    de: "Deutsch",
    jv: "Basa Jawa",
    ko: "한국어",
    vi: "Tiếng Việt",
    tr: "Türkçe",
    ur: "اردو",
    it: "Italiano",
    th: "ไทย",
    fa: "فارسی",
    pl: "Polski",
    su: "Basa Sunda",
    ha: "Hausa",
    my: "မြန်မာ",
    uk: "Українська",
    ms: "Bahasa Melayu",
    tl: "Filipino",
    nl: "Nederlands",
    ro: "Română",
    yo: "Yorùbá",
    ig: "Igbo",
    am: "አማርኛ",
    cs: "Čeština",
    el: "Ελληνικά",
    hu: "Magyar",
    sv: "Svenska",
    he: "עברית",
    sw: "Kiswahili",
    id: "Bahasa Indonesia",
    ne: "नेपाली",
    si: "සිංහල",
    ps: "پښتو",
    cy: "Cymraeg",
    ga: "Gaeilge"
  }.freeze

  RTL_LOCALES = %i[ar ur fa he ps].freeze

  def locale_name(locale)
    LOCALE_NAMES[locale.to_sym] || locale.to_s
  end

  def rtl_locale?
    RTL_LOCALES.include?(I18n.locale)
  end

  def text_direction
    rtl_locale? ? "rtl" : "ltr"
  end
end
