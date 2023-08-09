//
//  ViewController.swift
//  Scanner
//
//  Created by Nishant Taneja on 01/03/21.
//

import UIKit
import AVFoundation
import WhatsNew

class ViewController: UIViewController {
    // Variables
    private let captureSession = AVCaptureSession()
    private let captureDevice = AVCaptureDevice.default(for: .video)
    private var video: AVCaptureVideoPreviewLayer!
    private let metadataObjectTypes: [AVMetadataObject.ObjectType] = [.code128, .ean13, .qr]
    
    // IBAction
    @IBAction private func startScanning(_ sender: UIButton) {
        // Pop-Over Camera and begin scanning
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            imagePickerController.sourceType = .camera
//            imagePickerController.modalPresentationStyle = .popover
//            present(imagePickerController, animated: true, completion: nil)
//        }
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            if let captureDevice {
                let captureInput = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(captureInput)
            }
        } catch {
            print(error.localizedDescription)
        }
        let captureOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureOutput)
        captureOutput.setMetadataObjectsDelegate(self, queue: .main)
        if captureOutput.availableMetadataObjectTypes.contains(where: { metadataObjectTypes.contains($0) }) {
            captureOutput.metadataObjectTypes = metadataObjectTypes
        }
        video = AVCaptureVideoPreviewLayer(session: captureSession)
        video.frame = view.frame
        view.layer.addSublayer(video)
//        captureSession.startRunning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayWhatsNew()
    }
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count != 0,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObjectTypes.contains(object.type) else {
            // Error: unable to proceed for some reasons
            return
        }
        let alertController = UIAlertController(title: "Found Something!", message: object.stringValue, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Retake", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Proceed", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - What's New
extension ViewController {
    private func displayWhatsNew() {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let controller = WNViewController(items: [
            WNItem(image: .init(systemName: "chevron.left.forwardslash.chevron.right")!, title: "Display New Features Only Once", description: "If the current app version is not same as saved by WhatsNew Library, only then What's New screen will be displayed."),
            WNItem(image: .init(systemName: "newspaper")!, title: "What's New", description: "Discover new features. When new features are added, they will be displayed here."),
            WNItem(image: .init(systemName: "barcode.viewfinder")!, title: "Barcode Scan", description: "Scan any Barcode. The result will be displayed in alert sheet."),
            WNItem(image: .init(systemName: "qrcode.viewfinder")!, title: "QR Code Scan", description: "Scan any QR Code. The result will be displayed in alert sheet.")
        ], appVersion: appVersion)
        guard controller.shouldDisplayWhatsNew() else { return }
        present(controller, animated: true)
    }
}
