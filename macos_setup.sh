#!/bin/bash

set -e

RIME_DIR="$HOME/Library/Rime"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

check_brew() {
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed"
    fi
}

install_squirrel() {
    echo "Installing Squirrel..."
    brew install --cask squirrel
    echo "Squirrel installed successfully"
}

link_rime() {
    local target_dir="$1"
    
    if [ ! -d "$target_dir" ]; then
        echo "Error: Directory '$target_dir' does not exist"
        exit 1
    fi

    if [ -L "$RIME_DIR" ]; then
        echo "Removing existing symlink: $RIME_DIR"
        rm "$RIME_DIR"
    elif [ -d "$RIME_DIR" ]; then
        echo "Backing up existing directory: $RIME_DIR"
        mv "$RIME_DIR" "$RIME_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    mkdir -p "$(dirname "$RIME_DIR")"
    ln -s "$target_dir" "$RIME_DIR"
    echo "Created symlink: $RIME_DIR -> $target_dir"
}

setup_config() {
    local target="$1"
    local url=""
    
    case $target in
        "rime-ice")
            url="https://github.com/iDvel/rime-ice.git"
            ;;
        "rime-frost")
            url="https://github.com/gaboolic/rime-frost.git"
            ;;
        *)
            echo "Unknown target: $target"
            exit 1
            ;;
    esac

    if [ ! -d "$SCRIPT_DIR/$target" ]; then
        echo "Cloning $target..."
        git clone --depth 1 "$url" "$SCRIPT_DIR/$target"
    else
        echo "Directory $target already exists."
        read -p "Do you want to update it? (y/n): " update_choice
        if [[ "$update_choice" == "y" || "$update_choice" == "Y" ]]; then
            echo "Updating $target..."
            (cd "$SCRIPT_DIR/$target" && git pull)
        fi
    fi
}

main() {
    check_brew
    install_squirrel

    local target=""
    
    if [ $# -gt 0 ]; then
        target="$1"
    else
        echo ""
        echo "Choose Rime configuration to setup and link:"
        echo "1) rime-ice"
        echo "2) rime-frost"
        read -p "Enter choice (1 or 2): " choice
        case $choice in
            1) target="rime-ice" ;;
            2) target="rime-frost" ;;
            *) echo "Invalid choice"; exit 1 ;;
        esac
    fi

    setup_config "$target"
    
    local full_target="$SCRIPT_DIR/$target"
    link_rime "$full_target"

    echo ""
    echo "Setup complete!"
    echo "Squirrel is installed and $target is linked to $RIME_DIR"
    echo "Please restart Squirrel or reload configuration to apply changes"
}

main "$@"
