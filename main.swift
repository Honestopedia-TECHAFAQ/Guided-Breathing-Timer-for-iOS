import SwiftUI
import AVFoundation

struct BreathingTimerView: View {
    @State private var inhaleDuration: Double = 4
    @State private var exhaleDuration: Double = 4
    @State private var holdDuration: Double = 2
    
    @State private var isInhaling = false
    @State private var isHolding = false
    @State private var isExhaling = false
    @State private var circleScale: CGFloat = 1.0
    
    @State private var timerRunning = false
    @State private var currentPhase: String = "Inhale"
    @State private var timer: Timer?
    
    var inhaleSound: AVAudioPlayer?
    var exhaleSound: AVAudioPlayer?
    var holdSound: AVAudioPlayer?

    let circleColor = Color.purple.opacity(0.6)

    var body: some View {
        VStack {
            Spacer()
            
            Circle()
                .fill(circleColor)
                .frame(width: 200 * circleScale, height: 200 * circleScale)
                .animation(.easeInOut(duration: inhaleDuration), value: circleScale)
            
            Text(currentPhase)
                .font(.largeTitle)
                .padding()

            Button(action: {
                if timerRunning {
                    stopTimer()
                } else {
                    startTimer()
                }
            }) {
                Text(timerRunning ? "Pause" : "Start")
                    .font(.title)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .onAppear {
            loadSounds()
        }
    }
    
    func startTimer() {
        timerRunning = true
        runBreathingCycle()
    }
    
    func stopTimer() {
        timerRunning = false
        timer?.invalidate()
    }
    
    func runBreathingCycle() {
        currentPhase = "Inhale"
        circleScale = 1.5
        playSound(for: "inhale")
        
        timer = Timer.scheduledTimer(withTimeInterval: inhaleDuration, repeats: false) { _ in
            self.currentPhase = "Hold"
            self.playSound(for: "hold")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                self.currentPhase = "Exhale"
                self.circleScale = 1.0
                self.playSound(for: "exhale")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + self.exhaleDuration) {
                    if self.timerRunning {
                        self.runBreathingCycle()
                    }
                }
            }
        }
    }

    func loadSounds() {
        inhaleSound = loadSound(filename: "inhale")
        exhaleSound = loadSound(filename: "exhale")
        holdSound = loadSound(filename: "hold")
    }
    
    func playSound(for phase: String) {
        switch phase {
        case "inhale":
            inhaleSound?.play()
        case "exhale":
            exhaleSound?.play()
        case "hold":
            holdSound?.play()
        default:
            break
        }
    }

    func loadSound(filename: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else { return nil }
        do {
            return try AVAudioPlayer(contentsOf: url)
        } catch {
            return nil
        }
    }
}

struct BreathingTimerView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingTimerView()
    }
}
