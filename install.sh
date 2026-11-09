#!/bin/bash

# Kolory dla lepszej czytelności
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# ROZPOZNAWANIE ŚRODOWISKA: Sprawdzamy, czy jesteśmy w Termuxie, czy już w Ubuntu
if [ -d "$PREFIX" ] && [ ! -f /.dockerenv ]; then
    # ====================================================================
    # FAZA A: URUCHOMIENIE W TERMUXIE (NA POZIOMIE DOLARA ~ $)
    # ====================================================================
    echo -e "${BLUE}=== FAZA A: KONFIGURACJA DYSKU I KONTENERA (ANDROID) ===${NC}"
    
    # 1. Żądanie dostępu do pamięci fizycznej telefonu
    echo -e "${GREEN}[1/4] Sprawdzanie uprawnień do pamięci dyskowej...${NC}"
    termux-setup-storage
    sleep 2 # Czas na kliknięcie "Zezwól" na ekranie
    
    # 2. Tworzenie trwałego katalogu na dysku telefonu
    echo -e "${GREEN}[2/4] Tworzenie stałego folderu na dysku flash...${NC}"
    mkdir -p $HOME/storage/shared/ubuntu_robot
    
    # 3. Czyszczenie starych wirtualnych wpisów z pamięci RAM
    echo -e "${GREEN}[3/4] Czyszczenie bazy kontenerów...${NC}"
    proot-distro remove ubuntu 2>/dev/null || true
    
    # 4. Instalacja czystego Ubuntu bezpośrednio na dysku urządzenia
    echo -e "${GREEN}[4/4] Instalacja Ubuntu na dysku (to zajmie chwilę)...${NC}"
    PROOT_DISTRO_ROOTFS="$HOME/storage/shared/ubuntu_robot" proot-distro install ubuntu
    
    # 5. Aktualizacja skrótu "wejdz-ros" w Termuxie
    sed -i '/wejdz-ros/d' ~/.bashrc 2>/dev/null || true
    sed -i '/start-agent/d' ~/.bashrc 2>/dev/null || true
    sed -i '/start-foxglove/d' ~/.bashrc 2>/dev/null || true
    
    echo "alias wejdz-ros='PROOT_DISTRO_ROOTFS=\$HOME/storage/shared/ubuntu_robot proot-distro login ubuntu'" >> ~/.bashrc
    echo "alias start-agent='PROOT_DISTRO_ROOTFS=\$HOME/storage/shared/ubuntu_robot proot-distro login ubuntu -- ros2 run micro_ros_agent micro_ros_agent udp4 --port 8888'" >> ~/.bashrc
    echo "alias start-foxglove='PROOT_DISTRO_ROOTFS=\$HOME/storage/shared/ubuntu_robot proot-distro login ubuntu -- ros2 launch foxglove_bridge foxglove_bridge_launch.xml'" >> ~/.bashrc
    
    echo -e "${GREEN}✓ Faza A zakończona pomyślnie! Folder na dysku został utworzony.${NC}"
    echo -e "${BLUE}Za chwilę nastąpi automatyczne zalogowanie do Ubuntu.${NC}"
    echo -e "${BLUE}Gdy zobaczysz znak 'root@localhost', wklej tę samą komendę curla jeszcze raz, aby dokończyć instalację ROS 2!${NC}"
    sleep 3
    
    # Automatyczne wejście do nowego Ubuntu
    PROOT_DISTRO_ROOTFS="$HOME/storage/shared/ubuntu_robot" proot-distro login ubuntu
    
else
    # ====================================================================
    # FAZA B: URUCHOMIENIE W UBUNTU (NA POZIOMIE PROMPTU root@localhost)
    # ====================================================================
    echo -e "${BLUE}=== FAZA B: INSTALACJA PAKIETÓW ROBOTYCZNYCH ROS 2 (UBUNTU) ===${NC}"
    
    # 1. Dodawanie oficjalnych kluczy i repozytoriów ROS 2
    echo -e "${GREEN}[1/4] Konfiguracja zabezpieczeń i kluczy archiwum ROS 2...${NC}"
    apt update && apt install curl software-properties-common git -y
    add-apt-repository universe -y
    curl -sSL https://githubusercontent.com -o /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://ros.org noble main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
    
    # 2. Pobieranie właściwego systemu ROS 2 Jazzy oraz Foxglove Bridge na dysk
    echo -e "${GREEN}[2/4] Pobieranie oprogramowania ROS 2 Jazzy z serwerów oficjalnych...${NC}"
    apt update
    apt install ros-jazzy-ros-base ros-jazzy-foxglove-bridge python3-colcon-common-extensions -y
    
    # 3. Budowanie/Kompilacja Agenta micro-ROS wewnątrz Ubuntu
    echo -e "${GREEN}[3/4] Kompilacja Agenta micro-ROS dla mikrokontrolera... Może to potrwać kilka minut.${NC}"
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
    
    # 4. Dodawanie automatycznego ładowania ścieżek do profilu Ubuntu
    echo -e "${GREEN}[4/4] Automatyzacja zmiennych środowiskowych...${NC}"
    sed -i '/setup.bash/d' ~/.bashrc 2>/dev/null || true
    echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
    echo "source ~/microros_ws/install/local_setup.bash" >> ~/.bashrc
    
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN} SUCCESS: INSTALACJA NA DYSKU URZĄDZENIA ZAKOŃCZONA! ${NC}"
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${BLUE}Wpisz teraz słowo: exit, a następnie zrestartuj Termuxa.${NC}"
fi
