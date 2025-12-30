import SwiftUI
import Charts

struct ProjectDashboardView: View {
    @StateObject private var userService = UserService.shared
    @StateObject private var taskService = TaskService.shared
    @State private var selectedProject: Project?
    @State private var showingShareSheet = false
    @State private var inviteEmail = ""
    @State private var showingInvite = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Projects overview
                        if userService.projects.isEmpty {
                            emptyProjectsState
                        } else {
                            projectsSection
                        }
                        
                        // Overall statistics
                        statisticsSection
                        
                        // Upcoming tasks
                        upcomingTasksSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
        .accentColor(.appAccent)
    }
    
    private var emptyProjectsState: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 100)
            
            Text("No Projects")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Create a project in the tasks screen")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.5))
        }
    }
    
    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Projects")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 5)
            
            ForEach(userService.projects) { project in
                ProjectCardView(project: project, tasks: taskService.tasks)
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Statistics")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 5)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                StatCardView(
                    title: "Total Tasks",
                    value: "\(taskService.tasks.count)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatCardView(
                    title: "Completed",
                    value: "\(taskService.tasks.filter { $0.status == .completed }.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCardView(
                    title: "In Progress",
                    value: "\(taskService.tasks.filter { $0.status == .inProgress }.count)",
                    icon: "hourglass",
                    color: .orange
                )
                
                StatCardView(
                    title: "Overdue",
                    value: "\(taskService.overdueTasks().count)",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
            }
        }
    }
    
    private var upcomingTasksSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Upcoming Tasks")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 5)
            
            let upcoming = taskService.upcomingTasks().prefix(5)
            
            if upcoming.isEmpty {
                NeumorphicCard {
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        Text("No upcoming tasks")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 5)
                    }
                    .padding()
                }
            } else {
                ForEach(Array(upcoming)) { task in
                    UpcomingTaskRow(task: task)
                }
            }
        }
    }
}

// MARK: - Project Card View
struct ProjectCardView: View {
    let project: Project
    let tasks: [Task]
    
    private var projectTasks: [Task] {
        tasks.filter { $0.projectId == project.id }
    }
    
    private var progress: Double {
        guard !projectTasks.isEmpty else { return 0 }
        let completed = projectTasks.filter { $0.status == .completed }.count
        return Double(completed) / Double(projectTasks.count)
    }
    
    var body: some View {
        NeumorphicCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: project.icon)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: project.color))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if !project.description.isEmpty {
                            Text(project.description)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                }
                
                // Progress bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.appAccent)
                                .frame(width: geometry.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                
                // Tasks count
                HStack(spacing: 20) {
                    Label("\(projectTasks.count)", systemImage: "doc.text.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Label("\(project.teamMembers.count)", systemImage: "person.2.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Stat Card View
struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        NeumorphicCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                    Spacer()
                }
                
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.vertical, 5)
        }
    }
}

// MARK: - Upcoming Task Row
struct UpcomingTaskRow: View {
    let task: Task
    
    var daysUntilDue: Int {
        guard let dueDate = task.dueDate else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        return days
    }
    
    var body: some View {
        NeumorphicCard {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text(daysUntilDue == 0 ? "Today" : daysUntilDue == 1 ? "Tomorrow" : "In \(daysUntilDue) days")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Text(task.priority.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(priorityColor(task.priority))
                    )
            }
        }
    }
    
    private func priorityColor(_ priority: Task.Priority) -> Color {
        switch priority {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

#Preview {
    ProjectDashboardView()
}

