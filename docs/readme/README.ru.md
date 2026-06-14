# DF HUD

## Кратко

`df_hud` это форк публичного репозитория [`EstebanSole/hx-hud`](https://github.com/EstebanSole/hx-hud), поддерживаемый DF Network и значительно расширенный по части framework, inventory, персистентности, локалей и внутренней модульной структуры.

## Форк и атрибуция

- Базовый репозиторий: `EstebanSole/hx-hud`
- Автор, указанный в upstream `LICENSE`: `Moohja — Elixir Dev`
- Upstream лицензия, на которую опирается атрибуция: [`CC BY-NC 4.0`](https://raw.githubusercontent.com/EstebanSole/hx-hud/main/LICENSE)

Важно:

- В upstream README показан значок MIT.
- В файле upstream `LICENSE` указана `CC BY-NC 4.0`.
- В этом форке атрибуция документируется по файлу upstream `LICENSE`.

## Оценка происхождения кода

Техническое сравнение выполнено **2026-06-14** с публичной веткой `main` проекта `hx-hud`.

- Код, который все еще заметно происходит от `hx-hud`: **11.9%**
- Код, добавленный DF или существенно переписанный в `df_hud`: **88.1%**

Методика:

- Сравнивался только исходный код: `.lua`, `.js`, `.css`, `.html`
- Текущий `df_hud`: **70 исходных файлов**, **7,453 непустых строк**
- Upstream `hx-hud`: **7 исходных файлов**, **3,209 непустых строк**
- Для каждого текущего файла подбиралось наилучшее текстовое совпадение в upstream, затем результат взвешивался по числу непустых строк

Эта цифра является **технической оценкой** для ясности документации. Это **не** юридическое заключение об авторстве, правах или объеме лицензии.

## Что добавляет DF HUD

- Имя ресурса жестко закреплено как `df_hud`
- Новая структура с `client/`, `server/`, `shared/`, `locales/`, `web/js/`
- `init.lua` для выбора framework и inventory
- Поддержка `qbx`, `qbcore`, `esx`, `mythic`, `nd`, `ox`, `vrp`, `vrpex`, `custom`
- Поддержка `ox_inventory`, `qs-inventory`, `qb-inventory`, `ps-inventory`, `codem-inventory`, `core_inventory`, `ak47_inventory`, `esx_inventory`, `esx_inventoryhud`, `origen_inventory`, `mythic-inventory`, `ND_Core`, `vrp`, `custom`
- Персональная персистентность HUD, стилей и ручной коробки передач
- Стартовый баннер, проверка версии и предупреждения по custom support
- Локали вынесены из NUI JS и расширены по языкам
- Новые идентификаторы `voice-simple` и `voice-original`
- Существенно больше совместимости и runtime-логики, чем в исходной монолитной реализации

## Доступные языки

- `es`
- `en`
- `fr`
- `de`
- `ru`
- `jp`
- `cn`

## Примечания по установке

- Папка ресурса должна называться строго `df_hud`
- Используйте `ensure df_hud` в `server.cfg`
- Если переименовать ресурс, стартовая проверка его остановит
- Если используется режим `custom` для framework или inventory, настройте hooks в `shared/config/core.lua`

## Ссылки

- Корневой README: [README.md](../../README.md)
- Испанский: [README.es.md](README.es.md)
- Английский: [README.en.md](README.en.md)
- Французский: [README.fr.md](README.fr.md)
- Немецкий: [README.de.md](README.de.md)
- Японский: [README.jp.md](README.jp.md)
- Китайский: [README.cn.md](README.cn.md)
