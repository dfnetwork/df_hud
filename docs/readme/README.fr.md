# DF HUD

## Resume

`df_hud` est un fork du depot public [`EstebanSole/hx-hud`](https://github.com/EstebanSole/hx-hud), maintenu par DF Network et etendu pour prendre en charge davantage de frameworks, d'inventaires, de persistance, de langues et une structure interne beaucoup plus modulaire.

## Fork et attribution

- Depot de base : `EstebanSole/hx-hud`
- Auteur credite dans le `LICENSE` upstream : `Moohja — Elixir Dev`
- Licence upstream retenue pour l'attribution : [`CC BY-NC 4.0`](https://raw.githubusercontent.com/EstebanSole/hx-hud/main/LICENSE)

Note importante :

- Le README upstream affiche un badge MIT.
- Le fichier `LICENSE` upstream indique `CC BY-NC 4.0`.
- Ce fork documente l'attribution en suivant le fichier `LICENSE` upstream.

## Estimation de l'origine du code

Comparaison technique effectuee le **2026-06-14** contre la branche publique `main` de `hx-hud`.

- Code encore reconnaissable comme derive de `hx-hud` : **11.9%**
- Code ajoute par DF ou fortement reecrit dans `df_hud` : **88.1%**

Methodologie :

- Comparaison du code source uniquement : `.lua`, `.js`, `.css`, `.html`
- `df_hud` actuel : **70 fichiers source**, **7,453 lignes non vides**
- `hx-hud` upstream : **7 fichiers source**, **3,209 lignes non vides**
- Chaque fichier actuel a ete compare a sa meilleure correspondance textuelle dans l'upstream, ponderee par le nombre de lignes non vides

Ce pourcentage est une **approximation technique** pour clarifier l'etat du fork. Ce n'est **pas** une decision juridique sur l'auteur, le copyright ou la portee de la licence.

## Ce que DF HUD ajoute

- Nom de ressource force a `df_hud`
- Structure reorganisee avec `client/`, `server/`, `shared/`, `locales/`, `web/js/`
- `init.lua` pour resoudre framework et inventaire
- Support de `qbx`, `qbcore`, `esx`, `mythic`, `nd`, `ox`, `vrp`, `vrpex`, `custom`
- Support de `ox_inventory`, `qs-inventory`, `qb-inventory`, `ps-inventory`, `codem-inventory`, `core_inventory`, `ak47_inventory`, `esx_inventory`, `esx_inventoryhud`, `origen_inventory`, `mythic-inventory`, `ND_Core`, `vrp`, `custom`
- Persistance par joueur pour le HUD, les styles et la boite manuelle
- Banner de demarrage, verification de version et avertissements de support
- Locales separes du JS NUI avec davantage de langues
- Nouveaux identifiants `voice-simple` et `voice-original`
- Plus de compatibilite et de logique d'execution que l'implementation monolithique d'origine

## Langues disponibles

- `es`
- `en`
- `fr`
- `de`
- `ru`
- `jp`
- `cn`

## Notes d'installation

- Le dossier de la ressource doit s'appeler exactement `df_hud`
- Utilisez `ensure df_hud` dans `server.cfg`
- Si vous renommez la ressource, la validation au demarrage l'arretera
- Si vous utilisez un framework ou un inventaire `custom`, configurez les hooks dans `shared/config/core.lua`

## Liens

- README racine : [README.md](../../README.md)
- Espagnol : [README.es.md](README.es.md)
- Anglais : [README.en.md](README.en.md)
- Allemand : [README.de.md](README.de.md)
- Russe : [README.ru.md](README.ru.md)
- Japonais : [README.jp.md](README.jp.md)
- Chinois : [README.cn.md](README.cn.md)
