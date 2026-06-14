# DF HUD

## 概要

`df_hud` は公開リポジトリ [`EstebanSole/hx-hud`](https://github.com/EstebanSole/hx-hud) を元にした fork で、DF Network により管理され、framework、inventory、永続化、ロケール、内部構成のモジュール化が大きく拡張されています。

## Fork とクレジット

- ベースリポジトリ: `EstebanSole/hx-hud`
- upstream の `LICENSE` に記載されている作者: `Moohja — Elixir Dev`
- クレジット判断の基準にした upstream ライセンス: [`CC BY-NC 4.0`](https://raw.githubusercontent.com/EstebanSole/hx-hud/main/LICENSE)

重要な補足:

- upstream README には MIT バッジがあります。
- しかし upstream の `LICENSE` ファイルには `CC BY-NC 4.0` と記載されています。
- この fork では upstream の `LICENSE` に基づいてクレジットを明記しています。

## コード由来の推定

`hx-hud` の公開 `main` ブランチに対して **2026-06-14** に技術比較を行いました。

- まだ `hx-hud` 由来と判別できるコード: **11.9%**
- DF により追加または大きく書き換えられた `df_hud` のコード: **88.1%**

方法:

- 比較対象はソースコードのみ: `.lua`, `.js`, `.css`, `.html`
- 現在の `df_hud`: **70 個のソースファイル**, **7,453 行の非空行**
- upstream `hx-hud`: **7 個のソースファイル**, **3,209 行の非空行**
- 現在の各ファイルについて upstream 内の最も近いテキスト一致を探し、非空行数で重み付けしました

この数値は、fork の状態を明確にするための **技術的な推定値** です。法的な著作権判断やライセンス解釈そのものではありません。

## DF HUD が追加したもの

- リソース名を `df_hud` に固定
- `client/`, `server/`, `shared/`, `locales/`, `web/js/` に再編成
- framework と inventory を解決する `init.lua`
- `qbx`, `qbcore`, `esx`, `mythic`, `nd`, `ox`, `vrp`, `vrpex`, `custom` をサポート
- `ox_inventory`, `qs-inventory`, `qb-inventory`, `ps-inventory`, `codem-inventory`, `core_inventory`, `ak47_inventory`, `esx_inventory`, `esx_inventoryhud`, `origen_inventory`, `mythic-inventory`, `ND_Core`, `vrp`, `custom` をサポート
- HUD 設定、スタイル、マニュアルギアのプレイヤー単位永続化
- 起動バナー、バージョン確認、custom support 警告
- NUI JS から分離されたロケールと拡張された言語対応
- 新しい識別子 `voice-simple` と `voice-original`
- 元の単一構成実装より大幅に高い互換性と実行時ロジック

## 利用可能な言語

- `es`
- `en`
- `fr`
- `de`
- `ru`
- `jp`
- `cn`

## インストール時の注意

- リソースフォルダ名は必ず `df_hud` にしてください
- `server.cfg` では `ensure df_hud` を使用してください
- リソース名を変更すると、起動時検証により停止されます
- `custom` framework または inventory を使う場合は `shared/config/core.lua` で hooks を設定してください

## リンク

- ルート README: [README.md](../../README.md)
- スペイン語: [README.es.md](README.es.md)
- 英語: [README.en.md](README.en.md)
- フランス語: [README.fr.md](README.fr.md)
- ドイツ語: [README.de.md](README.de.md)
- ロシア語: [README.ru.md](README.ru.md)
- 中国語: [README.cn.md](README.cn.md)
