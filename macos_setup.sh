#!/bin/bash

set -e

RIME_DIR="$HOME/Library/Rime"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- 工具函數 ---

check_squirrel_installed() {
    if [ -d "/Library/Input Methods/Squirrel.app" ] || [ -d "$HOME/Library/Input Methods/Squirrel.app" ]; then
        return 0
    else
        return 1
    fi
}

select_scheme() {
    echo ""
    echo "請選擇 Rime 方案:"
    echo "1) rime-ice (霧凇拼音)"
    echo "2) rime-frost (白霜拼音)"
    read -p "輸入選擇 (1 或 2): " choice
    case $choice in
        1) echo "rime-ice" ;;
        2) echo "rime-frost" ;;
        *) echo "invalid" ;;
    esac
}

# --- 核心任務 ---

task_install_squirrel() {
    echo "--- 檢查環境 ---"
    if ! command -v brew &> /dev/null; then
        echo "未找到 Homebrew。正在安裝 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if check_squirrel_installed; then
        echo "鼠鬚管 (Squirrel) 已經安裝。"
    else
        echo "正在安裝鼠鬚管 (Squirrel)..."
        brew install --cask squirrel
        echo "鼠鬚管安裝成功。"
    fi
}

task_setup_config() {
    local target=$(select_scheme)
    if [ "$target" == "invalid" ]; then echo "無效選擇"; return 1; fi

    # 依賴檢查：配置前建議安裝 Squirrel
    if ! check_squirrel_installed; then
        echo "警告: 尚未檢測到鼠鬚管安裝，將先執行安裝任務..."
        task_install_squirrel
    fi

    local url=""
    if [ "$target" == "rime-ice" ]; then
        url="https://github.com/iDvel/rime-ice.git"
    else
        url="https://github.com/gaboolic/rime-frost.git"
    fi

    if [ ! -d "$SCRIPT_DIR/$target" ]; then
        echo "正在 Clone $target..."
        git clone --depth 1 "$url" "$SCRIPT_DIR/$target"
    else
        echo "目錄 $target 已存在。"
        read -p "是否更新該方案? (y/n): " update_choice
        if [[ "$update_choice" == "y" || "$update_choice" == "Y" ]]; then
            echo "正在更新 $target..."
            (cd "$SCRIPT_DIR/$target" && git pull)
        fi
    fi
    CURRENT_SCHEME="$target"
}

task_deploy_customs() {
    local target=${1:-""}
    if [ -z "$target" ]; then
        target=$(select_scheme)
    fi
    if [ "$target" == "invalid" ]; then echo "無效選擇"; return 1; fi

    local customs_dir="$SCRIPT_DIR/customs"
    local target_dir="$SCRIPT_DIR/$target"

    if [ ! -d "$target_dir" ]; then
        echo "錯誤: 方案目錄 $target_dir 不存在，請先執行方案配置。"
        return 1
    fi

    if [ -d "$customs_dir" ]; then
        echo "正在將自定義配置從 $customs_dir 部署到 $target_dir..."
        cp -v "$customs_dir"/*.yaml "$target_dir/" 2>/dev/null || true
        echo "自定義配置部署完成。"
    else
        echo "未找到 customs 目錄，跳過。"
    fi
}

task_link_rime() {
    local target=$(select_scheme)
    if [ "$target" == "invalid" ]; then echo "無效選擇"; return 1; fi
    
    local target_dir="$SCRIPT_DIR/$target"
    if [ ! -d "$target_dir" ]; then
        echo "錯誤: 方案目錄 $target_dir 不存在，請先執行方案配置。"
        return 1
    fi

    echo "正在連結 $target 到 $RIME_DIR..."
    if [ -L "$RIME_DIR" ]; then
        echo "移除現有軟連結: $RIME_DIR"
        rm "$RIME_DIR"
    elif [ -d "$RIME_DIR" ]; then
        local backup="$RIME_DIR.backup.$(date +%Y%m%d_%H%M%S)"
        echo "備份現有目錄到: $backup"
        mv "$RIME_DIR" "$backup"
    fi

    mkdir -p "$(dirname "$RIME_DIR")"
    ln -s "$target_dir" "$RIME_DIR"
    echo "連結創建成功: $RIME_DIR -> $target_dir"
}

task_all_in_one() {
    task_install_squirrel
    
    local target=$(select_scheme)
    if [ "$target" == "invalid" ]; then echo "無效選擇"; return 1; fi

    # 執行所有步驟
    setup_config_no_prompt "$target"
    task_deploy_customs "$target"
    
    # 執行 link
    local target_dir="$SCRIPT_DIR/$target"
    if [ -L "$RIME_DIR" ]; then rm "$RIME_DIR"; fi
    if [ -d "$RIME_DIR" ] && [ ! -L "$RIME_DIR" ]; then mv "$RIME_DIR" "$RIME_DIR.bak.$(date +%s)"; fi
    ln -s "$target_dir" "$RIME_DIR"
    
    echo "一鍵安裝完成！"
}

# 輔助函數：不帶交互的 setup
setup_config_no_prompt() {
    local target="$1"
    local url=""
    [ "$target" == "rime-ice" ] && url="https://github.com/iDvel/rime-ice.git" || url="https://github.com/gaboolic/rime-frost.git"
    
    if [ ! -d "$SCRIPT_DIR/$target" ]; then
        git clone --depth 1 "$url" "$SCRIPT_DIR/$target"
    else
        (cd "$SCRIPT_DIR/$target" && git pull)
    fi
}

# --- 主選單 ---

show_menu() {
    while true; do
        echo ""
        echo "========== LTRime 管理選單 =========="
        echo "1) 安裝鼠鬚管 (Squirrel)"
        echo "2) 配置/更新 Rime 方案 (下載字典等)"
        echo "3) 部署自定義配置 (將 customs/ 注入方案)"
        echo "4) 連結方案到系統目錄 (Symlink)"
        echo "5) 一鍵完成所有步驟"
        echo "q) 退出"
        echo "===================================="
        read -p "請選擇操作 [1-5, q]: " cmd
        echo ""

        case $cmd in
            1) task_install_squirrel ;;
            2) task_setup_config ;;
            3) task_deploy_customs ;;
            4) task_link_rime ;;
            5) task_all_in_one ;;
            q) exit 0 ;;
            *) echo "無效輸入" ;;
        esac
    done
}

show_menu
