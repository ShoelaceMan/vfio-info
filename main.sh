#!/bin/bash

# Set the default Libvirt URI
export LIBVIRT_DEFAULT_URI='qemu:///system'

while true
do
    if ! groups | grep -qe libvirt; then
        echo "You're not in the libvirt group, you may be asked for your sudo password."
        sudo=sudo
    fi
    $sudo virsh list --all
    sleep 2
    read -p "Please type in the VM name exactly: " answer
    if $sudo virsh list --all --name | grep -q "$answer"
        then
            clear
            echo -e "\`\`\`\n$answer XML dump:"
            $sudo virsh dumpxml "$answer" | curl -F 'clbin=<-' https://clbin.com
            sleep 1
            echo "libvirt status:"
            systemctl status libvirtd | curl -F 'clbin=<-' https://clbin.com
            sleep 1
            echo "Libvirt logs:"
            journalctl -b -u libvirtd | curl -F 'clbin=<-' https://clbin.com
            sleep 1
            echo "qemu.conf:"
            grep --invert-match -e "^# " -e "^ "- /etc/libvirt/qemu.conf | grep -e "[a-z]" | curl -F 'clbin=<-' https://clbin.com
            sleep 1
            echo "Libvirt $answer logs:"
            cat /var/log/libvirt/qemu/"$answer".log | curl -F 'clbin=<-' https://clbin.com
            echo "\`\`\`"
            exit
    elif [ "$answer" == "exit" ];
        then
            echo "Goodbye!"
            break
    elif true;
        then
            echo "ERROR Incorrect VM name!"
    fi    

done
