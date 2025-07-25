#!/bin/sh

# 🚀 OpenCode AI Development Stack - Complete Self-Contained Installer & Manager
# Author: Jason Hempstead <casjay@yahoo.com>
# Description: Single script that installs and manages entire AI development stack
# License: MIT
# Usage: ./opencode.sh [install|clean|reinstall|test|status|start|stop|help]

set -e

# 🎨 Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# 📁 XDG-compliant path definitions
LOCAL_BIN="$HOME/.local/bin"
LOCAL_SHARE="$HOME/.local/share"
CONFIG_DIR="$HOME/.config"
MODELS_DIR="$LOCAL_SHARE/models"
OLLAMA_MODELS="$MODELS_DIR/ollama"
IMAGE_MODELS="$MODELS_DIR/images"
TTS_MODELS="$MODELS_DIR/tts"

# 🔧 Component URLs and versions
OPENCODE_REPO="opencode-ai/opencode"
OLLAMA_URL="https://ollama.com/download/ollama-linux-amd64"
PIPER_REPO="rhasspy/piper"

# 🎯 User information
USER_NAME="Jason Hempstead"
USER_EMAIL="casjay@yahoo.com"

# Global variables for selected models
SELECTED_LLM=""
SELECTED_IMAGE=""
SELECTED_TTS=""

# ═══════════════════════════════════════════════════════════════════════════════
# 🎨 UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

print_banner() {
    printf '%b%s%b\n' "${CYAN}${BOLD}" "
╔══════════════════════════════════════════════════════════════════════════════╗
║                    🚀 OpenCode AI Stack Manager 🚀                          ║
║                                                                              ║
║  🤖 OpenCode AI    📦 Ollama         🎨 OpenDiffusion                       ║
║  🌐 OpenWebUI      🗣️  Piper TTS     ⚡ Continue VSCode                     ║
╚══════════════════════════════════════════════════════════════════════════════╝
" "${NC}"
}

print_separator() {
    printf '%b%s%b\n' "${PURPLE}" "════════════════════════════════════════════════════════════════════════════════" "${NC}"
}

print_step() {
    printf '%b%s%b %s\n' "${YELLOW}${BOLD}" "[$1]" "${NC}" "$2"
}

print_success() {
    printf '%b%s%b %s\n' "${GREEN}${BOLD}" "✅" "${NC}" "$1"
}

print_info() {
    printf '%b%s%b %s\n' "${BLUE}${BOLD}" "ℹ️ " "${NC}" "$1"
}

print_warning() {
    printf '%b%s%b %s\n' "${YELLOW}${BOLD}" "⚠️ " "${NC}" "$1"
}

print_error() {
    printf '%b%s%b %s\n' "${RED}${BOLD}" "❌" "${NC}" "$1" >&2
}

show_help() {
    print_banner
    printf '%s\n' ""
    printf '%b%s%b\n' "${YELLOW}${BOLD}" "Available Commands:" "${NC}"
    printf '%s\n' ""
    printf '%b%s%b %s\n' "${GREEN}" "install" "${NC}" "    🚀 Install the complete OpenCode AI development stack"
    printf '%b%s%b %s\n' "${GREEN}" "clean" "${NC}" "      🧹 Remove all installed components and data"
    printf '%b%s%b %s\n' "${GREEN}" "reinstall" "${NC}" "  🔄 Clean and reinstall everything"
    printf '%b%s%b %s\n' "${GREEN}" "test" "${NC}" "       🧪 Test the installation"
    printf '%b%s%b %s\n' "${GREEN}" "status" "${NC}" "     📊 Show current installation status"
    printf '%b%s%b %s\n' "${GREEN}" "start" "${NC}" "      ▶️  Start all services"
    printf '%b%s%b %s\n' "${GREEN}" "stop" "${NC}" "       ⏹️  Stop all services"
    printf '%b%s%b %s\n' "${GREEN}" "help" "${NC}" "       📖 Show this help message"
    printf '%s\n' ""
    printf '%b%s%b\n' "${CYAN}" "Examples:" "${NC}"
    printf '%s\n' "  ./opencode.sh install     # Full installation"
    printf '%s\n' "  ./opencode.sh status      # Check status"
    printf '%s\n' "  ./opencode.sh start       # Start all services"
    printf '%s\n' ""
}
# ═══════════════════════════════════════════════════════════════════════════════
# 🖥️  SYSTEM DETECTION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

