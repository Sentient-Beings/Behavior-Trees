# How to use Behavior Trees in ROS 2 with BT.CPP

This repository is for learning how to create and use behavior trees in ROS 2 with the `BT.CPP` library. It's meant to be used alongside the blog post I wrote about it: [link].

The whole setup is dockerized, so you don't have to worry about installing ROS 2 or any other dependencies on your machine. Just follow the steps below.

Once you're done, you'll have a simulated robot that uses a behavior tree to navigate around and find objects of a certain color.

## Setup Instructions

These instructions are for a Linux computer (tested on Ubuntu 22.04) since we need to display a graphical user interface from the Docker container. Using VS Code with the Dev Containers extension is the easiest way to get this running.

### What you'll need on your computer

*   **Docker Engine:** [Follow the installation guide here.](https://docs.docker.com/engine/install/) After you install it, it's very important to do the [Linux post-install steps](https://docs.docker.com/engine/install/linux-postinstall/). This lets you use Docker without typing `sudo` every time. Remember to log out and log back in for the changes to take effect.

*   **NVIDIA GPU Drivers (if you have an NVIDIA card):** If your computer has an NVIDIA graphics card, make sure you're using the official drivers and have the [NVIDIA Container Toolkit installed.](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) You can check if it's working by running:
    ```bash
    sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
    ```

*   **VS Code + Dev Containers Extension:** You'll need VS Code and the official [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) to open the project.

### Building the environment

1.  Clone this repository to your machine.
2.  Open the `Behavior_trees` folder with VS Code.
3.  VS Code should suggest reopening the folder in a container. If not, open the command palette (`Ctrl+Shift+P`) and run `Dev Containers: Rebuild and Reopen in Container`.
4.  Wait for the container to build. This will take a few minutes the first time.

Now you're inside the development environment with everything you need.

## Running the Robot

All the commands below should be run in the terminal inside VS Code.

### 1. Install Groot2

First, you need to install Groot2, which is a tool to see your behavior tree graphically as it runs.

The installer is already in your home directory inside the container.

```bash
cd ~
./Groot2Installer
```

An installer window should pop up. Just click 'Next' all the way through. For the installation directory, use the default path: `/home/ros2-dev/Groot2`.

After it's installed, run this command to create a shortcut so our ROS nodes can find it:

```bash
ln -s /home/ros2-dev/Groot2/bin/groot2 ~/groot2
```

### 2. Launch the Simulation

Next, start the Gazebo world and the navigation system.

```bash
ros2 launch simulation simulation_bringup.launch.py 
```

A Gazebo window will appear showing a room and the robot.

### 3. Run the Behavior Tree

Finally, start the behavior tree to get the robot moving.

```bash
ros2 launch behavior_tree tree.launch.py target_color:=green
```

You can change `green` to another color if you want to see the robot search for something else. Groot2 should also pop up and show you the tree's state in real-time.

### 3. Credits 
The code for this project was adopted from this repo: https://github.com/sea-bass/turtlebot3_behavior_demos. A great work done by Sebastian Castro. Head to https://roboticseabass.com/ to learn more about robotics related blogs. 

