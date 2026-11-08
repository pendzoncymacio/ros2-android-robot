# Projekt Robot ROS 2 dla Młodzieży 📱

Witaj w repozytorium projektu! Poniżej znajdziesz instrukcję, jak krok po kroku przygotować swój telefon lub tablet jako główny "mózg" naszego robota.

---

### 📋 Wymagania techniczne (Przed startem)
Zanim zaczniesz, upewnij się, że Twój telefon spełnia poniższe warunki:
* **System Android:** Wersja 8.0 lub nowsza.
* **Procesor:** 64-bitowy (architektura ARM64) – posiada go 99% współczesnych telefonów.
* **Pamięć:** Minimum 3-4 GB wolnego miejsca na dysku (instalacja Linuksa i ROS 2 zajmuje sporo przestrzeni).
* **Połączenie:** Stabilne Wi-Fi (pobierzemy około 1.5 GB danych).

---

### 🚀 INSTRUKCJA INSTALACJI

#### Krok 1: Pobierz i zainstaluj aplikację Termux
Termux to emulator terminala, który pozwala uruchomić system Linux bezpośrednio na Androidzie. Pobierz dokładnie tę przetestowaną wersję:
👉 **[POBIERZ TERMUX V0.118.1 (ARM64)](https://github.com/termux/termux-app/releases/download/v0.118.3/termux-app_v0.118.3+github-debug_arm64-v8a.apk)**

*Po pobraniu kliknij w plik `.apk`. Jeśli system Android wyświetli ostrzeżenie, wejdź w Ustawienia i wybierz "Zezwól na instalację z tego źródła".*

#### Krok 2: Uruchom Interaktywny Instalator
Otwórz zainstalowaną aplikację Termux. Aby uruchomić instalator w sposób, który pozwoli na bezproblemowe korzystanie z klawiatury ekranowej, skopiuj poniższą komendę w całości i  wklej ją do terminala , lub wpisz a potem naciśnij **Enter**:

```bash
curl -sSL https://raw.githubusercontent.com/pendzoncymacio/ros2-android-robot/refs/heads/main/install.sh -o install.sh && bash install.sh
```

*Wskazówka:* Ta komenda najpierw pobiera skrypt jako plik na Twój telefon, a następnie uruchamia go lokalnie. Dzięki temu menu zatrzyma się na ekranie i będzie grzecznie czekać na Twój wybór (wpisanie cyfry od 1 do 6).

---

### 🏁 Jak uruchomić system po zakończeniu instalacji?

Gdy instalator wyświetli komunikat o sukcesie, **zrestartuj aplikację Termux** (wpisz komendę `exit` lub zamknij aplikację z paska powiadomień Androida). 

Po ponownym otwarciu Termuxa, zamiast wpisywać długie komendy Linuxa, możesz używać przygotowanych skrótów (aliasów):

1. `wejdz-ros` – loguje Cię bezpośrednio do wnętrza systemu Ubuntu 24.04, gdzie zainstalowany jest ROS 2.
2. `start-agent` – uruchamia micro-ROS Agenta, który nasłuchuje na dane z robota przez Wi-Fi (port UDP 8888).
3. `start-foxglove` – uruchamia mostek wizualizacji (serwer dla interfejsu graficznego i wirtualnego joysticka).

---

### 🛠️ Co dokładnie instaluje ten skrypt? (Przewodnik po menu)

Gdy uruchomisz komendę z Kroku 2, zobaczysz menu wyboru. Możesz wybrać instalację automatyczną (opcja 1) lub instalować komponenty po kolei (opcje 2-5), aby zobaczyć jak powstaje system:

* **Opcja 1) INSTALACJA AUTOMATYCZNA:** Uruchamia po kolei wszystkie poniższe kroki bez zadawania pytań. Idealne, jeśli chcesz po prostu mieć gotowe środowisko.
* **Opcja 2) KROK 1: System Ubuntu 24.04 (Noble):** Tworzy na Twoim telefonie bezpieczną, odizolowaną przestrzeń (tzw. kontener proot) z pełnoprawnym systemem operacyjnym Linux Ubuntu. Nie uszkodzi to Twoich plików na telefonie ani systemu Android.
* **Opcja 3) KROK 2: Framework ROS 2 Jazzy:** Instaluje wewnątrz Ubuntu bazową wersję systemu operacyjnego dla robotów (Robot Operating System 2). To zbiór narzędzi, który pozwala na przesyłanie danych z czujników (np. z Lidaru) i sterowanie silnikami za pomocą tzw. "tematów" (topics).
* **Opcja 4) KROK 3: Agent micro-ROS:** Pobiera kod źródłowy i kompiluje specjalny program-most (Agent). Zadaniem tego Agenta jest bezprzewodowe odbieranie danych z mikrokontrolera ESP32 (który fizycznie steruje robotem) i przekazywanie ich bezpośrednio do systemu ROS 2 na telefonie.
* **Opcja 5) KROK 4: Foxglove Bridge & Skróty systemowe:** 
  * Instaluje **Foxglove Bridge** – serwer, który pozwala wyświetlić mapę z Lidaru i wirtualny joystick na ekranie telefonu przez przeglądarkę internetową lub aplikację.
  * Instaluje **htop** – graficzny podgląd wydajności, dzięki któremu zobaczysz, jak bardzo algorytmy robota obciążają procesor Twojego telefonu.
  * Tworzy **skróty (aliasy)** w Termuxie, dzięki czemu nie musisz pamiętać długich komend Linuxa.

---

### 🏁 Jak uruchomić system po instalacji?

Gdy instalator zakończy pracę, zrestartuj Termuxa. Od teraz masz do dyspozycji 3 proste komendy:
1. `wejdz-ros` – loguje Cię do wnętrza systemu Ubuntu.
2. `start-agent` – uruchamia nasłuchiwanie na robota (port UDP 8888).
3. `start-foxglove` – uruchamia mostek wizualizacji (sterowanie przez tablet/telefon).
