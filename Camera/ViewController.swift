//
//  ViewController.swift
//  Camera
//
//  Created by doug harper on 11/3/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController {
  
  @IBOutlet weak var cameraPreview: UIView!
  @IBOutlet weak var thumbnailButton: UIButton!
  
  let captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer!
  var activeInput: AVCaptureDeviceInput!
  let imageOutput = AVCapturePhotoOutput()
  
  let videoQueue = DispatchQueue(label: "com.stefankollaart.video", qos: .userInitiated)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    setupCaptureSession()
    setUpPreview()
    startSession()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Setup Capture Session & Preview
    func defaultDevice() -> AVCaptureDevice {
        if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInDuoCamera,
                                                      mediaType: AVMediaTypeVideo,
                                                      position: .front) {
            return device // use dual camera on supported devices
        } else if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                                                             mediaType: AVMediaTypeVideo,
                                                             position: .front) {
            return device // use default back facing camera otherwise
        } else {
            fatalError("All supported devices are expected to have at least one of the queried capture devices.")
        }
    }
    

  func setupCaptureSession() {
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto
    let camera = defaultDevice()
    
    do {
      let input = try AVCaptureDeviceInput(device: camera)
      if captureSession.canAddInput(input) {
        captureSession.addInput(input)
        activeInput = input
      }
    } catch {
      print("Error setting up device input: \(error.localizedDescription)")
    }
    imageOutput.isHighResolutionCaptureEnabled = true
    
    if captureSession.canAddOutput(imageOutput) {
      captureSession.addOutput(imageOutput)
    }
  }
  
  func setUpPreview() {
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = cameraPreview.bounds
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    cameraPreview.layer.addSublayer(previewLayer)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if let connection = self.previewLayer?.connection  {
      let currentDevice: UIDevice = UIDevice.current
      let orientation: UIDeviceOrientation = currentDevice.orientation
      let previewLayerConnection : AVCaptureConnection = connection
      if previewLayerConnection.isVideoOrientationSupported {
        switch (orientation) {
        case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
          break
        case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
          break
        case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
          break
        case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
          break
        default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
          break
        }
      }
    }
  }
  
  private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
    layer.videoOrientation = orientation
    previewLayer.frame = self.view.bounds
  }
  
  func startSession() {
    if !captureSession.isRunning {
      videoQueue.async {
        self.captureSession.startRunning()
      }
    }
  }
  
  func stopRunning() {
    if captureSession.isRunning {
      videoQueue.async {
        self.captureSession.stopRunning()
      }
    }
  }
  
  @IBAction func capturePhoto(_ sender: UIButton) {
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "quicklook")
    self.present(nextViewController, animated:false, completion:nil)
    
  }
  
  func currentVideoOrientation() -> AVCaptureVideoOrientation {
    var orientation: AVCaptureVideoOrientation
    
    switch UIDevice.current.orientation {
    case .portrait:
      orientation = AVCaptureVideoOrientation.portrait
    case .landscapeRight:
      orientation = AVCaptureVideoOrientation.landscapeLeft
    case .portraitUpsideDown:
      orientation = AVCaptureVideoOrientation.portraitUpsideDown
    default:
      orientation = AVCaptureVideoOrientation.landscapeRight
    }
    
    return orientation
  }
  
  
}

