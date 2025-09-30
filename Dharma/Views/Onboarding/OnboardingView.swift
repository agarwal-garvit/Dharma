//
//  OnboardingView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var studyGoal: StudyGoal = .daily10Min
    @State private var scriptDisplay: ScriptDisplay = .both
    @State private var preferredLanguage = "en"
    @State private var studyTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    
    let dataManager = DataManager.shared
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Welcome Page
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                VStack(spacing: 16) {
                    Text("Welcome to Dharma")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your daily companion for learning the Bhagavad Gita")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                Button("Get Started") {
                    withAnimation {
                        currentPage = 1
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .tag(0)
            .padding()
            
            // Study Goal Selection
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Choose Your Study Goal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("How much time would you like to dedicate daily?")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    ForEach(StudyGoal.allCases, id: \.self) { goal in
                        Button(action: {
                            studyGoal = goal
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(goal.displayName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("\(goal.durationMinutes) minutes per session")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: studyGoal == goal ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(studyGoal == goal ? .orange : .gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(studyGoal == goal ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                                    .stroke(studyGoal == goal ? Color.orange : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                HStack {
                    Button("Back") {
                        withAnimation {
                            currentPage = 0
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Spacer()
                    
                    Button("Next") {
                        withAnimation {
                            currentPage = 2
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .tag(1)
            .padding()
            
            // Script Display Selection
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Choose Script Display")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("How would you like to see Sanskrit text?")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    ForEach(ScriptDisplay.allCases, id: \.self) { script in
                        Button(action: {
                            scriptDisplay = script
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(script.displayName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(scriptDescription(for: script))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: scriptDisplay == script ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(scriptDisplay == script ? .orange : .gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(scriptDisplay == script ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                                    .stroke(scriptDisplay == script ? Color.orange : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                HStack {
                    Button("Back") {
                        withAnimation {
                            currentPage = 1
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Spacer()
                    
                    Button("Next") {
                        withAnimation {
                            currentPage = 3
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .tag(2)
            .padding()
            
            // Study Time Selection
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Set Study Time")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("When would you like to receive your daily reminder?")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 20) {
                    DatePicker("Study Time", selection: $studyTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                        )
                    
                    Text("You'll receive a gentle reminder at this time each day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                HStack {
                    Button("Back") {
                        withAnimation {
                            currentPage = 2
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Spacer()
                    
                    Button("Complete") {
                        completeOnboarding()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .tag(3)
            .padding()
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    private func scriptDescription(for script: ScriptDisplay) -> String {
        switch script {
        case .devanagari:
            return "Traditional Sanskrit script"
        case .iast:
            return "Roman transliteration"
        case .both:
            return "Both scripts together"
        }
    }
    
    private func completeOnboarding() {
        // Save preferences
        dataManager.userPreferences.studyGoal = studyGoal
        dataManager.userPreferences.scriptDisplay = scriptDisplay
        dataManager.userPreferences.preferredLanguage = preferredLanguage
        dataManager.userPreferences.studyTime = studyTime
        dataManager.saveUserData()
        
        // Set up notifications
        setupNotifications()
        
        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Send notification
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
    }
    
    private func setupNotifications() {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                scheduleDailyNotification()
            }
        }
    }
    
    private func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Dharma Study"
        content.body = "Time for your daily Bhagavad Gita study session!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: studyTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyStudy", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(Color.orange)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.orange)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    OnboardingView()
}
