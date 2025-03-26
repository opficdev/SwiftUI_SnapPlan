//
//  LinearAudioPlayer.swift
//  SnapPlan
//
//  Created by opfic on 3/25/25.
//

import SwiftUI
import AVKit

struct LinearAudioPlayer: View {
    @State private var file: AVAudioFile
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    
    init(file: AVAudioFile) {
        self.file = file
        do {
            let data = try Data(contentsOf: file.url)
            self._player = State(initialValue: try AVAudioPlayer(data: data))
        } catch {
            print("Error initializing player: \(error)")
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(DateFormatter.audioTimeFmt(player?.currentTime ?? 0))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Slider(value: Binding(
                    get: { progress },
                    set: { newValue in
                        progress = newValue
                        player?.currentTime = newValue * (player?.duration ?? 0)
                    }
                ), in: 0...1)
                .accentColor(.blue)
                
                Text(DateFormatter.audioTimeFmt(player?.duration ?? 0))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    if isPlaying {
                        player?.pause()
                    }
                    else {
                        player?.play()
                    }
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
        )
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let player = player {
                    progress = player.currentTime / player.duration
                }
            }
        }
    }
}
