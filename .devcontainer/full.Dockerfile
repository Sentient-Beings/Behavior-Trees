# ROS distribution to use
ARG ROS_DISTRO=jazzy
FROM osrf/ros:${ROS_DISTRO}-desktop-full

ENV USER=ros2-dev
ENV USERNAME=$USER
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Do not prompt the user for input
ARG DEBIAN_FRONTEND=noninteractive

# Define Shell Env
SHELL ["/bin/bash", "-c"]
ENV SHELL=/bin/bash

# ====================================================================
# --- ALL ROOT-LEVEL OPERATIONS ---
# ====================================================================

# Install all necessary system packages in one layer
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        # Build tools
        build-essential \
        gdb gdbserver \
        cmake \
        # System libs and dependencies
        sudo nano autoconf git \
        libargon2-dev libssl-dev libx11-dev \
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev \
        libcanberra-gtk-module libcanberra-gtk3-module \
        fuse3 libfuse2 libqt5svg5-dev libxext-dev flex bison gstreamer1.0-pulseaudio \
        libusb-1.0-0-dev udev apt-transport-https ca-certificates curl software-properties-common \
        libgtk-3-dev libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev \
        pkg-config \
        # Python and ROS
        python3-pip python3-dev python3-opencv python3-tk python3-pyqt5.qtwebengine \
        ros-${ROS_DISTRO}-gazebo-* \
        ros-${ROS_DISTRO}-navigation2 \
        ros-${ROS_DISTRO}-nav2-bringup \
        ros-${ROS_DISTRO}-ffmpeg-image-transport \
        ros-${ROS_DISTRO}-tf-transformations \
        ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
        ros-${ROS_DISTRO}-pcl-conversions && \
    rm -rf /var/lib/apt/lists/*

# Install additional Python modules
RUN pip3 install --break-system-packages matplotlib transforms3d

# Download Groot2 Installer
WORKDIR /root/
RUN curl -o Groot2Installer https://s3.us-west-1.amazonaws.com/download.behaviortree.dev/groot2_linux_installer/Groot2-v1.6.1-linux-installer.run \
 && chmod a+x Groot2Installer
# TODO: we have to run the installer and install the groot (maybe ofload this to user)

# Remove display warnings
RUN mkdir /tmp/runtime-root && chmod -R 0700 /tmp/runtime-root
ENV XDG_RUNTIME_DIR "/tmp/runtime-root"
ENV NO_AT_BRIDGE 1

# Delete default "ubuntu" user if it exists to avoid UID conflicts
RUN userdel -r ubuntu || true

# Add User, add to fuse group, and move Groot2
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    groupadd fuse && \
    usermod -aG fuse ${USERNAME} && \
    mv /root/Groot2Installer /home/${USERNAME}/ && \
    chown ${USER_UID}:${USER_GID} /home/${USERNAME}/Groot2Installer

# ====================================================================
# --- SWITCH TO NON-ROOT USER ---
# From here on, commands run as $USERNAME
# ====================================================================
USER $USERNAME

WORKDIR /home/$USERNAME

# Set up environment variables
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV TURTLEBOT_MODEL=3

# Set up ROS2 environment in user's bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc

CMD ["/bin/bash"]