detect_architecture() {
    arch=$(uname -m)
    case "$arch" in
    x86_64) printf '%s\n' "amd64" ;;
    aarch64 | arm64) printf '%s\n' "arm64" ;;
    armv7l) printf '%s\n' "armv7" ;;
    *) printf '%s\n' "amd64" ;;
    esac
}

detect_gpu() {
    gpu_type="none"

    # Check for NVIDIA GPU
    if command -v nvidia-smi >/dev/null 2>&1 || lspci 2>/dev/null | grep -i nvidia | grep -q VGA; then
        gpu_type="nvidia"
    # Check for AMD GPU
    elif lspci 2>/dev/null | grep -i amd | grep -q VGA; then
        gpu_type="amd"
    # Check for Intel integrated graphics
    elif [ -d "/dev/dri" ] && ls /dev/dri/card* >/dev/null 2>&1; then
        gpu_type="integrated"
    fi

    printf '%s\n' "$gpu_type"
}

select_models() {
    gpu_type="$1"

    case "$gpu_type" in
    nvidia)
        SELECTED_LLM="codellama:13b-instruct"
        SELECTED_IMAGE="dreamshaper-v7"
        SELECTED_TTS="en-us-libritts-high.onnx"
        ;;
    amd)
        SELECTED_LLM="llama2:13b"
        SELECTED_IMAGE="deliberate-v2"
        SELECTED_TTS="en-us-amy-high.onnx"
        ;;
    *)
        SELECTED_LLM="llama2:7b"
        SELECTED_IMAGE="dreamlike-diffusion-1.0"
        SELECTED_TTS="en-us-amy-low.onnx"
        ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# 📁 DIRECTORY SETUP FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

