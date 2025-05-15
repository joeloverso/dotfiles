#!/bin/bash

# Function to check if an NVIDIA GPU is detected
nvidia_detected() {
    if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
        return 0
    else
        return 1
    fi
}

# Enable the solopasha/hyprland COPR repository
sudo dnf copr enable -y solopasha/hyprland

if nvidia_detected; then
    # Install hyprland-nvidia-git and nvidia automatically if an NVIDIA GPU is detected
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
   
fi
sudo dnf install -y hyprland cliphist xdg-desktop-portal-hyprland swww grimblast

# Return to the previous directory
cd ..
