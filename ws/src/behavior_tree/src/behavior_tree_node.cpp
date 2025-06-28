#include <chrono>
#include <random>
#include <string>

#include "rclcpp/rclcpp.hpp"
#include "ament_index_cpp/get_package_share_directory.hpp"
#include "behaviortree_cpp/bt_factory.h"
#include "behaviortree_cpp/xml_parsing.h"
#include "behaviortree_cpp/loggers/groot2_publisher.h"
#include "yaml-cpp/yaml.h"

#include "behavior_tree/navigation_behaviors.h"
#include "behavior_tree/vision_behaviors.h"

using namespace std::chrono_literals;

const std::string default_bt_xml_file = 
    ament_index_cpp::get_package_share_directory("behavior_tree") + "/bt_xml/tree_naive.xml";
const std::string sim_worlds_share_dir = 
    ament_index_cpp::get_package_share_directory("simulation");
const std::string default_location_file = 
    sim_worlds_share_dir + "/maps/sim_house_locations.yaml";

class BehaviorTreeNode : public rclcpp::Node {
    public:
        BehaviorTreeNode() : Node("behavior_tree_node") {
            // Read the location file and shuffle it
            this->declare_parameter<std::string>("location_file", default_location_file);
            location_file_ = this->get_parameter("location_file").as_string();
            RCLCPP_INFO(this->get_logger(), "Using location file %s", location_file_.c_str());

            this->declare_parameter<std::string>("tree_xml_file", default_bt_xml_file);
            tree_xml_file_ = this->get_parameter("tree_xml_file").as_string();
            this->declare_parameter<std::string>("target_color", "");
            target_color_ = this->get_parameter("target_color").as_string();
            if (target_color_ != "") {
                RCLCPP_INFO(this->get_logger(), "Searching for target color %s...",
                    target_color_.c_str());
            }
        }

        void execute() {
            // Build and initialize the behavior tree based on parameters.
            create_behavior_tree();

            // Create a timer to tick the behavior tree
            const auto timer_period = 500ms;
            timer_ = this->create_wall_timer(
                timer_period,
                std::bind(&BehaviorTreeNode::update_behavior_tree, this)
            );

            rclcpp::spin(shared_from_this());
            rclcpp::shutdown();
        }

        void create_behavior_tree() {
            // We construct the bt from xml and set it up for logging
            BT::BehaviorTreeFactory factory;
            factory.registerNodeType<SetLocations>("SetLocations");
            factory.registerNodeType<GetLocationFromQueue>("GetLocationFromQueue");
            // goToPose and LookForobject need ROS interaction, so we pass in a shared_ptr to this node
            factory.registerNodeType<GoToPose>("GoToPose", shared_from_this());
            factory.registerNodeType<LookForObject>("LookForObject", shared_from_this());

            auto blackboard = BT::Blackboard::create();
            blackboard->set<std::string>("location_file", location_file_);
            tree_ = factory.createTreeFromFile(tree_xml_file_, blackboard);

            // Set up tree logging to monitor the tree in Groot2.
            // Default ports (1666/1667) are used by the Nav2 behavior tree, so we use another port.
            // NOTE: You must have the PRO version of Groot2 to view live tree updates.
            publisher_ptr_ = std::make_unique<BT::Groot2Publisher>(tree_, 1668);
        }

        void update_behavior_tree() {
            // Tick the BT
            BT::NodeStatus tree_status = tree_.tickOnce();
            if (tree_status == BT::NodeStatus::RUNNING) {
                return;
            }
            // Cancel the timer if we hit a terminal state.
            if (tree_status == BT::NodeStatus::SUCCESS) {
                RCLCPP_INFO(this->get_logger(), "Finished with status SUCCESS");
                timer_->cancel();
            } else if (tree_status == BT::NodeStatus::FAILURE) {
                RCLCPP_INFO(this->get_logger(), "Finished with status FAILURE");
                timer_->cancel();
            }
        }

        std::string tree_xml_file_;
        std::string location_file_;
        std::string target_color_;

        rclcpp::TimerBase::SharedPtr timer_;
        BT::Tree tree_;
        std::unique_ptr<BT::Groot2Publisher> publisher_ptr_;
};

int main(int argc, char **argv) {
    rclcpp::init(argc, argv);
    auto node = std::make_shared<BehaviorTreeNode>();
    node->execute();
    return 0;
}