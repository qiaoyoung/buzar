import AppTrackingTransparency
import AVFoundation
import Flutter
import MediaPlayer
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    // 配置音频会话的方法
    private func configureAudioSession() {
        do {
            // 设置音频会话类别和选项
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [
                    .mixWithOthers, // 允许与其他应用的音频混音
                    .allowAirPlay, // 支持 AirPlay
                    .duckOthers // 当其他应用播放声音时降低音量
                ]
            )
            // 激活音频会话
            try AVAudioSession.sharedInstance().setActive(true)
            
            // 配置远程控制事件
            UIApplication.shared.beginReceivingRemoteControlEvents()
            
            // 设置后台任务
            let audioBackground = UIApplication.shared.beginBackgroundTask {
                UIApplication.shared.endBackgroundTask(UIBackgroundTaskIdentifier.invalid)
            }
            
            if audioBackground == UIBackgroundTaskIdentifier.invalid {
                print("Background task failed to start")
            }
        } catch {
            print("Audio Session configuration failed: \(error.localizedDescription)")
        }
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 配置音频会话
        configureAudioSession()
 
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { _ in
                }
            }
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
