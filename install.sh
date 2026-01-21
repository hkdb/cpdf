#!/usr/bin/env bash

set -e
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "\n"

echo -e "${GREEN}
 ░▒▓██████▓▒░░▒▓███████▓▒░░▒▓███████▓▒░░▒▓████████▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
░▒▓█▓▒░      ░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░   
░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
 ░▒▓██████▓▒░░▒▓█▓▒░      ░▒▓███████▓▒░░▒▓█▓▒░        
     
                   INSTALLATION
${NC}
"

# Detect distro
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID="$ID"
    DISTRO_LIKE="$ID_LIKE"
  elif [ -f /etc/debian_version ]; then
    DISTRO_ID="debian"
  elif [ -f /etc/redhat-release ]; then
    DISTRO_ID="rhel"
  else
    DISTRO_ID="unknown"
  fi

  # Map to package manager type
  if [[ "$DISTRO_ID" == "debian" || "$DISTRO_ID" == "ubuntu" || "$DISTRO_ID" == "linuxmint" || "$DISTRO_ID" == "pop" || "$DISTRO_ID" == "elementary" || "$DISTRO_ID" == "zorin" || "$DISTRO_LIKE" == *"debian"* || "$DISTRO_LIKE" == *"ubuntu"* ]]; then
    PKG_TYPE="debian"
  elif [[ "$DISTRO_ID" == "fedora" || "$DISTRO_ID" == "rhel" || "$DISTRO_ID" == "centos" || "$DISTRO_ID" == "rocky" || "$DISTRO_ID" == "alma" || "$DISTRO_LIKE" == *"fedora"* || "$DISTRO_LIKE" == *"rhel"* ]]; then
    PKG_TYPE="redhat"
  elif [[ "$DISTRO_ID" == "arch" || "$DISTRO_ID" == "manjaro" || "$DISTRO_ID" == "endeavouros" || "$DISTRO_ID" == "cachyos" || "$DISTRO_ID" == "garuda" || "$DISTRO_LIKE" == *"arch"* ]]; then
    PKG_TYPE="arch"
  else
    PKG_TYPE="unknown"
  fi
}

# Check if ghostscript is installed
check_gs_installed() {
  command -v gs &>/dev/null && return 0 || return 1
}

# GitHub repository
GITHUB_REPO="hkdb/cpdf"

# Install ghostscript if missing
install_ghostscript() {
  if check_gs_installed; then
    echo -e "${GREEN}✅️ ghostscript already installed${NC}\n"
    return 0
  fi

  echo -e "${YELLOW}⚠️  Missing dependency: ghostscript${NC}"
  echo ""
  read -p "Would you like to install it now? [y/N] " -n 1 -r
  echo ""

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️  Skipping ghostscript installation. cpdf will not work.${NC}\n"
    return 1
  fi

  echo -e "\n📦️ Installing ghostscript...\n"

  case $PKG_TYPE in
    debian)
      sudo apt-get update
      sudo apt-get install -y ghostscript
      ;;
    redhat)
      sudo dnf install -y ghostscript
      ;;
    arch)
      sudo pacman -Sy --noconfirm ghostscript
      ;;
    *)
      echo -e "${RED}❌️ Unknown distribution. Please install ghostscript manually.${NC}"
      return 1
      ;;
  esac

  if [[ $? -ne 0 ]]; then
    echo -e "${RED}❌️ Failed to install ghostscript${NC}\n"
    return 1
  fi

  echo -e "${GREEN}✅️ ghostscript installed successfully${NC}\n"
  return 0
}

