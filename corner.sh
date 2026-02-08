#!/bin/bash

# Telegram Channel: T.me/NetworkCriminals
# github.com/NimuLy

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
NC=$(tput sgr0)

REPOS=(
  "kali.download"
  "mirrors.jevincanders.net"
  "kali.cs.nycu.edu.tw"
  "mirror.kku.ac.th"
  "mirrors.neusoft.edu.cn"
  "kali.darklab.sh"
  "kali.mirror.garr.it"
  "kali.mirror.rafal.ca"
  "mirrors.netix.net"
  "mirror.freedif.org"
  "mirror.aktkn.sg"
  "mirrors.ocf.berkeley.edu"
  "mirror1.sox.rs"
  "mirror.pyratelan.org"
  "mirror.johnnybegood.fr"
  "ftp.free.fr"
  "archive-4.kali.org"
  "ftp.halifax.rwth-aachen.de"
  "mirror.netcologne.de"
  "free.nchc.org.tw"
  "mirror.accuris.ca"
  "mirror.twds.com.tw"
  "mirror.init7.net"
  "mirror.0xem.ma"
  "mirror.vinehost.net"
  "xsrv.moratelindo.io"
  "mirror.primelink.net.id"
  "mirror.cspacehostings.com"
  "mirror.leitecastro.com"
  "mirror.cedia.org.ec"
  "mirrors.ustc.edu.cn"
  "elmirror.cl"
  "ftp.nluug.nl"
  "mirror.serverius.net"
  "mirror.ufro.cl"
  "repo.jing.rocks"
  "mirrors.dotsrc.org"
  "ftp.ne.jp"
  "ftp.jaist.ac.jp"
  "ftp.riken.jp"
  "mirror.lagoon.nc"
  "ftp.yz.yamagata-u.ac.jp"
  "ftp.belnet.be"
  "quantum-mirror.hu"
  "kali.koyanet.lv"
  "mirror.2degrees.nz"
  "mirror.accum.se"
  "wlglam.fsmg.org.nz"
  "hlzmel.fsmg.org.nz"
  "mirror.truenetwork.ru"
  "ftp.cc.uoc.gr"
  "mirror.amuksa.com"
  "kali.itsec.am"
  "kali.mirror2.gnc.am"
  "kali.mirror1.gnc.am"
  "md.mirrors.hacktegic.com"
  "mirror.math.princeton.edu"
  "fastmirror.pp.ua"
  "mirror.corner-host.com"
  "mirror.new-edge.net"
  "mirror.flashpoint.org"
  "mirrors.esto.network"
  "mirror.us.cdn-perfprod.com"
  "us.mirror.ionos.com"
  "mirror.ourhost.az"
  "mirror.es.cdn-perfprod.com"
)

best_repo=""

require_root() { [[ $EUID -ne 0 ]] && echo "Run as root" && exit 1; }
require_kali() { [[ ! -f /etc/os-release ]] && exit 1; . /etc/os-release; [[ "$ID" != "kali" ]] && echo "Must run on Kali Linux" && exit 1; }

save_backup() { [[ -f /etc/apt/sources.list.bak ]] && return; cp /etc/apt/sources.list /etc/apt/sources.list.bak; }
restore_backup() { cp /etc/apt/sources.list.bak /etc/apt/sources.list; }

check_repos() {
  echo ""
  fastest_time=999999
  for r in "${REPOS[@]}"; do
    echo -n "Checking $r "
    start=$(date +%s%N)
    if curl -s --head --fail --max-time 5 "http://$r" >/dev/null; then
      end=$(date +%s%N)
      ms=$(( (end - start) / 1000000 ))
      echo -e "${GREEN}UP${NC} ${ms}ms"
      [[ $ms -lt $fastest_time ]] && fastest_time=$ms && best_repo=$r
    else
      echo -e "${RED}DOWN${NC}"
    fi
  done
  echo ""
  echo "Fastest Mirror: ${BLUE}$best_repo${NC} at ${fastest_time}ms"
}

apply_repo() { save_backup; sed -i "s|deb http://[^/]\+/kali|deb http://$1/kali|g" /etc/apt/sources.list; }

auto_update() { check_repos; [[ -n $best_repo ]] && apply_repo "$best_repo"; }
manual_update() { for i in "${!REPOS[@]}"; do echo "$((i+1)). ${REPOS[$i]}"; done; read -p "Select repo: " n; [[ $n -ge 1 && $n -le ${#REPOS[@]} ]] && apply_repo "${REPOS[$((n-1))]}" || manual_update; }


art_corner() {
  echo ""
  echo "_________ "
  echo "\_   ___ \  ___________  ____   ___________ "
  echo "/    \  \/ /  _ \_  __ \/    \_/ __ \_  __ \ "
  echo "\     \___(  <_> )  | \/   |  \  ___/|  | \/ "
  echo " \______  /\____/|__|  |___|  /\___  >__|   "
  echo "        \/                  \/     \/       "
  echo ""
}

main_menu() {
  art_corner
  echo "1. Auto Detect & Apply Best Mirror"
  echo "2. Choose Mirror Manually"
  echo "3. Check Mirror Status"
  echo "4. Backup sources.list"
  echo "5. Restore Backup"
  echo "6. Quit"
}

while true; do
  require_root
  require_kali
  main_menu
  read -p "Choice: " c
  case $c in
    1) auto_update ;;
    2) manual_update ;;
    3) check_repos ;;
    4) save_backup ;;
    5) restore_backup ;;
    6) exit ;;
    *) echo "Invalid input" ;;
  esac
done
