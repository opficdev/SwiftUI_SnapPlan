//
//  LinearAudioPlayer.swift
//  SnapPlan
//
//  Created by opfic on 3/25/25.
//

import SwiftUI
import AVKit

struct LinearAudioPlayer: View {
    @Binding var file: AVAudioFile
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    
    init(file: Binding<AVAudioFile>) {
        self._file = file
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let data = try Data(contentsOf: file.wrappedValue.url)
            self._player = State(initialValue: try AVAudioPlayer(data: data))
        } catch {
            print("Error initializing player: \(error)")
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(DateFormatter.mmss(from: player?.currentTime ?? 0))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Slider(value: Binding(
                    get: { progress },
                    set: { value in
                        progress = value
                        player?.currentTime = value * (player?.duration ?? 0)
                    }
                ), in: 0...1)
                .accentColor(.blue)
                .onChange(of: progress) { value in
                    if value == 0 {
                        player?.pause()
                        isPlaying = false
                    }
                    else if 1.0 <= value {
                        progress = 0
                        player?.currentTime = 0
                    }
                }
                
                Text(DateFormatter.mmss(from: player?.duration ?? 0))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
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
        .onChange(of: self.file) { file in
            do {
                let data = try Data(contentsOf: file.url)
                self.player = try AVAudioPlayer(data: data)
            }
            catch {
                print("Error initializing player: \(error.localizedDescription)")
            }
        }
    }
}
