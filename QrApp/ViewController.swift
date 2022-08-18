//
//  ViewController.swift
//  QrApp
//
//  Created by Celil Aydın on 18.08.2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    var qrCodeFrameView : UIView?

    
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
           guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
               print("Failed camera device")
               return
           }
           
           do {
               
               
               let input = try AVCaptureDeviceInput(device: captureDevice)
               
               
               captureSession.addInput(input)
               
               
               let caputureMetadataOutput = AVCaptureMetadataOutput()
               captureSession.addOutput(caputureMetadataOutput)
               
               
               caputureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
               caputureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
               
               
               videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
               videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
               videoPreviewLayer?.frame = view.layer.bounds
               view.layer.addSublayer(videoPreviewLayer!)
               
               
               captureSession.startRunning()
               
               
               view.bringSubviewToFront(messageLabel)
               view.bringSubviewToFront(topBar)
               
               
               qrCodeFrameView = UIView()
               
               if let qrcodeFrameView = qrCodeFrameView {
                   qrcodeFrameView.layer.borderColor = UIColor.yellow.cgColor
                   qrcodeFrameView.layer.borderWidth = 2
                   view.addSubview(qrcodeFrameView)
                   view.bringSubviewToFront(qrcodeFrameView)
               }
               
               
           }catch {
               print(error)
               return
           }
    }


}

extension ViewController : AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "QR Code"
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
}

