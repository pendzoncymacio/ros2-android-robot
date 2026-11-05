#!/bin/bash
set -e

# Kolory dla lepszej czytelności w Termuxie
GREEN='\033[0,32m'
BLUE='\033[0,34m'
NC='\033[0m' # No Color

show_menu() {
    clear
    echo -e "${BLUE}====================================================${NC}"
    echo -e "${GREEN}      INTERAKTYWNY INSTALATOR ROS 2 DLA WARSZTATÓW  ${NC}"
    echo -e "${BLUE}====================================================${NC}"
    echo " Wybierz komponent do instalacji:"
    echo " 1) INSTALACJA AUTOMATYCZNA (Wszystko na raz)"
    echo " ----------------------------------------------------"
    echo " 2) KROK 1: Aktualizacja Termuxa i instalacja Ubuntu"
    echo " 3) KROK 2: Instalacja bazowa ROS 2 Jazzy (w Ubuntu)"
    echo " 4) KROK 3: Kompilacja Agenta micro-ROS (w Ubuntu)"
    echo " 5) KROK 4: Instalacja Foxglove Bridge & Skróty"
    echo " ----------------------------------------------------"
    echo " 6) Wyjście"
    echo -e "${BLUE}====================================================${NC}"
    echo -n "Wpisz numer opcji (1-6): "
}

install_termux_ubuntu() {
    echo -e "${GREEN}[KROK 1] Aktualizacja Termux i instalacja czystego Ubuntu...${NC}"
    pkg update -y && pkg upgrade -y
    pkg install proot-distro git curl -y
    proot-distro install ubuntu
    echo -e "${GREEN}Sukces! Środowisko Ubuntu zostało utworzone.${NC}"
    read -p "Naciśnij Enter, aby wrócić do menu..."
}

install_ros2() {
    if [ ! -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ]; then
        echo "Błąd: Najpierw musisz zainstalować Ubuntu (Krok 1)!"
        read -p "Naciśnij Enter..."
        return
    fi
    echo -e "${GREEN}[KROK 2] Instalacja pakietów ROS 2 Jazzy wewnątrz Ubuntu...${NC}"
    
    cat << 'EOF' > $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/sub_ros.sh
#!/bin/bash
set -e
apt update && apt install locales software-properties-common curl git -y
locale-gen en_US en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

add-apt-repository universe -y
curl -sSL https://githubusercontent.com -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://ros.org noble main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

apt update
apt install ros-jazzy-ros-base python3-colcon-common-extensions -y
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
EOF

    proot-distro login ubuntu -- bash /root/sub_ros.sh
    rm $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/sub_ros.sh
    echo -e "${GREEN}Sukces! ROS 2 Jazzy został zainstalowany.${NC}"
    read -p "Naciśnij Enter, aby wrócić do menu..."
}

install_microros() {
    echo -e "${GREEN}[KROK 3] Budowanie Agenta micro-ROS... To może chwilę potrwać.${NC}"
    cat << 'EOF' > $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/sub_urosc.sh
#!/bin/bash
set -e
source /opt/ros/jazzy/setup.bash
mkdir -p ~/microros_ws/src
cd ~/microros_ws/src
if [ ! -d "micro-ros_setup" ]; then
    git clone -b jazzy https://github.com
fi
cd ~/microros_ws
colcon build
source install/local_setup.bash
ros2 run micro_ros_setup create_agent_ws.sh
ros2 run micro_ros_setup build_agent.sh
echo "source ~/microros_ws/install/local_setup.bash" >> ~/.bashrc
EOF

    proot-distro login ubuntu -- bash /root/sub_urosc.sh
    rm $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/sub_urosc.sh
    echo -e "${GREEN}Sukces! Agent micro-ROS został pomyślnie skompilowany.${NC}"
    read -p "Naciśnij Enter, aby wrócić do menu..."
}

install_foxglove_shortcuts() {
    echo -e "${GREEN}[KROK 4] Instalacja Foxglove Bridge i tworzenie aliasów...${NC}"
    cat << 'EOF' > $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/sub_fox.sh
#!/bin/bash
apt update && apt install ros-jazzy-foxglove-bridge htop -y
EOF
    proot-distro login ubuntu -- bash /root/sub_fox.sh
    rm $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/sub_fox.sh

    # Dodawanie aliasów w Termuxie
    sed -i '/wejdz-ros/d' ~/.bashrc 2>/dev/null || true
    sed -i '/start-agent/d' ~/.bashrc 2>/dev/null || true
    sed -i '/start-foxglove/d' ~/.bashrc 2>/dev/null || true
    
    echo "alias wejdz-ros='proot-distro login ubuntu'" >> ~/.bashrc
    echo "alias start-agent='proot-distro login ubuntu -- ros2 run micro_ros_agent micro_ros_agent udp4 --port 8888'" >> ~/.bashrc
    echo "alias start-foxglove='proot-distro login ubuntu -- ros2 launch foxglove_bridge foxglove_bridge_launch.xml'" >> ~/.bashrc

    echo -e "${GREEN}Sukces! Skróty zostały dodane do systemu Termux.${NC}"
    read -p "Naciśnij Enter, aby wrócić do menu..."
}

# Główna pętla programu
while true; do
    show_menu
    read choice
    case $choice in
        1)
            install_termux_ubuntu
            install_ros2
            install_microros
            install_foxglove_shortcuts
            echo -e "${GREEN}Pełna instalacja zakończona! Zrestartuj Termux.${NC}"
            exit 0
            ;;
        2) install_termux_ubuntu ;;
        3) install_ros2 ;;
        4) install_microros ;;
        5) install_foxglove_shortcuts ;;
        6) clear; echo "Do zobaczenia na warsztatach!"; exit 0 ;;
        *) echo "Nieprawidłowy wybór!"; sleep 1 ;;
    esac
done
