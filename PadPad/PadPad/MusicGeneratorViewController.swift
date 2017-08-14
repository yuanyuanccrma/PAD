//
//  ViewController.swift
//  padpad
//
//  Created by 栗圆 on 3/17/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//
// learn unwind http://stackoverflow.com/questions/28380923/how-to-do-something-before-unwind-segue-action
// Cite audio record https://iosdevcenters.blogspot.com/2016/08/audio-recording-and-playing-in-swift-30.html
// Cite the example code from audioKit: https://github.com/audiokit/AudioKit/tree/master/Examples/iOS/SequencerDemo

import UIKit
import CoreData
import AudioKit
import AVFoundation

class MusicGeneratorViewController: UIViewController, AVAudioRecorderDelegate{
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    func setupUI() {
        var buttons = [UIButton]()
        buttons.append(melodyButton)
        buttons.append(bassButton)
        buttons.append(snareButton)
        for button in buttons {
            button.setTitleColor(UIColor.white, for: UIControlState())
            button.setTitleColor(UIColor.lightGray, for: UIControlState.disabled)
        }
        tempoSlider.callback = updateTempo
        tempoSlider.minimum = 40
        tempoSlider.maximum = 200
        tempoSlider.value  = 110
        tempoSlider.format = "%0.1f BPM"
    }
    
    var audioURL: String?
    
    @IBOutlet var melodyButton: UIButton!
    @IBOutlet var bassButton: UIButton!
    @IBOutlet var snareButton: UIButton!
    @IBOutlet var tempoSlider: AKPropertySlider!
    
    @IBOutlet weak var btnAudioRecord: UIButton!
    var recordingSession : AVAudioSession!
    var audioRecorder :AVAudioRecorder!
    var settings = [String : Int]()
    
    let composer = Compose()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Allow")
                    } else {
                        print("Dont Allow")
                    }
                }
            }
        } catch {
            print("failed to record!")
        }
        composer.setupTracks()
        settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }
    
    func directoryURL() -> NSURL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
        return soundURL as NSURL?
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            audioRecorder = try AVAudioRecorder(url: self.directoryURL()! as URL,
                                                settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            finishRecording(success: false)
        }
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
        } catch {
        }
    }
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        if success {
            print(success)
        } else {
            audioRecorder = nil
            print("Somthing Wrong.")
        }
    }
    @IBAction func click_AudioRecord(_ sender: AnyObject) {
        if audioRecorder == nil {
            self.btnAudioRecord.setTitle("Stop", for: UIControlState.normal)
            self.btnAudioRecord.backgroundColor = UIColor(red: 119.0/255.0, green: 119.0/255.0, blue: 119.0/255.0, alpha: 1.0)
            self.startRecording()
        } else {
            self.btnAudioRecord.setTitle("Record", for: UIControlState.normal)
            self.btnAudioRecord.backgroundColor = UIColor(red: 221.0/255.0, green: 27.0/255.0, blue: 50.0/255.0, alpha: 1.0)
            self.finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @IBAction func goBack(from segue: UIStoryboardSegue) {
    }
    
    @IBAction func addNewTransaction(from segue: UIStoryboardSegue) {
        if let addOn = segue.source as? SaveMixTableViewController {
            let date = addOn.datePicker.date as NSDate
            var name: String?
            if addOn.nameTextField.text != nil, addOn.nameTextField.text != "" {
                name = addOn.nameTextField.text
                print("\(addOn.nameTextField.text)")
            }
            var diary: String?
            if addOn.diaryTextField.text != nil,addOn.diaryTextField.text != "" {
                diary = addOn.diaryTextField.text
            }
            var imageData: NSData?
            if addOn.image != nil {
                imageData = NSData(data: UIImageJPEGRepresentation(addOn.image!, 1.0)!)
            }
            audioURL = self.directoryURL()!.path! + "/" + name! + ".m4a"
            if name != nil {
                container?.performBackgroundTask {[weak self] context in
                    _ = MixDown.createNewMixFile(date: date, url: self?.audioURL, name: name, diary: diary, coverImage: imageData, in: context)
                    try? context.save()
                }
            }
        }
    }
    
    // MARK: Core Data
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                let request: NSFetchRequest<MixDown> = MixDown.fetchRequest()
                let story = try? context.fetch(request)
                for tale in story! {
                    print(" \(tale.url!), \(tale.name!)")
                }
            }
        }
    }
    

    @IBAction func clearMelodySequence(_ sender: UIButton) {
        composer.clear(Sequence.melody)
        melodyButton?.isEnabled = false
    }
    
    @IBAction func clearBassDrumSequence(_ sender: UIButton) {
        composer.clear(Sequence.bassDrum)
        bassButton?.isEnabled = false
    }
    
    @IBAction func clearSnareDrumSequence(_ sender: UIButton) {
        composer.clear(Sequence.snareDrum)
        snareButton?.isEnabled = false
    }
    
    @IBAction func clearSnareDrumGhostSequence(_ sender: UIButton) {
        composer.clear(Sequence.snareDrumGhost)
    }
    
    @IBAction func generateMajorSequence(_ sender: UIButton) {
        composer.generateNewMelodicSequence(minor: false)
        melodyButton?.isEnabled = true
    }
    
    @IBAction func generateMinorSequence(_ sender: UIButton) {
        composer.generateNewMelodicSequence(minor: true)
        melodyButton?.isEnabled = true
    }
    
    @IBAction func generateBassDrumSequence(_ sender: UIButton) {
        composer.generateBassDrumSequence()
        bassButton?.isEnabled = true
    }
    
    @IBAction func generateBassDrumHalfSequence(_ sender: UIButton) {
        composer.generateBassDrumSequence(2)
        bassButton?.isEnabled = true
    }
    
    @IBAction func generateBassDrumQuarterSequence(_ sender: UIButton) {
        composer.generateBassDrumSequence(4)
        bassButton?.isEnabled = true
    }
    
    @IBAction func generateSnareDrumSequence(_ sender: UIButton) {
        composer.generateSnareDrumSequence()
        snareButton?.isEnabled = true
    }
    
    @IBAction func generateSnareDrumHalfSequence(_ sender: UIButton) {
        composer.generateSnareDrumSequence(2)
        snareButton?.isEnabled = true
    }
    
    @IBAction func generateSnareDrumGhostSequence(_ sender: UIButton) {
        composer.generateSnareDrumGhostSequence()
        snareButton?.isEnabled = true
    }
    
    @IBAction func generateSequence(_ sender: UIButton) {
        composer.generateSequence()
        melodyButton?.isEnabled = true
        bassButton?.isEnabled = true
        snareButton?.isEnabled = true
    }
    
    @IBAction func stopSequence(_ sender: UIButton) {
        composer.stopSequence()
    }
    
    @IBAction func playSequence(_ sender: UIButton) {
        composer.playSequence()
    }
    
    func updateTempo(value: Double) {
        composer.currentTempo = value
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = segue.destination as? SaveMixTableViewController
    }
}
