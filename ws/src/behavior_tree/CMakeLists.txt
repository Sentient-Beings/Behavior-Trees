cmake_minimum_required(VERSION 3.8)
project(behavior_tree)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)
find_package(ament_index_cpp REQUIRED)
find_package(rclpy REQUIRED)
find_package(rclcpp REQUIRED)
find_package(rclcpp_action REQUIRED)
find_package(nav2_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(behaviortree_cpp REQUIRED)
find_package(cv_bridge REQUIRED)
find_package(OpenCV REQUIRED)
find_package(image_transport REQUIRED)
find_package(tf2 REQUIRED)
find_package(tf2_ros REQUIRED)
find_package(tf2_geometry_msgs REQUIRED)
find_package(yaml-cpp REQUIRED)


# Install directories
install(DIRECTORY
  bt_xml launch
  DESTINATION share/${PROJECT_NAME}
)

set(BT_SOURCES
    src/navigation_behaviors.cpp 
    src/vision_behaviors.cpp
)

set(TARGET_DEPENDS
    ament_index_cpp rclcpp rclcpp_action
    nav2_msgs sensor_msgs cv_bridge image_transport
    behaviortree_cpp tf2 tf2_ros tf2_geometry_msgs yaml-cpp
)
include_directories(include)
add_executable(behavior_tree_node src/behavior_tree_node.cpp ${BT_SOURCES})
install(TARGETS
    behavior_tree_node
    DESTINATION lib/${PROJECT_NAME}
)
ament_target_dependencies(behavior_tree_node ${TARGET_DEPENDS})
target_link_libraries(behavior_tree_node ${OpenCV_LIBS} ${YAML_CPP_LIBRARIES})

ament_package()
