Locales = Locales or {}

local function normalizeLocale(locale)
    if type(locale) ~= 'string' or locale == '' then
        return 'es'
    end

    locale = locale:lower()

    if locale == 'zh' or locale == 'zh-cn' then
        return 'cn'
    end

    if locale == 'ja' then
        return 'jp'
    end

    return locale
end

function RegisterLocale(locale, entries)
    Locales[normalizeLocale(locale)] = entries
end

function GetLocale(locale)
    locale = normalizeLocale(locale)
    return Locales[locale] or Locales.es or {}
end
