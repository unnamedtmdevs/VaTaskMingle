import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var userEmail = ""
    
    let pages = [
        OnboardingPage(
            icon: "checkmark.circle.fill",
            title: "Welcome to TaskMingle",
            description: "Manage tasks and projects with ease. A modern approach to productivity."
        ),
        OnboardingPage(
            icon: "person.3.fill",
            title: "Team Collaboration",
            description: "Invite members, share projects, and achieve goals together."
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "Track Progress",
            description: "Visualize project progress and never miss deadlines."
        ),
        OnboardingPage(
            icon: "bell.fill",
            title: "Reminders",
            description: "Set up reminders and get notifications for important tasks."
        )
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.appAccent : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Current page content
                VStack(spacing: 20) {
                    Image(systemName: pages[currentPage].icon)
                        .font(.system(size: 80))
                        .foregroundColor(.appAccent)
                        .padding(.bottom, 20)
                    
                    Text(pages[currentPage].title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text(pages[currentPage].description)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(currentPage)
                
                Spacer()
                
                // Email input on last page
                if currentPage == pages.count - 1 {
                    VStack(spacing: 15) {
                        Text("Enter your email (optional)")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                        
                        NeumorphicTextField(placeholder: "email@example.com", text: $userEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(.horizontal)
                    }
                    .transition(.opacity)
                }
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: previousPage) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(NeumorphicButtonStyle(color: Color.white.opacity(0.2)))
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button(action: nextPage) {
                            HStack {
                                Text("Next")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: 200)
                        }
                        .buttonStyle(NeumorphicButtonStyle())
                    } else {
                        Button(action: completeOnboarding) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: 200)
                        }
                        .buttonStyle(NeumorphicButtonStyle())
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
    
    private func nextPage() {
        withAnimation(.spring()) {
            if currentPage < pages.count - 1 {
                currentPage += 1
            }
        }
    }
    
    private func previousPage() {
        withAnimation(.spring()) {
            if currentPage > 0 {
                currentPage -= 1
            }
        }
    }
    
    private func completeOnboarding() {
        if !userEmail.isEmpty {
            UserService.shared.setUserEmail(userEmail)
        }
        
        // Create sample project and task
        createSampleData()
        
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
    
    private func createSampleData() {
        let sampleProject = Project(
            name: "My First Project",
            description: "This is a sample project. Feel free to edit or delete it.",
            color: "#FE284A",
            icon: "star.fill"
        )
        UserService.shared.addProject(sampleProject)
        
        let sampleTask = Task(
            title: "Welcome to TaskMingle!",
            description: "Start by creating your tasks and projects. Use priorities, set deadlines, and track your progress.",
            projectId: sampleProject.id,
            priority: .medium,
            status: .todo,
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())
        )
        TaskService.shared.addTask(sampleTask)
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

#Preview {
    OnboardingView()
}

