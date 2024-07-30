#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <vector>

using namespace std;

struct CPUInfo {
    long user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice;
};

CPUInfo getCPUInfo() {
    CPUInfo cpuInfo = {0};
    ifstream file("/proc/stat");
    string line;
    if (getline(file, line)) {
        istringstream ss(line);
        string cpu;
        ss >> cpu; // Skip the "cpu" label
        ss >> cpuInfo.user >> cpuInfo.nice >> cpuInfo.system >> cpuInfo.idle;
        ss >> cpuInfo.iowait >> cpuInfo.irq >> cpuInfo.softirq >> cpuInfo.steal;
        ss >> cpuInfo.guest >> cpuInfo.guest_nice;
    }
    return cpuInfo;
}

long getTotalMemory() {
    ifstream file("/proc/meminfo");
    string line;
    long memTotal = 0;
    while (getline(file, line)) {
        if (line.find("MemTotal:") != string::npos) {
            istringstream ss(line);
            string label;
            ss >> label >> memTotal;
            break;
        }
    }
    return memTotal;
}

void displaySystemInfo() {
    CPUInfo cpuInfo = getCPUInfo();
    long totalMemory = getTotalMemory();

    cout << "System Monitor Tool" << endl;
    cout << "--------------------" << endl;
    cout << "CPU Usage:" << endl;
    cout << "User: " << cpuInfo.user << " jiffies" << endl;
    cout << "Nice: " << cpuInfo.nice << " jiffies" << endl;
    cout << "System: " << cpuInfo.system << " jiffies" << endl;
    cout << "Idle: " << cpuInfo.idle << " jiffies" << endl;
    cout << "IOwait: " << cpuInfo.iowait << " jiffies" << endl;
    cout << "IRQ: " << cpuInfo.irq << " jiffies" << endl;
    cout << "SoftIRQ: " << cpuInfo.softirq << " jiffies" << endl;
    cout << "Steal: " << cpuInfo.steal << " jiffies" << endl;
    cout << "Guest: " << cpuInfo.guest << " jiffies" << endl;
    cout << "Guest Nice: " << cpuInfo.guest_nice << " jiffies" << endl;
    cout << "Total Memory: " << totalMemory / 1024 << " MB" << endl;
}

int main() {
    while (true) {
        system("clear"); // Clear screen (Linux specific)
        displaySystemInfo();
        sleep(2); // Update every 2 seconds
    }
    return 0;
}
