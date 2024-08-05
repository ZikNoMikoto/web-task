#!/bin/bash

# Остановка всех запущенных виртуальных машин
for vm in $(VBoxManage list runningvms | awk '{print $1}' | tr -d '"'); do
  echo "Stopping VM: $vm"
  VBoxManage controlvm "$vm" poweroff
done

# Удаление всех виртуальных машин и их данных
for vm in $(VBoxManage list vms | awk '{print $1}' | tr -d '"'); do
  echo "Deleting VM: $vm"
  VBoxManage unregistervm "$vm" --delete
done

# Удаление данных виртуальных машин из папок
VBOX_DIR="$vm"
if [ -d "$vm" ]; then
  echo "Deleting VM data in: $VBOX_DIR"
  rm -rf "$vm"
fi

echo "All virtual machines and their data have been deleted."
