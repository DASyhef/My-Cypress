#!/usr/bin/env bash
set -e

echo "=== Vérification et installation des prérequis ==="

# 1. Détection de l'OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     OS_NAME=Linux;;
    Darwin*)    OS_NAME=macOS;;
    *)          OS_NAME="UNKNOWN:${OS}"
esac
echo "Système détecté : $OS_NAME"

# 2. Vérification / Installation de Task (Go-Task)
if ! command -v task &> /dev/null; then
    echo "[!] Task n'est pas installé. Installation en cours..."
    if [ "$OS_NAME" = "Linux" ]; then
        if command -v snap &> /dev/null; then
            sudo snap install task --classic
        else
            sh -c "$(curl -ssL https://taskfile.dev/install.sh)" -- -b ~/.local/bin
        fi
    elif [ "$OS_NAME" = "macOS" ]; then
        if command -v brew &> /dev/null; then
            brew install go-task/tap/go-task
        else
            sh -c "$(curl -ssL https://taskfile.dev/install.sh)" -- -b ~/.local/bin
        fi
    fi
else
    echo "[✓] Task est installé : $(task --version)"
fi

# 3. Vérification de Flutter
if ! command -v flutter &> /dev/null; then
    echo "[X] Flutter n'est pas installé ou absente du PATH."
    echo "    Veuillez installer Flutter SDK : https://docs.flutter.dev/get-started/install"
    exit 1
else
    echo "[✓] Flutter est installé : $(flutter --version | head -n 1)"
fi

# 4. Vérification de Git
if ! command -v git &> /dev/null; then
    echo "[X] Git n'est pas installé."
    exit 1
else
    echo "[✓] Git est installé : $(git --version)"
fi

# 5. Contrôle global via Flutter Doctor
echo "=== Diagnostic Flutter Doctor ==="
flutter doctor

echo "=== Environnement prêt ==="