#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <unistd.h>
#include <iomanip>
#include <sys/types.h>
#include <dirent.h>

void print_cpu_load() {
    std::ifstream stat_file("/proc/stat");
    if (!stat_file.is_open()) {
        std::cerr << "Unable to open /proc/stat" << std::endl;
        return;
    }

    std::string line;
    std::getline(stat_file, line);
    stat_file.close();

    std::istringstream iss(line);
    std::string cpu;
    unsigned long user, nice, system, idle, iowait, irq, softirq, steal;
    iss >> cpu >> user >> nice >> system >> idle >> iowait >> irq >> softirq >> steal;

    unsigned long total = user + nice + system + idle + iowait + irq + softirq + steal;
    unsigned long active = user + nice + system + irq + softirq + steal;
    double cpu_load = 100.0 * active / total;

    std::cout << "CPU Load: " << std::fixed << std::setprecision(2) << cpu_load << "%" << std::endl;
}

void print_processes() {
    DIR* dir;
    struct dirent* entry;
    if ((dir = opendir("/proc")) == nullptr) {
        std::cerr << "Unable to open /proc directory" << std::endl;
        return;
    }

    std::vector<pid_t> pids;
    while ((entry = readdir(dir)) != nullptr) {
        if (entry->d_type == DT_DIR) {
            std::string name(entry->d_name);
            if (name.find_first_not_of("0123456789") == std::string::npos) {
                pids.push_back(std::stoi(name));
            }
        }
    }
    closedir(dir);

    std::cout << std::setw(6) << "PID" << std::setw(20) << "Name" << std::setw(10) << "VMSize" << std::endl;
    for (pid_t pid : pids) {
        std::ifstream status_file("/proc/" + std::to_string(pid) + "/status");
        if (status_file.is_open()) {
            std::string line;
            std::string name;
            std::string vm_size;

            while (std::getline(status_file, line)) {
                if (line.rfind("Name:", 0) == 0) {
                    name = line.substr(6);
                } else if (line.rfind("VmSize:", 0) == 0) {
                    vm_size = line.substr(8, line.find('k') - 8);
                }
            }
            status_file.close();

            if (!name.empty() && !vm_size.empty()) {
                std::cout << std::setw(6) << pid
                          << std::setw(20) << name
                          << std::setw(10) << vm_size << std::endl;
            }
        }
    }
}

int main() {
    while (true) {
        std::cout << "\033[2J\033[H"; // Clear screen
        print_cpu_load();
        print_processes();
        sleep(5); // Update every 5 seconds
    }
    return 0;
}
