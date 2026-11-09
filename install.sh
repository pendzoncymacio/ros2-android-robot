#!/bin/bash

# Kolory dla lepszej czytelności
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ROZPOZNAWANIE ŚRODOWISKA: Sprawdzamy, czy jesteśmy w Termuxie, czy już w Ubuntu
if [ -d "$PREFIX" ] && [ ! -f /.dockerenv ]; then
    # ====================================================================
    # FAZA A: URUCHOMIENIE W TERMUXIE (ANDROID)
    # ====================================================================
    echo -e "${BLUE}=== FAZA A: KONFIGURACJA KONTENERA NA DYŚKU ===${NC}"
    mkdir -p $HOME/ubuntu_robot
    proot-distro remove ubuntu 2>/dev/null || true
    PROOT_DISTRO_ROOTFS="$HOME/ubuntu_robot" proot-distro install ubuntu
    
    # Aktualizacja skrótów startowych w Termuxie
    sed -i '/wejdz-ros/d' ~/.bashrc 2>/dev/null || true
    sed -i '/start-agent/d' ~/.bashrc 2>/dev/null || true
    
    echo "alias wejdz-ros='PROOT_DISTRO_ROOTFS=\$HOME/ubuntu_robot proot-distro login ubuntu'" >> ~/.bashrc
    echo "alias start-agent='PROOT_DISTRO_ROOTFS=\$HOME/ubuntu_robot proot-distro login ubuntu -- ros2 run micro_ros_agent micro_ros_agent udp4 --port 8888'" >> ~/.bashrc
    
    echo -e "${GREEN}✓ Faza A zakończona! Automatyczne logowanie do Ubuntu...${NC}"
    sleep 2
    PROOT_DISTRO_ROOTFS="$HOME/ubuntu_robot" proot-distro login ubuntu
    
else
    # ====================================================================
    # FAZA B: URUCHOMIENIE W UBUNTU (PROMPT root@localhost)
    # ====================================================================
    echo -e "${BLUE}=== FAZA B: INSTALACJA STABILNEGO ROS 2 HUMBLE ===${NC}"
    
    # 1. Dodawanie oficjalnych kluczy i repozytoriów ROS 2
    echo -e "${GREEN}[1/4] Konfiguracja repozytoriów dla wersji Humble...${NC}"
    apt update && apt install curl software-properties-common git -y
    add-apt-repository universe -y
    curl -sSL https://githubusercontent.com -o /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://ros.org jammy main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
    
    # 2. Pobieranie systemu ROS 2 Humble prosto na dysk telefonu
    echo -e "${GREEN}[2/4] Instalacja pakietów ROS 2 Humble...${NC}"
    apt update
    apt install ros-humble-ros-base python3-colcon-common-extensions -y
    
    # 3. Budowanie Agenta micro-ROS ze sprawdzonym adresem z dokumentacji
    echo -e "${GREEN}[3/4] Pobieranie i kompilacja Agenta micro-ROS...${NC}"
    source /opt/ros/humble/setup.bash
    mkdir -p ~/microros_ws/src
    cd ~/microros_ws/src
    if [ ! -d "micro-ros_setup" ]; then
        git clone -b humble https://github.com
    fi
    cd ~/microros_ws
    colcon build
    source install/local_setup.bash
    ros2 run micro_ros_setup create_agent_ws.sh
    ros2 run micro_ros_setup build_agent.sh
    
    # 4. Automatyzacja zmiennych środowiskowych w Ubuntu
    echo -e "${GREEN}[4/4] Konfiguracja autostartu środowiska...${NC}"
    sed -i '/setup.bash/d' ~/.bashrc 2>/dev/null || true
    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
    echo "source ~/microros_ws/install/local_setup.bash" >> ~/.bashrc
    
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN} SUCCESS: PEŁNA INSTALACJA NA DYSKU ZAKOŃCZONA!     ${NC}"
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${BLUE}Wpisz słowo: exit, a następnie zrestartuj Termuxa.${NC}"
fi