# Detect OS and architecture
detect_platform() {
  # Detect OS
  case "$(uname -s)" in
    Linux*)   OS="linux" ;;
    Darwin*)  OS="macos" ;;
    FreeBSD*) OS="freebsd" ;;
    *)
      echo -e "${RED}❌️ Unsupported operating system: $(uname -s)${NC}"
      echo -e "${YELLOW}For Windows, please use install.bat instead.${NC}"
      return 1
      ;;
  esac

  # Detect architecture
  case "$(uname -m)" in
    x86_64|amd64)  ARCH="x86_64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *)
      echo -e "${RED}❌️ Unsupported architecture: $(uname -m)${NC}"
      return 1
      ;;
  esac

  # Check for unsupported platform
  if [[ "$OS" == "freebsd" && "$ARCH" == "arm64" ]]; then
    echo -e "${RED}❌️ FreeBSD ARM64 binary is not available.${NC}"
    echo -e "${YELLOW}Please build from source: https://github.com/hkdb/cpdf${NC}\n"
    return 1
  fi

  echo -e "📋️ Detected platform: ${OS}-${ARCH}\n"
  return 0
}

# Get cpdf binary (local build or download from GitHub)
get_cpdf_binary() {
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local local_binary="${script_dir}/dist/cpdf"

  # Check for locally compiled binary first
  if [[ -f "$local_binary" ]]; then
    echo -e "${GREEN}✅️ Found locally compiled binary${NC}\n"
    CPDF_BINARY="$local_binary"
    return 0
  fi

  # Detect platform
  detect_platform
  if [[ $? -ne 0 ]]; then
    return 1
  fi

  # Build download URL based on platform
  local binary_name="cpdf-${OS}-${ARCH}"

  local download_url="https://github.com/${GITHUB_REPO}/releases/latest/download/${binary_name}"

  # Download from GitHub releases
  echo -e "📥️ Downloading ${binary_name} from GitHub releases...\n"

  local tmp_dir=$(mktemp -d)

  if command -v curl &>/dev/null; then
    curl -fsSL "$download_url" -o "${tmp_dir}/cpdf"
  elif command -v wget &>/dev/null; then
    wget -q "$download_url" -O "${tmp_dir}/cpdf"
  else
    echo -e "${RED}❌️ Neither curl nor wget found. Please install one of them.${NC}"
    return 1
  fi

  if [[ $? -ne 0 ]]; then
    echo -e "${RED}❌️ Failed to download cpdf from GitHub${NC}\n"
    echo -e "${YELLOW}URL: ${download_url}${NC}\n"
    rm -rf "$tmp_dir"
    return 1
  fi

  chmod +x "${tmp_dir}/cpdf"
  CPDF_BINARY="${tmp_dir}/cpdf"
  TMP_DIR="$tmp_dir"

  echo -e "${GREEN}✅️ Downloaded cpdf successfully${NC}\n"
  return 0
}

# Main installation

detect_distro
echo -e "📋️ Detected package type: ${PKG_TYPE}\n"

echo -e "🔍️ Checking dependencies...\n"
install_ghostscript

echo -e "🔍️ Getting cpdf binary...\n"
get_cpdf_binary
if [[ $? -ne 0 ]]; then
  echo -e "${RED}❌️ Failed to get cpdf binary. Exiting...${NC}\n"
  exit 1
fi

echo -e "✅️ Making sure there's a $HOME/.local/bin...\n"
if [[ ! -d "$HOME/.local/bin" ]]; then
  mkdir -p "$HOME/.local/bin"
  if [[ $? -ne 0 ]]; then
    echo -e "\n${RED}❌️ Failed to create $HOME/.local/bin... Exiting...${NC}\n"
    exit 1
  fi
fi

echo -e "💾️ Installing cpdf to $HOME/.local/bin...\n"
cp "$CPDF_BINARY" "$HOME/.local/bin/cpdf"
chmod +x "$HOME/.local/bin/cpdf"

# Cleanup temp directory if used
if [[ -n "$TMP_DIR" ]]; then
  rm -rf "$TMP_DIR"
fi

echo -e "\n${GREEN}**************"
echo -e " 💯️ COMPLETED"
echo -e "**************${NC}\n"

echo -e "⚠️  Make sure $HOME/.local/bin is already in \$PATH...\n"
