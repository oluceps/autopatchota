set shell := ["nu", "-c"]

host := `hostname`
me := `whoami`
home := `$env.HOME`
ota_file := "ota.zip"

# MODIFY BELOW IF NEEDED

# get from https://developers.google.com/android/ota
ota_url := "https://dl.google.com/dl/android/aosp/shiba-ota-ap2a.240805.005.d1-3cde38bd.zip"

magisk_url := "https://github.com/topjohnwu/Magisk/releases/download/v27.0/Magisk-v27.0.apk"

ksu_anykernel_url := "https://github.com/tiann/KernelSU/releases/download/v1.0.1/AnyKernel3-android14-5.15.148_2024-05.zip"

secret_root := "~/Sec"


# -------------------------------------

default:
    @just --choose

start-from-exist-ota-zip: get-magisk-tool get-anykernel-ksu-kernel extract-ota-zip repack-kernel repack-kernel patch

start: get-latest-update start-from-exist-ota-zip

get-latest-update:
    http get {{ ota_url }} | save {{ ota_file }} 
    
get-magisk-tool:
    #!/usr/bin/env nu
    mkdir build
    http get {{ magisk_url }} | save magisk.zip
    ouch d magisk.zip
    let arch = uname | get machine
    mv $"magisk/lib/($arch)/libmagiskboot.so" build/
    chmod +x build/libmagiskboot.so
    rm -r ./magisk*
    
get-anykernel-ksu-kernel:
    #!/usr/bin/env nu
    http get {{ ksu_anykernel_url }} | save ksu.zip
    mkdir build
    ouch d ksu.zip
    mv ksu/Image build/
    rm ksu.zip ksu -r

extract-ota-zip:
    #!/usr/bin/env nu
    mkdir build
    avbroot extract -i {{ ota_file }} --boot-only --directory build/

repack-kernel:
    #!/usr/bin/env nu
    cd build
    mv Image kernel
    ./libmagiskboot.so repack boot.img

patch:
    #!/usr/bin/env nu
    (avbroot ota patch
          --key-avb {{ secret_root }}/avb.key
          --key-ota {{ secret_root }}/ota.key
          --cert-ota {{ secret_root }}/ota.crt
          --prepatched build/new-boot.img
          --input ./{{ ota_file }})
clean:
    rm -rf build *.patched magisk*

# Reboot to recovery mode. If the screen is stuck at a No command message, press the volume up button once while holding down the power button.
sideload:
    adb sideload $"./{{ ota_file }}.patched"
