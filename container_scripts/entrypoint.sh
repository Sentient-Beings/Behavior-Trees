#!/usr/bin/env bash
echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
echo "source /home/${USERNAME}/mnt/ws/install/setup.bash" >> ~/.bashrc

cd /home/${USERNAME}/mnt/ws

if [ -d "build" ] || [ -d "log" ] || [ -d "install" ]; then
    rm -rf build log install
fi

source /opt/ros/${ROS_DISTRO}/setup.bash
colcon build --symlink-install