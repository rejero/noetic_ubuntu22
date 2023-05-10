#!/bin/bash
 
# download pacakge list using rosdep
# ref: http://wiki.ros.org/noetic/Installation/Source
 
sudo apt-get install python3-rosdep python3-rosinstall-generator python3-vcstool build-essential
sudo rosdep init
rosdep update
 
# setup ros workspace
mkdir -p ros_noetic_ws/src
cd ros_noetic_ws
rosinstall_generator desktop --rosdistro noetic --deps --tar > noetic-desktop.rosinstall
vcs import --input noetic-desktop.rosinstall ./src
rm noetic-desktop.rosinstall
 
# install dependencies
sudo apt install libogre-1.9-dev libpoco-dev libbz2-dev libgpgme-dev liblog4cxx-dev liburdfdom-dev liburdfdom-headers-dev
sudo apt install python3-catkin-pkg python3-osrf-pycommon python3-rosdep python3-rosinstall-generator python3-defusedxml python3-python-qt-binding
#sudo apt install rviz
sudo apt install python3-pip
sudo python3 -m pip install catkin_tools
~
 
# patch rosconsole package and support c++17 for supporting the latest liblog4cxx-dev
cd src
#rm -rf rviz
#rm -rf visualization_tutorials
rm -rf rosconsole
git clone https://github.com/ros/rosconsole.git
cd rosconsole
wget https://patch-diff.githubusercontent.com/raw/ros/rosconsole/pull/54.patch
git apply 54.patch
rm 54.patch
cd ../resource_retriever
find CMakeLists.txt -type f -exec sed -i 's/c++11/c++17/g' {} \;
cd ../rqt_image_view
find CMakeLists.txt -type f -exec sed -i 's/c++11/c++17/g' {} \;
cd ../geometry/tf
find CMakeLists.txt -type f -exec sed -i 's/c++11/c++17/g' {} \;
cd ../../laser_geometry
find CMakeLists.txt -type f -exec sed -i 's/11/17/g' {} \;
cd ../urdf/urdf
find CMakeLists.txt -type f -exec sed -i 's/14/17/g' {} \;
cd ../../kdl_parser/kdl_parser
find CMakeLists.txt -type f -exec sed -i 's/14/17/g' {} \;
cd ../../robot_state_publisher
find CMakeLists.txt -type f -exec sed -i 's/11/17/g' {} \;
cd ../../
 
# Optional package (ex. robotics) Currently GAZEBO AND IMAGE TRANSPORT
# git clone git@github.com:mavlink/mavros.git src/mavros
 
sudo apt install libgazebo-dev # Gazebo
rm -rf src/image_common # since we need to update it with the below upstream package
git clone https://github.com/ros-perception/image_common src/image_common #IMAGE TRANSPORT ALSO A GAZEBO DEPDENCAY
#REMEMBER THE IMAGE COMMON IS NOT FULL OF EVERYTHING REQUIRED IN THE ORIGINAL DIRECTORY
git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b noetic-devel  src/gazebo_ros_pkgs #GAZEBO
git clone https://github.com/ros-controls/control_toolbox.git src/control_toolbox
 
 
# build
catkin init
catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release
catkin build
 
 
# NOTE
# liblog4cxx-dev requires C++17 for std::shared_mutex
# python3-defusedxml for launching roscore
 
# rviz issue: compiled ros1 rviz may crush, try to use the default rviz
