# DF HUD

## 概述

`df_hud` 是基于公开仓库 [`EstebanSole/hx-hud`](https://github.com/EstebanSole/hx-hud) 的 fork，由 DF Network 维护，并在 framework、inventory、持久化、本地化以及内部模块化结构方面做了大量扩展。

## Fork 与归属说明

- 基础仓库：`EstebanSole/hx-hud`
- upstream `LICENSE` 中注明的作者：`Moohja — Elixir Dev`
- 归属说明参考的 upstream 许可证：[`CC BY-NC 4.0`](https://raw.githubusercontent.com/EstebanSole/hx-hud/main/LICENSE)

重要说明：

- upstream README 显示的是 MIT 徽章。
- upstream 的 `LICENSE` 文件写的是 `CC BY-NC 4.0`。
- 本 fork 以 upstream 的 `LICENSE` 文件作为归属说明依据。

## 代码来源估算

已于 **2026-06-14** 对 `hx-hud` 公共 `main` 分支进行了技术比对。

- 仍可明显识别为来自 `hx-hud` 的代码：**11.9%**
- 由 DF 新增或在 `df_hud` 中大幅重写的代码：**88.1%**

方法：

- 仅比较源代码：`.lua`、`.js`、`.css`、`.html`
- 当前 `df_hud`：**70 个源文件**，**7,453 行非空代码**
- upstream `hx-hud`：**7 个源文件**，**3,209 行非空代码**
- 对当前每个文件寻找 upstream 中最接近的文本匹配，并按非空行数加权

这个比例是为了文档清晰度给出的 **技术估算值**，并不是关于作者、版权或许可证范围的法律裁定。

## DF HUD 相比 upstream 的新增内容

- 资源名称强制固定为 `df_hud`
- 重构目录为 `client/`、`server/`、`shared/`、`locales/`、`web/js/`
- 使用 `init.lua` 处理 framework 与 inventory 解析
- 支持 `qbx`、`qbcore`、`esx`、`mythic`、`nd`、`ox`、`vrp`、`vrpex`、`custom`
- 支持 `ox_inventory`、`qs-inventory`、`qb-inventory`、`ps-inventory`、`codem-inventory`、`core_inventory`、`ak47_inventory`、`esx_inventory`、`esx_inventoryhud`、`origen_inventory`、`mythic-inventory`、`ND_Core`、`vrp`、`custom`
- HUD 配置、样式与手动挡偏好的玩家级持久化
- 启动横幅、版本检查以及 custom 支持提示
- 将 locales 从 NUI JS 中拆分出来并扩展多语言支持
- 新的 `voice-simple` 与 `voice-original` 标识
- 相比原始单体实现，具备更多兼容层与运行时逻辑

## 可用语言

- `es`
- `en`
- `fr`
- `de`
- `ru`
- `jp`
- `cn`

## 安装说明

- 资源文件夹名称必须严格为 `df_hud`
- 在 `server.cfg` 中使用 `ensure df_hud`
- 如果你重命名资源，启动校验会主动停止它
- 如果使用 `custom` framework 或 inventory，请在 `shared/config/core.lua` 中配置 hooks

## 链接

- 根 README： [README.md](../../README.md)
- 西班牙语： [README.es.md](README.es.md)
- 英语： [README.en.md](README.en.md)
- 法语： [README.fr.md](README.fr.md)
- 德语： [README.de.md](README.de.md)
- 俄语： [README.ru.md](README.ru.md)
- 日语： [README.jp.md](README.jp.md)
