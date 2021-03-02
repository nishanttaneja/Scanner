//
//  ViewController.swift
//  Scanner
//
//  Created by Nishant Taneja on 01/03/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    // Variables
    private let captureSession = AVCaptureSession()
    private let captureDevice = AVCaptureDevice.default(for: .video)!
    private var video: AVCaptureVideoPreviewLayer!
    
    // IBAction
    @IBAction private func startScanning(_ sender: UIButton) {
        // Pop-Over Camera and begin scanning
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            imagePickerController.sourceType = .camera
//            imagePickerController.modalPresentationStyle = .popover
//            present(imagePickerController, animated: true, completion: nil)
//        }
    }
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let captureInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureInput)
        } catch {
            print(error.localizedDescription)
        }
        let captureOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureOutput)
        captureOutput.setMetadataObjectsDelegate(self, queue: .main)
        captureOutput.metadataObjectTypes = [.code128, .qr]
        video = AVCaptureVideoPreviewLayer(session: captureSession)
        video.frame = view.frame
        view.layer.addSublayer(video)
        captureSession.startRunning()
    }
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count != 0,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              [AVMetadataObject.ObjectType.qr, .code128].contains(object.type) else {
            // Error: unable to proceed for some reasons
            return
        }
        let alertController = UIAlertController(title: "Found Something!", message: object.stringValue, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Retake", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Proceed", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

