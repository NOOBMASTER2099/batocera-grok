#!/bin/bash
# =====================================================
# Grok Batocera Overlay - ONE COMMAND INSTALL (AV)
# New splash added as requested
# =====================================================

clear

echo "GROK OVERLAY INSTALLING..."

cat << "EOF"
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!l !!!!!!!!!! I!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!   am !!!!!!!! Jh   !!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!I  hhrah          hajha  i!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!, ,a   z h          a c   h; .!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!l .ak tX z;la        ht:z  f d;: !!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!  hh F    c.F hTafFhhh r.c zzlI ha  !!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!  ha         z z;      ;X X Fzzzzz  ha  !!!!!!!!!!!!!!
!!!!!!!!!!!!   h  Xz Y      .    uu       vX zzzzz  hh  !!!!!!!!!!!!
!!!!!!!!!!  l:L XTXz         c        n      zzzzzzz Qht  !!!!!!!!!!
!!!!!!!!  khd zFXr                              zzXzcz ahd  !!!!!!!!
!!!l,   hh  X z                                    zXz X .aa   .!!!!
l  .hhh  Xi z            TXXYi        iXXzF           zz lc  hhh   l
!!    ;              z;      nzzzzzzzccI     ;c           j  :    !!
!!!!                   zXahahchhhhhhh.  ,hhhhl                  !!!!
!!!!!!!               hhhhhCQhhkhhI  Fa hhhhha l             !!!!!!!
!!!!!!!!!!!i       z.fk            hhhhhhL   Mh w       :!!!!!!!!!!!
!!!!!!!  p   !!!!!               cIzhaz       Ld ;!!!!!   w. !!!!!!!
!!!!!!. hhha: !!!!!              pp           h  !!!!! taLhh ;!!!!!!
!!!!!!! Uhha. !!!!!         f z  hp.         oh  !!!!! Thha! !!!!!!!
!!!t  F Lahhh    !  qhz z  vz tvo  ah .z   o hhh  ! !  hhhhd u  !!!!
!!! hhhhhlthJa v f  hh haYXQh.hh    hhhhahhr.hhh     hhbkhhhhhaa !!!
!!! LhQhvn  zw c Ta vrkU.  haaq      ahhh    dXh h z hqz. cuaQab !!!
!!!!  z        nr ah       I .kQ hh zh  z       haz:r.       z  !!!!
!!!!!!!!!!!!!! ; r. Xan !,  hLahhhhhhhY,  ,T.clc  c ci!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!  v    . Y  ohkhohh!hhhh  X      ; !!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!  a    odhhaha     a  !!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!     hh,Lkahlva aahIvhh.t   !!!!!!!!!!!!!!!!!!!!
!!!!!!!l     !!    xhhhb  ckhaoI hh wchhha  aahhi    !!     !!!!!!!!
!!!!!! aahh.   ! u aahJc    czathhhhhhh     Xvkah v u   .hhhh !!!!!!
!!!!!, hhaahhhhhh zv    !!!! tmzhhhhhk  !!!!    n  hhhhhhhahM !!!!!!
!!!!!! Y ,Ukhhhh,X  Uz !!!!!!  zz  za  l!!!!! vv  ziahhaa,  Y !!!!!!
!!!!!!!!l  Yahh   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   hhhi  !!!!!!!!!
!!!!!!!!! qdhhX  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  chakc !!!!!!!!!
!!!!!!!!!I  zI. ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!.  tX  l!!!!!!!!!
!!!!!!!!!!!!   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   t!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOF

echo "GROK OVERLAY INSTALLING..."

# Update packages and install dependencies
apt-get update -y
apt-get install -y python3-pip python3-dev python3-evdev

pip3 install --break-system-packages pillow requests evdev

# Create folders
mkdir -p /userdata/system/grok-overlay
cd /userdata/system/grok-overlay

# Config with your Grok key + metadata support
cat > config.ini << EOF
[GROK]
api_key = xai-UCcQcKtlvC4TaXxqotml48cW8x9osoSIYPTJcFjl1wVC9hwkEh6SUeWdAr2qfPEdURg03RrD9XJsFM25
bubble_seconds = 10
bubble_position = bottom-right
EOF

# Download the main AV files (we'll add these next)
curl -L -O https://raw.githubusercontent.com/NOOBMASTER2099/batocera-grok/main/grok_daemon.py
curl -L -O https://raw.githubusercontent.com/NOOBMASTER2099/batocera-grok/main/bubble_generator.py

chmod +x grok_daemon.py

# Create Ports menu entry
cat > /userdata/roms/ports/Grok\ Overlay.sh << 'EOL'
#!/bin/bash
echo "Grok Overlay is running in background!"
echo "Select + L1  → Ask Grok (screenshot + vision)"
echo "Select + R1  → Open History Viewer"
sleep 4
EOL
chmod +x /userdata/roms/ports/Grok\ Overlay.sh

# Auto-start on boot
if ! grep -q "grok-overlay" /userdata/system/custom.sh 2>/dev/null; then
    echo "/userdata/system/grok-overlay/grok_daemon.py &" >> /userdata/system/custom.sh
fi

echo "✅ GROK OVERLAY INSTALLED SUCCESSFULLY!"

