# LTRime

LTRime 是一个用于 macOS 的 Rime (鼠鬚管) 配置管理工具。旨在简化 Rime 的安装、配置和多方案切换，目前主要支持 **[霧凇拼音 (rime-ice)](https://github.com/iDvel/rime-ice)** 和 **[白霜拼音 (rime-frost)](https://github.com/gaboolic/rime-frost)**。

## ✨ 功能特性

- **多方案支持**：内置支持两款流行的拼音配置方案，可按需选择。
- **自动化脚本**：提供 `macos_setup.sh` 交互式脚本，一键处理安装 Squirrel、下载/更新配置、部署自定义设置。
- **配置隔离**：通过 `customs/` 目录集中管理个人配置（如补丁文件），避免直接修改仓库文件，方便后续更新。
- **无缝切换**：通过软链接 (`Symlink`) 方式将配置链接到 `~/Library/Rime`，在不同方案间快速切换而无需手动复制文件。

## 📂 目录结构

- `macos_setup.sh`: 主管理脚本，提供安装、更新、部署、切换的交互式菜单。
- `sync.sh`: 快速同步脚本，用于拉取上游更新并重新应用自定义配置。
- `customs/`: **用户自定义目录**。请将你的 `default.custom.yaml`, `squirrel.custom.yaml`, `luna_pinyin.custom.yaml` 等文件放在此处。脚本会自动将其复制到生效的方案目录中。
- `rime-ice/`: (自动下载) 霧凇拼音仓库。
- `rime-frost/`: (自动下载) 白霜拼音仓库。

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone <your-repo-url> ltrime
cd ltrime
```

### 2. 运行设置脚本

赋予脚本执行权限并运行：

```bash
chmod +x macos_setup.sh sync.sh
./macos_setup.sh
```

### 3. 脚本功能说明

运行脚本后，你将看到以下菜单：

1. **安装鼠鬚管 (Squirrel)**: 检查系统是否已安装 Squirrel，未安装则自动通过 Homebrew 安装。
2. **配置/更新 Rime 方案**: 选择下载 `rime-ice` 或 `rime-frost`。如果已存在，则询问是否更新。
3. **部署自定義配置**: 将 `customs/` 目录下的所有 `.yaml` 配置文件复制到选定的方案目录中。
4. **連結方案到系統目錄**: 备份原有的 `~/Library/Rime` (如果有)，并将选定的方案目录软链接到该位置。
5. **一鍵完成所有步驟**: 依次执行上述所有步骤，适合初次安装。

## ⚙️ 自定义配置

为了保持上游仓库的纯净并方便更新，建议**不要**直接修改 `rime-ice` 或 `rime-frost` 目录下的文件。

1. 在 `customs/` 目录下创建或修改你的配置文件（例如 `default.custom.yaml`）。
2. 运行 `./macos_setup.sh` 选择 `3) 部署自定義配置`，或者运行 `./sync.sh`。
3. 重新部署 Rime (在输入法菜单中选择 "重新部署")。

## 🔄 更新

若要更新方案并保持自定义配置：

```bash
./sync.sh
```
此脚本会拉取 `rime-ice` 和 `rime-frost` 的最新代码，并自动重新应用 `customs/` 中的配置。

## 🔗 相关链接

- [rime-ice (霧凇拼音)](https://github.com/iDvel/rime-ice)
- [rime-frost (白霜拼音)](https://github.com/gaboolic/rime-frost)
- [Rime Input Method Engine](https://rime.im/)
- [rime-soak (Rime 在线配置)](https://github.com/pdog18/rime-soak)