create_directories() {
    print_step "SETUP" "Creating directory structure 📁"

    # Create all required directories
    mkdir -p "$LOCAL_BIN"
    mkdir -p "$CONFIG_DIR/opencode"
    mkdir -p "$OLLAMA_MODELS"
    mkdir -p "$IMAGE_MODELS"
    mkdir -p "$TTS_MODELS"
    mkdir -p "$LOCAL_SHARE/openwebui"

    print_info "Created directory structure"

    # Ensure ~/.local/bin is in PATH
    if ! printf '%s\n' "$PATH" | grep -q "$LOCAL_BIN"; then
        printf '%s\n' 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.bashrc"
        export PATH="$LOCAL_BIN:$PATH"
        print_info "Added ~/.local/bin to PATH"
    fi

    print_success "Directory structure created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🤖 OPENCODE AI INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

install_opencode() {
    print_step "OPENCODE" "Installing OpenCode AI 🤖"

    arch=$(detect_architecture)
    opencode_bin="$LOCAL_BIN/opencode"

    # Skip if already installed and working
    if [ -x "$opencode_bin" ]; then
        print_info "OpenCode already installed, skipping"
        return 0
    fi

    # Get latest release info
    release_url=$(curl -s "https://api.github.com/repos/$OPENCODE_REPO/releases/latest" |
        grep "browser_download_url.*linux.*$arch" |
        cut -d '"' -f 4 | head -1)

    if [ -z "$release_url" ]; then
        print_error "Failed to find OpenCode release for architecture: $arch"
        return 1
    fi

    # Download and install
    temp_file="/tmp/opencode-$arch.tar.gz"
    curl -L "$release_url" -o "$temp_file"

    # Extract to temporary directory
    temp_dir="/tmp/opencode-extract"
    mkdir -p "$temp_dir"
    tar -xzf "$temp_file" -C "$temp_dir" --strip-components=1

    # Find the binary and copy it
    find "$temp_dir" -name "opencode" -type f -executable -exec cp {} "$opencode_bin" \;
    chmod +x "$opencode_bin"

    # Cleanup
    rm -rf "$temp_file" "$temp_dir"

    if [ -x "$opencode_bin" ]; then
        print_success "OpenCode AI installed successfully"
    else
        print_error "OpenCode installation failed"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# 📦 OLLAMA INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

install_ollama() {
    print_step "OLLAMA" "Installing Ollama 📦"

    ollama_bin="$LOCAL_BIN/ollama"

    # Skip if already installed
    if [ -x "$ollama_bin" ]; then
        print_info "Ollama already installed, skipping"
    else
        # Download and install Ollama
        curl -L "$OLLAMA_URL" -o "$ollama_bin"
        chmod +x "$ollama_bin"
        print_success "Ollama binary installed"
    fi

    # Start Ollama service if not running
    if ! pgrep -f "ollama serve" >/dev/null; then
        print_info "Starting Ollama service..."
        OLLAMA_MODELS="$OLLAMA_MODELS" nohup "$ollama_bin" serve >/dev/null 2>&1 &
        sleep 3
    fi

    # Pull the selected model
    print_info "Pulling language model: $SELECTED_LLM"
    OLLAMA_MODELS="$OLLAMA_MODELS" "$ollama_bin" pull "$SELECTED_LLM"

    print_success "Ollama setup completed"
}
# ═══════════════════════════════════════════════════════════════════════════════
# 🗣️  PIPER TTS INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

install_piper() {
    print_step "PIPER" "Installing Piper TTS 🗣️"

    arch=$(detect_architecture)
    piper_bin="$LOCAL_BIN/piper"

    # Skip if already installed
    if [ -x "$piper_bin" ]; then
        print_info "Piper already installed, skipping binary"
    else
        # Get latest Piper release
        release_url=$(curl -s "https://api.github.com/repos/$PIPER_REPO/releases/latest" |
            grep "browser_download_url.*linux.*$arch" |
            cut -d '"' -f 4 | head -1)

        if [ -z "$release_url" ]; then
            print_error "Failed to find Piper release for architecture: $arch"
            return 1
        fi

        # Download and extract
        temp_file="/tmp/piper-$arch.tar.gz"
        curl -L "$release_url" -o "$temp_file"

        temp_dir="/tmp/piper-extract"
        mkdir -p "$temp_dir"
        tar -xzf "$temp_file" -C "$temp_dir"

        # Find and copy the binary
        find "$temp_dir" -name "piper" -type f -executable -exec cp {} "$piper_bin" \;
        chmod +x "$piper_bin"

        # Cleanup
        rm -rf "$temp_file" "$temp_dir"

        print_success "Piper TTS binary installed"
    fi

    # Download TTS model if not exists
    model_file="$TTS_MODELS/$SELECTED_TTS"
    if [ ! -f "$model_file" ]; then
        print_info "Downloading TTS model: $SELECTED_TTS"
        model_url="https://github.com/rhasspy/piper/releases/download/v1.2.0/$SELECTED_TTS"
        curl -L "$model_url" -o "$model_file"
        print_success "TTS model downloaded"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🐳 DOCKER CONTAINER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker is required but not installed"
        print_info "Please install Docker: sudo pacman -S docker"
        return 1
    fi

    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running or accessible"
        print_info "Please start Docker: sudo systemctl start docker"
        return 1
    fi

    return 0
}

install_openwebui() {
    print_step "OPENWEBUI" "Setting up OpenWebUI 🌐"

    if ! check_docker; then
        return 1
    fi

    container_name="openwebui"
    image="ghcr.io/open-webui/open-webui:main"

    # Remove existing container if it exists
    if docker ps -a --format "table {{.Names}}" | grep -q "^$container_name$"; then
        print_info "Removing existing OpenWebUI container"
        docker stop "$container_name" >/dev/null 2>&1 || true
        docker rm "$container_name" >/dev/null 2>&1 || true
    fi

    # Create and start new container
    docker run -d \
        --name "$container_name" \
        --restart unless-stopped \
        -p 3000:8080 \
        -v "$LOCAL_SHARE/openwebui:/app/data" \
        -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
        -e ENABLE_OLLAMA_API=true \
        -e WEBUI_AUTH=false \
        --add-host=host.docker.internal:host-gateway \
        "$image"

    print_success "OpenWebUI container started on port 3000"
}

install_opendiffusion() {
    print_step "DIFFUSION" "Setting up OpenDiffusion 🎨"

    if ! check_docker; then
        return 1
    fi

    container_name="opendiffusion"
    image="ghcr.io/casjaysdevdocker/opendiffusion:latest"

    # Remove existing container if it exists
    if docker ps -a --format "table {{.Names}}" | grep -q "^$container_name$"; then
        print_info "Removing existing OpenDiffusion container"
        docker stop "$container_name" >/dev/null 2>&1 || true
        docker rm "$container_name" >/dev/null 2>&1 || true
    fi

    # Create and start new container
    docker run -d \
        --name "$container_name" \
        --restart unless-stopped \
        -p 7860:7860 \
        -v "$IMAGE_MODELS:/models" \
        "$image"

    print_success "OpenDiffusion container started on port 7860"
}

# ═══════════════════════════════════════════════════════════════════════════════
# ⚡ VSCODE CONTINUE EXTENSION
# ═══════════════════════════════════════════════════════════════════════════════

install_continue_extension() {
    print_step "CONTINUE" "Installing Continue VSCode Extension ⚡"

    if ! command -v code >/dev/null 2>&1; then
        print_warning "VSCode not found, skipping Continue extension"
        return 0
    fi

    # Install the extension
    code --install-extension continue.continue --force
    print_success "Continue extension installed"
}
# ═══════════════════════════════════════════════════════════════════════════════
# ⚙️  CONFIGURATION GENERATION
# ═══════════════════════════════════════════════════════════════════════════════

generate_opencode_config() {
    print_step "CONFIG" "Generating OpenCode configuration ⚙️"

    config_file="$CONFIG_DIR/opencode/config.json"

    # Create OpenCode config
    cat >"$config_file" <<EOF
{
  "llm": {
    "provider": "openai",
    "api_key": "ollama-placeholder",
    "base_url": "http://localhost:11434/v1",
    "model": "$SELECTED_LLM"
  },
  "image_generator": {
    "provider": "sd",
    "base_url": "http://localhost:7860",
    "model": "$SELECTED_IMAGE"
  },
  "features": {
    "code_interpreter": false,
    "vectorstore": false
  },
  "user": {
    "name": "$USER_NAME",
    "email": "$USER_EMAIL"
  },
  "telemetry": {
    "enabled": false
  },
  "theme": "dracula",
  "editor": "code",
  "project_defaults": {
    "language": "bash",
    "workspace": "~/Projects/opencode"
  }
}
EOF

    print_success "OpenCode configuration generated"
}

create_desktop_file() {
    print_step "DESKTOP" "Creating desktop launcher 🖥️"

    desktop_file="$HOME/.local/share/applications/opencode.desktop"
    mkdir -p "$(dirname "$desktop_file")"

    cat >"$desktop_file" <<EOF
[Desktop Entry]
Name=OpenCode AI
Comment=AI-powered development environment
Exec=$LOCAL_BIN/opencode
Icon=code
Terminal=true
Type=Application
Categories=Development;IDE;
StartupNotify=true
EOF

    chmod +x "$desktop_file"
    print_success "Desktop launcher created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🧪 VERIFICATION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

verify_installation() {
    print_step "VERIFY" "Verifying installation 🧪"

    issues=0

    # Check binaries
    if [ ! -x "$LOCAL_BIN/opencode" ]; then
        print_error "OpenCode binary not found"
        issues=$((issues + 1))
    fi

    if [ ! -x "$LOCAL_BIN/ollama" ]; then
        print_error "Ollama binary not found"
        issues=$((issues + 1))
    fi

    if [ ! -x "$LOCAL_BIN/piper" ]; then
        print_error "Piper binary not found"
        issues=$((issues + 1))
    fi

    # Check containers
    if command -v docker >/dev/null 2>&1; then
        if ! docker ps --format "table {{.Names}}" | grep -q "openwebui"; then
            print_error "OpenWebUI container not running"
            issues=$((issues + 1))
        fi

        if ! docker ps --format "table {{.Names}}" | grep -q "opendiffusion"; then
            print_error "OpenDiffusion container not running"
            issues=$((issues + 1))
        fi
    fi

    # Check config files
    if [ ! -f "$CONFIG_DIR/opencode/config.json" ]; then
        print_error "OpenCode config not found"
        issues=$((issues + 1))
    fi

    if [ $issues -eq 0 ]; then
        print_success "All components verified successfully!"
        return 0
    else
        print_error "Found $issues issues during verification"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 MAIN INSTALLATION FUNCTION
# ═══════════════════════════════════════════════════════════════════════════════

cmd_install() {
    # Clear screen and show banner
    clear
    print_banner
    print_separator

    print_info "Starting OpenCode AI stack installation..."
    printf '%s\n' ""

    # System detection
    print_step "DETECT" "Detecting system configuration 🔍"
    arch=$(detect_architecture)
    gpu_type=$(detect_gpu)

    print_info "Architecture: $arch"
    print_info "GPU Type: $gpu_type"

    # Select appropriate models
    select_models "$gpu_type"
    print_info "Selected LLM: $SELECTED_LLM"
    print_info "Selected Image Model: $SELECTED_IMAGE"
    print_info "Selected TTS Model: $SELECTED_TTS"
    printf '%s\n' ""

    print_separator

    # Execute installation steps
    create_directories
    print_separator

    install_opencode
    print_separator

    install_ollama
    print_separator

    install_piper
    print_separator

    install_openwebui
    print_separator

    install_opendiffusion
    print_separator

    install_continue_extension
    print_separator

    generate_opencode_config
    print_separator

    create_desktop_file
    print_separator

    # Final verification
    if verify_installation; then
        printf '%s\n' ""
        print_separator
        printf '%b%s%b\n' "${GREEN}${BOLD}" "
🎉 INSTALLATION COMPLETE! 🎉

Your OpenCode AI development stack is ready:

🤖 OpenCode AI:     Run 'opencode' in terminal
🌐 OpenWebUI:       http://localhost:3000
🎨 OpenDiffusion:   http://localhost:7860
📦 Ollama:          Running with model '$SELECTED_LLM'
🗣️  Piper TTS:      Configured with '$SELECTED_TTS'
⚡ Continue:        Available in VSCode

Happy coding! 🚀
" "${NC}"
        print_separator
    else
        printf '%b%s%b\n' "${RED}${BOLD}" "
❌ Installation completed with issues.
Please check the error messages above and retry.
" "${NC}"
        return 1
    fi
}
# ═══════════════════════════════════════════════════════════════════════════════
# 🧹 CLEANUP FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

cmd_clean() {
    printf '%b%s%b\n' "${YELLOW}${BOLD}" "🧹 Cleaning OpenCode AI stack..." "${NC}"
    printf '%b%s%b\n' "${RED}" "⚠️  This will remove all AI models and configurations!" "${NC}"
    printf '%s' "Are you sure? (y/N): "
    read -r confirm

    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        print_info "Operation cancelled"
        return 0
    fi

    # Stop and remove Docker containers
    docker stop openwebui opendiffusion >/dev/null 2>&1 || true
    docker rm openwebui opendiffusion >/dev/null 2>&1 || true
    print_success "Docker containers removed"

    # Remove binaries
    rm -f "$LOCAL_BIN/opencode" "$LOCAL_BIN/ollama" "$LOCAL_BIN/piper"
    print_success "Binaries removed"

    # Remove data directories
    rm -rf "$LOCAL_SHARE/models"
    rm -rf "$LOCAL_SHARE/openwebui"
    rm -rf "$CONFIG_DIR/opencode"
    print_success "Data directories removed"

    # Remove desktop file
    rm -f "$HOME/.local/share/applications/opencode.desktop"
    print_success "Desktop launcher removed"

    # Uninstall VSCode extension
    command -v code >/dev/null 2>&1 && code --uninstall-extension continue.continue >/dev/null 2>&1 || true
    print_success "Continue extension removed"

    printf '%b%s%b\n' "${GREEN}${BOLD}" "🧹 Cleanup completed!" "${NC}"
}

cmd_reinstall() {
    printf '%b%s%b\n' "${YELLOW}${BOLD}" "🔄 Reinstalling OpenCode AI stack..." "${NC}"
    cmd_clean
    cmd_install
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🧪 TESTING FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

cmd_test() {
    printf '%b%s%b\n' "${YELLOW}${BOLD}" "🧪 Testing OpenCode AI stack..." "${NC}"

    # Test binaries
    printf '%b%s%b\n' "${CYAN}" "Testing binaries..." "${NC}"
    if [ -x "$LOCAL_BIN/opencode" ]; then
        print_success "OpenCode binary found"
    else
        print_error "OpenCode binary missing"
    fi

    if [ -x "$LOCAL_BIN/ollama" ]; then
        print_success "Ollama binary found"
    else
        print_error "Ollama binary missing"
    fi

    if [ -x "$LOCAL_BIN/piper" ]; then
        print_success "Piper binary found"
    else
        print_error "Piper binary missing"
    fi

    # Test Docker containers
    printf '%b%s%b\n' "${CYAN}" "Testing Docker containers..." "${NC}"
    if docker ps --format "table {{.Names}}" | grep -q openwebui; then
        print_success "OpenWebUI container running"
    else
        print_error "OpenWebUI container not running"
    fi

    if docker ps --format "table {{.Names}}" | grep -q opendiffusion; then
        print_success "OpenDiffusion container running"
    else
        print_error "OpenDiffusion container not running"
    fi

    # Test configuration files
    printf '%b%s%b\n' "${CYAN}" "Testing configuration files..." "${NC}"
    if [ -f "$CONFIG_DIR/opencode/config.json" ]; then
        print_success "OpenCode config found"
    else
        print_error "OpenCode config missing"
    fi

    # Test network connectivity
    printf '%b%s%b\n' "${CYAN}" "Testing network connectivity..." "${NC}"
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        print_success "OpenWebUI responding"
    else
        print_error "OpenWebUI not responding"
    fi

    if curl -s http://localhost:7860 >/dev/null 2>&1; then
        print_success "OpenDiffusion responding"
    else
        print_error "OpenDiffusion not responding"
    fi

    if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
        print_success "Ollama API responding"
    else
        print_error "Ollama API not responding"
    fi

    printf '%b%s%b\n' "${GREEN}${BOLD}" "🧪 Testing completed!" "${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# 📊 STATUS FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

cmd_status() {
    printf '%b%s%b\n' "${CYAN}${BOLD}" "📊 OpenCode AI Stack Status" "${NC}"
    printf '%b%s%b\n' "${CYAN}" "═══════════════════════════════" "${NC}"

    # System information
    printf '%b%s%b\n' "${YELLOW}" "System Information:" "${NC}"
    printf '%s\n' "  Architecture: $(uname -m)"
    printf '%s\n' "  Kernel: $(uname -r)"
    if command -v lsb_release >/dev/null 2>&1; then
        printf '%s\n' "  Distribution: $(lsb_release -d 2>/dev/null | cut -d: -f2 | sed 's/^[[:space:]]*//')"
    else
        printf '%s\n' "  Distribution: Unknown"
    fi
    printf '%s\n' ""

    # Binary status
    printf '%b%s%b\n' "${YELLOW}" "Installed Binaries:" "${NC}"
    if [ -x "$LOCAL_BIN/opencode" ]; then
        printf '%s\n' "  ✅ OpenCode AI"
    else
        printf '%s\n' "  ❌ OpenCode AI"
    fi

    if [ -x "$LOCAL_BIN/ollama" ]; then
        printf '%s\n' "  ✅ Ollama"
    else
        printf '%s\n' "  ❌ Ollama"
    fi

    if [ -x "$LOCAL_BIN/piper" ]; then
        printf '%s\n' "  ✅ Piper TTS"
    else
        printf '%s\n' "  ❌ Piper TTS"
    fi
    printf '%s\n' ""

    # Docker container status
    printf '%b%s%b\n' "${YELLOW}" "Docker Containers:" "${NC}"
    if command -v docker >/dev/null 2>&1; then
        if docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null | grep -E "(openwebui|opendiffusion)" >/dev/null; then
            docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null | grep -E "(openwebui|opendiffusion)" | while read -r line; do
                name=$(printf '%s\n' "$line" | awk '{print $1}')
                status=$(printf '%s\n' "$line" | awk '{print $2}')
                if [ "$status" = "Up" ]; then
                    printf '%s\n' "  ✅ $name - Running"
                else
                    printf '%s\n' "  ❌ $name - Stopped"
                fi
            done
        else
            printf '%s\n' "  ❌ No containers found"
        fi
    else
        printf '%s\n' "  ❌ Docker not available"
    fi
    printf '%s\n' ""

    # Service URLs
    printf '%b%s%b\n' "${YELLOW}" "Service URLs:" "${NC}"
    printf '%s\n' "  🌐 OpenWebUI: http://localhost:3000"
    printf '%s\n' "  🎨 OpenDiffusion: http://localhost:7860"
    printf '%s\n' "  📦 Ollama API: http://localhost:11434"
    printf '%s\n' ""

    # Model information
    printf '%b%s%b\n' "${YELLOW}" "Installed Models:" "${NC}"
    if [ -d "$LOCAL_SHARE/models" ]; then
        ollama_count=$(find "$LOCAL_SHARE/models" -name "*.bin" 2>/dev/null | wc -l)
        tts_count=$(find "$LOCAL_SHARE/models" -name "*.onnx" 2>/dev/null | wc -l)
        printf '%s\n' "  📦 Ollama models: $ollama_count"
        printf '%s\n' "  🗣️  TTS models: $tts_count"
    else
        printf '%s\n' "  📦 Ollama models: 0"
        printf '%s\n' "  🗣️  TTS models: 0"
    fi
    printf '%s\n' " "
}
printf '%s\n' "  ❌ Still working on everything "
exit 1
