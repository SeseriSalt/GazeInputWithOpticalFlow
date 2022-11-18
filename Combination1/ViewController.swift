
//
//  ViewController.swift
//  Vision Face Detection
//
//  Created by Pawel Chmiel on 21.06.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import UIKit
import AVFoundation //カメラに関するフレームワーク
import Vision       //顔検出で使用
import CoreMotion//背面タップで使用


final class ViewController: UIViewController {
    var OpenCV = openCV()
    var session: AVCaptureSession? //デバイスからの入力と出力を管理するオブジェクト
    let shapeLayer = CAShapeLayer()//
    let shapeLayer_l = CAShapeLayer()//
    let shapeLayer_r = CAShapeLayer()//
    let textLayer = CATextLayer()
    let center = CATextLayer()
    let topright = CATextLayer()
    let topleft = CATextLayer()
    let bottomright = CATextLayer()
    let bottomleft = CATextLayer()
    
    
    let faceDetection = VNDetectFaceRectanglesRequest()//顔検出のリクエスト
    let faceDetectionRequest = VNSequenceRequestHandler()//複数の画像に関連する画像解析要求を処理するオブジェクト
    let faceLandmarks = VNDetectFaceLandmarksRequest()//顔のランドマーク検出リクエスト
    let faceLandmarksDetectionRequest = VNSequenceRequestHandler()//複数の画像に関連する画像解析要求を処理するオブジェクト
    
    var i: Int = 0//
    //トリミング用
    var Rmaxx : CGFloat = 0
    var Rmaxy : CGFloat = 0
    var Rminx : CGFloat = 0
    var Rminy : CGFloat = 0
    var Lmaxx : CGFloat = 0
    var Lmaxy : CGFloat = 0
    var Lminx : CGFloat = 0
    var Lminy : CGFloat = 0
    
    var clipx : CGFloat! = 0
    var clipy : CGFloat! = 0
    var clipwidth : CGFloat!
    var clipheight : CGFloat!
    var clipxL : CGFloat! = 0
    var clipyL : CGFloat! = 0
    var clipwidthL : CGFloat!
    var clipheightL : CGFloat!
    var clipxR : CGFloat! = 0
    var clipyR : CGFloat! = 0
    var clipwidthR : CGFloat!
    var clipheightR : CGFloat!
    
    var clipRect : CGRect!
    var clipRectL : CGRect!
    var clipRectR : CGRect!
    var maxx : CGFloat = 0
    var maxy : CGFloat = 0
    var minx : CGFloat = 0
    var miny : CGFloat = 0
    var rectx : CGFloat = 0
    var recty : CGFloat = 0
    var rectx_l : CGFloat = 0
    var recty_l : CGFloat = 0
    var rectx_r : CGFloat = 0
    var recty_r : CGFloat = 0
    var croppedEyes : CIImage!
    var croppedEyesL : CIImage!
    var croppedEyesR : CIImage!
    var prev_croppedEyes : CIImage!
    var prev_croppedEyesL : CIImage!
    var prev_croppedEyesR : CIImage!
    var pprev_croppedEyes : CIImage!
    var prev_clipRect :CGRect!
    var prev_clipRectL :CGRect!
    var prev_clipRectR :CGRect!
    
    
    let context = CIContext(options: nil)
    
    // 画像インスタンス用(入力選択肢)
    let imageSample = CATextLayer()
    
    var pre_clipx : CGFloat = 0
    var pre_clipy : CGFloat = 0
    var old_clipx : CGFloat = 0
    var old_clipy : CGFloat = 0
    
    //オプティカルフロー用
    var prev_ciImageWithOrientation: CIImage!
    var prev_prev: CIImage!
    var flowx = [Double]();
    var flowy = [Double]();
    var absDifLR = [Double]();
    
    
    //ウインクでの判別用
    var winkFlag : Int = 0
    var first_numberLR = 0
    var second_number = 0
    var MaxLR : Double = 0
    var MinLR : Double = 0
    
    
    //被験者に合わせて調整するやつ
    let ikichi: Double = 1.0   //閾値 1.0
    let teiryu: Int = 18       //停留時間 35
    let ikichiLR : Double = 1.3
    
    let ikichiLRMin : Double = -1.3
    
    
    //入力判別用
    var mabataki: Int = 0
    var inputchecker: Int = 0
    var old_firstnum : Int = 0
    var old_inputchecker: Int = 0
    var ouro: Int = 0
    var ouro_x: Double = 0.0
    var fukuro: Int = 0
    var fukuro_x: Double = 0.0
    
    var first_number: Int = 0
    var color : CGColor = UIColor.white.cgColor
    var out_put: Int = 0
    var old_output: Int = 0
    var old_mabataki: Int = 0
    var giza: Int = 0
    var vgiza: Int = 0
    
    
    //    //目を瞑る用///
    //    var HeightArray : [Double] = [0.0,0.0,0.0,0.0,0.0,0.0]
    
    
    //背面タップ・入力用////////
    // MotionManager
    let motionManager = CMMotionManager()
    var MotionArray :[Double] = [-0.7]//加速度データ格納
    var zFlag = 0
    var InputFlag = 0//背面タップありなし
    var InToOut = 0//内側選択肢か外側選択肢か
    var TapCount = 0//０回目の入力か１回目の入力か
    //    var ImageNum = 0// 選択肢画像の番号
    var ImmediatelyAfter = 0//背面タップ直後にeyeglanceをしないための変数
    var accelerometerZ = CATextLayer()//加速度の差分表示ラベル
    var tapp = CATextLayer()//背面タップ奇数偶数ラベル
    var Sabun :Double = 0.0
    
    //入力文字表示用
    var InputText = CATextLayer()
    var TextString :[String] = []
    
    //お題の文字表示のためのやつ
    var Example = CATextLayer()
    var SampleList : [String] = ["wink", "Left", "Left", "Left", "Left", "Left", "Left", "Left", "Left", "Left", "Left", "Right", "Right", "Right", "Right", "Right", "Right", "Right", "Right", "Right", "Right"]
    //    var SampleList : [String] = ["a", "a", "e", "0", "↩︎"]
    var SampleInt : Int = 0
    //    var SampleInt : Int = 0
    
    //タイマー
    var timer: Timer!
    ////出力された文字の入力時間
    var now1_start : Double = 0.00
    var now1_end : Double!
    //1試行ごとの入力時間（切り替えも含む）
    var now2_start : Double = 0.00
    var now2_end : Double!
    //実験データ収集
    var TimeChecker : String = ""
    var TimeChecker_try : String = ""
    var ErrorChecker : Int = 0
    var InPutType : Int = 0  //入力の種類→ 1：背面タップなし　2：2回目背面タップあり　3：1回目背面タップあり　4：背面タップ2回
    var Success : String = ""
    
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer? = {      //カメラの取得している映像の表示
        guard let session = self.session else { return nil }
        
        var previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspect
        
        return previewLayer
    }()
    
    
    
    var frontCamera: AVCaptureDevice? = {//強制的にインカメにしてる？？
        return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sessionPrepare()//カメラのセットアップ（下にコードあり）
        session?.startRunning()//AVCaptureSessionの開始
        
        //背面タップ用
        //        if motionManager.isAccelerometerAvailable {
        //            // intervalの設定 [sec]
        //            motionManager.accelerometerUpdateInterval = 0.005  //0.005
        //            // センサー値の取得開始
        //            motionManager.startAccelerometerUpdates(
        //                            to: OperationQueue.current!,
        //                            withHandler: {(accelData: CMAccelerometerData?, errorOC: Error?) in
        //                                self.outputAccelData(acceleration: accelData!.acceleration)
        //                        })
        //
        //        }
        
        
    }
    
    override func viewDidLayoutSubviews() {//ビューの位置を調整し直したあと（最後）に呼び出される
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.frame     //カメラの映像表示のやつ
        
        
        shapeLayer.frame = view.frame
        shapeLayer_l.frame = view.frame
        shapeLayer_r.frame = view.frame
        textLayer.frame = view.frame
        center.frame = CGRect(x: (view.frame.origin.x + view.frame.size.width) / 2 - 12.5, y: (view.frame.origin.y + view.frame.size.height) / 2 - 50, width: 50, height: 50)
        topright.frame = CGRect(x: (view.frame.size.width) - 45, y: (view.frame.origin.y) + 35, width: 50, height: 50)
        topleft.frame = CGRect(x: view.frame.origin.x - 5, y: (view.frame.origin.y) + 35, width: 50, height: 50)
        bottomright.frame = CGRect(x: (view.frame.size.width) - 45, y: (view.frame.size.height) - 85, width: 50, height: 50)
        bottomleft.frame = CGRect(x: view.frame.origin.x - 5, y: (view.frame.size.height) - 85, width: 50, height: 50)
        
        
        //背面タップ用の画面表示
        //        accelerometerZ.frame = CGRect(x: (view.frame.origin.x + view.frame.size.width) / 2 - 75, y: (view.frame.origin.y + view.frame.size.height) / 2 - 100, width: 300, height: 50)
        //        tapp.frame = CGRect(x: (view.frame.origin.x + view.frame.size.width) / 2 - 12.5, y: (view.frame.origin.y + view.frame.size.height) / 2 + 50 , width: 50, height: 50)
        //入力文字の表示
        InputText.frame = CGRect(x: (view.frame.origin.x + view.frame.size.width) / 2 - 135, y: (view.frame.origin.y + view.frame.size.height) / 2 - 140, width: 280, height: 20)
        
        //お題の表示
        Example.frame = CGRect(x: (view.frame.origin.x + view.frame.size.width) / 2-135, y: (view.frame.origin.y + view.frame.size.height) / 2 - 170, width: 280, height: 30)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {//ビューが完全にスクリーン上に表示された時に呼ばれる
        super.viewDidAppear(animated)
        guard let previewLayer = previewLayer else { return }       //カメラの映像表示のやつ
        view.layer.addSublayer(previewLayer)                        //カメラの映像表示のやつ
        
        //図形の描画．Visionで得られる座標が上下左右反対だから合わせる
        shapeLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: -1))
        shapeLayer_l.setAffineTransform(CGAffineTransform(scaleX: -1, y: -1))
        shapeLayer_r.setAffineTransform(CGAffineTransform(scaleX: -1, y: -1))
        textLayer.setAffineTransform(CGAffineTransform(scaleX: 1, y: 1))
        view.layer.addSublayer(textLayer)
        view.layer.addSublayer(shapeLayer)
        view.layer.addSublayer(shapeLayer_l)
        view.layer.addSublayer(shapeLayer_r)
        
        
        
        //        画面中心に＋マーク
        center.string = "+"
        center.foregroundColor = UIColor.black.cgColor
        center.fontSize = 50.0
        center.contentsScale = UIScreen.main.scale
        center.opacity = 0.5
        view.layer.addSublayer(center)
        
        
        
        //テキスト表示
        InputText.string = "テキスト"
        InputText.foregroundColor = UIColor.black.cgColor
        InputText.fontSize = 17.0
        InputText.backgroundColor = UIColor.gray.cgColor
        //        InputText.opacity = 0.5//透明度
        //        InputText.shadowColor = UIColor.white.cgColor
        //        InputText.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.addSublayer(InputText)
        
        //t self.Sample = SampleList0.randomElement()
        Example.string = SampleList[SampleInt]
        Example.foregroundColor = UIColor.black.cgColor
        Example.fontSize = 25.0
        Example.backgroundColor = UIColor.lightGray.cgColor
        //        Example.opacity = 0.9//透明度
        //        Example.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.addSublayer(Example)
        
        
        
        let screenW:CGFloat = view.frame.size.width
        let screenH:CGFloat = view.frame.size.height
        
        //時間計測開始
        now1_start = GetDate().timeIntervalSince1970
        now2_start = GetDate().timeIntervalSince1970
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //timer.invalidate()
        motionManager.stopAccelerometerUpdates()
    }
    
    
    
    //    カメラのセットアップ
    func sessionPrepare() {
        session = AVCaptureSession()
        guard let session = session, let captureDevice = frontCamera else { return }
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            session.beginConfiguration()
            
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            
            output.alwaysDiscardsLateVideoFrames = true
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.commitConfiguration()
            let queue = DispatchQueue(label: "output.queue")
            output.setSampleBufferDelegate(self, queue: queue)
            print("setup delegate")
        } catch {
            print("can't setup session")
        }
    }
    
    func GetDate()-> Date{
        let noww = Date()
        return noww
    }
    
    
}



extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    //１フレームごとに処理する関数
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //        Visionで用いる画像はCIImage型にする必要がある
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as! [CIImageOption : Any]?)
        
        
        //leftMirrored for front camera
        let ciImageWithOrientation = ciImage.oriented(forExifOrientation: Int32(UIImage.Orientation.leftMirrored.rawValue))
        
        //Let's 顔検出
        detectFace(on: ciImageWithOrientation)
        
        
        
        var array:[Double] = [0.0, 0.0]
        var arrayL:[Double] = [0.0, 0.0]
        var arrayR:[Double] = [0.0, 0.0]
        //var parray:[Double] = [0.0, 0.0, 0.0, 0.0]
        
        var point_x : CGFloat = 0
        var point_y : CGFloat = 0
        
        //        var GetTime : [Double]
        if(Rmaxx > 0 && prev_ciImageWithOrientation != nil){
            
            clipx = minx * ciImageWithOrientation.extent.width / self.view.bounds.width
            clipy =  (miny-10) * ciImageWithOrientation.extent.height / self.view.bounds.height
            clipwidth = (maxx - minx) * ciImageWithOrientation.extent.width / self.view.bounds.width
            clipheight = (maxx - minx)/4 * ciImageWithOrientation.extent.width / self.view.bounds.width
            
            clipxL = (Lminx-10) * ciImageWithOrientation.extent.width / self.view.bounds.width
            clipyL =  (miny-10) * ciImageWithOrientation.extent.height / self.view.bounds.height
            clipwidthL = (Lmaxx - Lminx) * ciImageWithOrientation.extent.width / self.view.bounds.width
            clipheightL = (Lmaxx - Lminx)*0.8 * ciImageWithOrientation.extent.width / self.view.bounds.width
            
            clipxR = Rminx * ciImageWithOrientation.extent.width / self.view.bounds.width
            clipyR = (miny-10) * ciImageWithOrientation.extent.height / self.view.bounds.height
            clipwidthR = (Rmaxx - Rminx) * ciImageWithOrientation.extent.width / self.view.bounds.width
            clipheightR = (Rmaxx - Rminx)*0.8 * ciImageWithOrientation.extent.width / self.view.bounds.width
            
            //                print(clipx, clipxL, clipxR)
            
            //目の範囲の矩形を取得
            clipRect = CGRect(x: clipx, y: clipy, width: clipwidth, height: clipheight)
            clipRectL = CGRect(x: clipxL, y: clipyL, width: clipwidthL, height: clipheightL)
            clipRectR = CGRect(x: clipxR, y: clipyR, width: clipwidthR, height: clipheightR)
            //print(clipx!, clipy!, clipwidth!, clipheight!, ciImageWithOrientation.extent.width / self.view.bounds.width, ciImageWithOrientation.extent.height / self.view.bounds.height, ciImageWithOrientation.extent.width / self.view.bounds.width, ciImageWithOrientation.extent.width / self.view.bounds.width)
            //目の範囲を元画像から切り取り
            croppedEyes = ciImageWithOrientation.cropped(to: clipRect)
            croppedEyesL = ciImageWithOrientation.cropped(to: clipRectL)
            croppedEyesR = ciImageWithOrientation.cropped(to: clipRectR)
            //            prev_croppedEyes = prev_ciImageWithOrientation!.cropped(to: clipRect)
            prev_croppedEyes = prev_ciImageWithOrientation!.cropped(to: clipRect) //試しに１つ前のnextをそのままprevで使ってみたけどダメだった     １つ前の画像から切り取る矩形は今の画像と同じ大きさじゃないとダメらしい
            prev_croppedEyesL = prev_ciImageWithOrientation!.cropped(to: clipRectL)
            prev_croppedEyesR = prev_ciImageWithOrientation!.cropped(to: clipRectR)
            
            //ciimage → cgimage
            let CGnext = context.createCGImage(croppedEyes, from: croppedEyes.extent)
            let CGnextL = context.createCGImage(croppedEyesL, from: croppedEyesL.extent)
            let CGnextR = context.createCGImage(croppedEyesR, from: croppedEyesR.extent)
            let prev_CGnext = context.createCGImage(prev_croppedEyes, from: prev_croppedEyes.extent)
            let prev_CGnextL = context.createCGImage(prev_croppedEyesL, from: prev_croppedEyesL.extent)
            let prev_CGnextR = context.createCGImage(prev_croppedEyesR, from: prev_croppedEyesR.extent)
            
            //            //cgimage → uiimage
            let next = UIImage(cgImage: CGnext!)
            let nextL = UIImage(cgImage: CGnextL!)
            let nextR = UIImage(cgImage: CGnextR!)
            //            let prev = UIImage(cgImage: prev_CGnext!)
            let prev = UIImage(cgImage: prev_CGnext!)
            let prevL = UIImage(cgImage: prev_CGnextL!)
            let prevR = UIImage(cgImage: prev_CGnextR!)
            
            
            //オプティカルフロー
            OpenCV.avop(prev, next, &array)
            OpenCV.avopLR(prevL, nextL, &arrayL)
            OpenCV.avopLR(prevR, nextR, &arrayR)
        }
        
        flowx.append(array[0])//
        flowy.append(array[1])
        absDifLR.append(arrayL[1] - arrayR[1])
        
        
        
        TimeChecker = ""
        TimeChecker_try = ""
        ErrorChecker = 0
        InPutType = 0
        Success = ""
        
        
        //ここから入力判定
        
        //        if(mabataki != 0 && i - mabataki > 6){
        //            mabataki = 0    //瞬きは余韻が大きいから，瞬きが発生してから１０フレーム以上経ってから入力再開
        //        }
        //
        if (winkFlag == 0 && absDifLR[i] > ikichiLR && i > 30 &&  i - vgiza > 6){
            winkFlag = 1 // 左ウィンク
            MaxLR = absDifLR[i]
            first_numberLR = i
            inputchecker = 0
        }
        else if (winkFlag == 0 && absDifLR[i] < ikichiLRMin && i > 30 &&  i - vgiza > 6){
            winkFlag = -1 //右ウィンク
            MaxLR = absDifLR[i]
            first_numberLR = i
            inputchecker = 0
        }
        // 左
        else if (winkFlag == 1 && absDifLR[i] > MaxLR){
            MaxLR = absDifLR[i]
            first_numberLR = i
        }
        else if (winkFlag == 1 && absDifLR[i] < ikichiLRMin){
            winkFlag = 2
        }
        else if (winkFlag == 2 && absDifLR[i] > ikichiLRMin){
            winkFlag = 4
            second_number = i
        }
        else if (winkFlag == 4 && i - second_number > 2 && i - second_number <= 10) {
            winkFlag = 6
        }
        else if (winkFlag == 4 && absDifLR[i] > ikichiLR) {
            winkFlag = -6
        }
        // 右
        else if (winkFlag == -1 && absDifLR[i] < MaxLR){
            MaxLR = absDifLR[i]
            first_numberLR = i
        }
        else if (winkFlag == -1 && absDifLR[i] > ikichiLR){
            winkFlag = -2
        }
        else if (winkFlag == -2 && absDifLR[i] < ikichiLR){
            winkFlag = -4
            second_number = i
        }
        else if (winkFlag == -4 && i - second_number > 2  && i - second_number <= 10) {
            winkFlag = -6
        }
        else if (winkFlag == -4 && absDifLR[i] < ikichiLRMin) {
            winkFlag = 6
        }
        
        if (winkFlag == 0 && inputchecker == 0   && i > 30 && i - vgiza > 6) {//往路波形の検出
            
            if(array[1] > ikichi && mabataki == 0) {    //正の閾値を超えた場合
                inputchecker = 1    //①へ
                ouro = i
                old_clipx = pre_clipx   //前の画像の座標
                old_clipy = pre_clipy
                
            }
            else if(array[1] < -ikichi && mabataki == 0) { //負の閾値を超えた場合
                inputchecker = -1   //-①へ
                old_clipx = pre_clipx   //前の画像の座標
                old_clipy = pre_clipy
                ouro = i
            }
            
            if(mabataki != 0 && i - mabataki > 6 && array[1] < ikichi){
                mabataki = 0    //瞬きは余韻が大きいから，瞬きが発生してから１０フレーム以上経ってから入力再開
            }
        }
        
        else if(inputchecker == 1) {    //①
            if(array[1] < ikichi){     //閾値以下に戻った場合
                if(array[1] < -ikichi) { //いきなり負の閾値を超えた場合
                    inputchecker = 0    //ウインクの誤作動?
                    //                        color = UIColor.white.cgColor
                    mabataki = i
                }
                else if (array[1] < ikichi){
                    //垂直方向のピーク値を記録
                    var dumy: Double = 0
                    var maxpoint: Int = 0
                    for n in ouro ..< i {
                        if (flowy[n] >= dumy){
                            maxpoint = n;
                            dumy = flowy[n];
                        }
                    }
                    if winkFlag == 0{
                        point_x = clipx - old_clipx     //入力波形の座標の変化を取得してみたけど，あんまり意味なかった
                        point_y = clipy - old_clipy
                        
                        //水平方向のピーク値を記録
                        ouro_x = (flowx[maxpoint] + flowx[maxpoint - 1] + flowx[maxpoint + 1]) / 3;
                        inputchecker = 2    //②へ
                        first_number = i    //停留時間スタート
                    }
                }
            }
        }
        
        
        else if(inputchecker == 2) {    //②復路波形の検出
            if(i - first_number > teiryu){      //停留時間が一定値を超えた場合
                inputchecker = 0                //最初からやり直し
                
            }
            else if(array[1] < -ikichi){//負の閾値を超えた場合
                /*  if(i - first_number < 3 && winkFlag == 0){      //停留時間が短すぎる場合
                 inputchecker = 0          //ウインクの誤作動？？
                 //                       color = UIColor.white.cgColor
                 //                       mabataki = i
                 
                 }*/
                //                    else{
                inputchecker = 3           //③へ
                fukuro = i
                
                old_clipx = pre_clipx   //前の画像の座標
                old_clipy = pre_clipy
                //                    }
            }
        }
        
        else if(inputchecker == 3){ //③
            if(array[1] > -ikichi){     //閾値以下に戻った場合
                point_x = clipx - old_clipx
                point_y = clipy - old_clipy
                
                //垂直方向のピーク値を記録
                var dumy: Double = 0
                var maxpoint: Int = 0
                for n in fukuro ..< i {
                    if (flowy[n] <= dumy){
                        maxpoint = n;
                        dumy = flowy[n];
                    }
                }
                
                //水平方向のピークの数値を記録
                fukuro_x = (flowx[maxpoint] + flowx[maxpoint - 1] + flowx[maxpoint + 1]) / 3;
                
                if(fukuro_x * ouro_x < 0){  //復路波形ならば入力判定
                    if(ouro_x > 0){
                        out_put = 1      //右上！！！！！！！！！！！！！！！
                        color = UIColor.red.cgColor
                        vgiza = i
                        
                    }  else{
                        out_put = 2      //左上！！！！！！！！！！！！！！！
                        color = UIColor.blue.cgColor
                        vgiza = i
                        
                    }
                }   else {      //水平方向の正負方向が往復で同じ場合，大きい方で判定
                    if(ouro_x > fukuro_x){
                        out_put = 1      //右上！！！！！！！！！！！！！！！
                        color = UIColor.red.cgColor
                        vgiza = i
                        
                        
                    }   else{
                        out_put = 2      //左上！！！！！！！！！！！！！！！！
                        color = UIColor.blue.cgColor
                        vgiza = i
                        
                    }
                }
                inputchecker = 0
            }
            
        }
        
        else if(inputchecker == -1){       //-①
            if(array[1] > -ikichi){
                
                if(array[1] > ikichi) { //いきなり正の閾値を超えた場合
                    inputchecker = 0    //まばたき？？
                    color = UIColor.white.cgColor
                    mabataki = i
                }
                else if(array[1] > -ikichi){      //閾値以下に戻った場合
                    point_x = clipx - old_clipx
                    point_y = clipy - old_clipy
                    //垂直方向のピーク値を記録
                    var dumy: Double = 0
                    var maxpoint: Int = 0
                    for n in ouro ..< i {
                        if (flowy[n] <= dumy){
                            maxpoint = n;
                            dumy = flowy[n];
                        }
                    }
                    
                    //水平方向のピークの数値を記録
                    ouro_x = (flowx[maxpoint] + flowx[maxpoint - 1] + flowx[maxpoint + 1]) / 3;
                    
                    inputchecker = -2   //−②へ
                    first_number = i        //停留時間スタート
                }
            }
        }
        
        
        
        else if(inputchecker == -2){    //−②復路波形の検出
            if(i - first_number > teiryu){      //停留時間が一定値を超えた場合
                inputchecker = 0                //最初からやり直し
                
            }else if(array[1] > ikichi){//正の閾値を超えた場合
                if(i - first_number < 3){      //停留時間が短すぎる場合
                    inputchecker = 0          //まばたき？？
                    color = UIColor.white.cgColor
                    mabataki = i
                }else{
                    inputchecker = -3    //−③へ
                    old_clipx = pre_clipx   //前の画像の座標
                    old_clipy = pre_clipy
                    fukuro = i
                    
                }
            }
        }
        
        else if(inputchecker == -3){   //−③
            if(array[1] < ikichi){     //閾値以下に戻った場合
                point_x = clipx - old_clipx
                point_y = clipy - old_clipy
                //垂直方向のピーク値を記録
                var dumy: Double = 0
                var maxpoint: Int = 0
                for n in fukuro ..< i {
                    if (flowy[n] >= dumy){
                        maxpoint = n;
                        dumy = flowy[n];
                    }
                }
                
                //水平方向のピークの数値を記録
                fukuro_x = (flowx[maxpoint] + flowx[maxpoint - 1] + flowx[maxpoint + 1]) / 3;
                
                
                if(fukuro_x * ouro_x < 0){  //復路波形ならば入力判定
                    if(ouro_x > 0){
                        out_put = -1      //右下！！！！！！！！！！！！！！！
                        color = UIColor.yellow.cgColor
                        
                        vgiza = i
                        
                    }  else{
                        out_put = -2      //左下！！！！！！！！！！！！！！！
                        color = UIColor.green.cgColor
                        vgiza = i
                        
                    }
                }   else {      //水平方向の正負方向が往復で同じ場合，大きい方で判定
                    if(ouro_x > fukuro_x){
                        out_put = -1      //右下！！！！！！！！！！！！！！！
                        color = UIColor.yellow.cgColor
                        
                        vgiza = i
                        
                    }   else{
                        out_put = -2      //左下！！！！！！！！！！！！！！！
                        color = UIColor.green.cgColor
                        vgiza = i
                        
                    }
                }
                inputchecker = 0
            }//入力 終わり
            
        }//inputchecker == -3 終わり
        /*}*/
        
        
        if winkFlag == 6 {//切り替え
            color = UIColor.purple.cgColor
            out_put = 5
            TextString.append("R")
            
            winkFlag = 0
            first_numberLR = 0
            second_number = 0
            vgiza = i
        }
        
        if winkFlag == -6 {//切り替え
            color = UIColor.purple.cgColor
            out_put = 6
            TextString.append("L")
            
            winkFlag = 0
            first_numberLR = 0
            second_number = 0
            vgiza = i
        }
        
        if winkFlag != 0 && i - first_numberLR > 10 {//ウインクがうまく行かなかったとき元に戻す
            winkFlag = 0
            first_numberLR = 0
            second_number = 0
        }
        //        if inputchecker != 0 &&  i - first_number > teiryu {//Eye glance入力がうまく行かなかった時元に戻す　→ 何故が機能しない　firstnumber が定期的に0になっていないから？
        //           inputchecker = 0
        //            first_number = 0
        //        }
        
        //UIに入力文字を出力
        DispatchQueue.main.async {
            let str = self.TextString.joined(separator: "")
            self.InputText.string = str
        }
        
        //表示された入力例の文字入力に成功したら
        if (SampleList[SampleInt] == TextString.last) {
            //時間をカウント
            now1_end = GetDate().timeIntervalSince1970
            TimeChecker =  String(format: "%.2f", (now1_end - now1_start))
            //誤入力をカウント(誤入力0回の時：1)
            ErrorChecker = TextString.count
            //入力の種類を取得
            switch TextString.last {
            case "a", "b", "c", "d", "h", "i", "j", "k", "o", "p", "q", "r", "v", "w", "x", "y":
                InPutType = 1
            case "e", "f", "g", "l", "m", "n", "s", "t", "u", "z":
                InPutType = 2
            case "0", "1", "2", "3", "5", "6", "7", "8", "改行", "空白", "delete":
                InPutType = 3
            case "4", "9":
                InPutType = 4
            default:
                InPutType = 5
            }
            //成功した文字を取得
            Success = TextString.last!
            
            //配列から入力した文字を削除
            SampleList.remove(at: SampleInt)
            //配列がなくなったら終わり
            if SampleList.count == 0{
                SampleList = ["終わり！！！!"]
                SampleInt = 0
                ErrorChecker = ErrorChecker + 111111000 //終わりの合図
                DispatchQueue.main.async {
                    self.Example.string = "終わり！！！！"
                    self.TextString = []
                }
            }
            else{//配列がまだあったら
                //新しく入力してもらう文字をランダムに表示
                SampleInt = Int.random(in: 0..<SampleList.count)
                DispatchQueue.main.async {
                    self.Example.string = self.SampleList[self.SampleInt]
                    self.TextString = []
                }
            }
            //時間をリセット
            now1_start = GetDate().timeIntervalSince1970
            
        }
        //正解にしろ不正解にしろ入力が行われた時
        if out_put != 0 {
            //1試行あたりの時間をカウント
            now2_end = GetDate().timeIntervalSince1970
            TimeChecker_try =  String(format: "%.2f", (now2_end - now2_start))
            now2_start = GetDate().timeIntervalSince1970
        }
        
        // 出力
        print(i,", ",arrayL[1], ",", arrayR[1], ",", arrayL[1] - arrayR[1], ",", out_put, ",", winkFlag, ",", mabataki, ",", second_number, ",", TimeChecker_try, ",",Success,",", InPutType, ",", TimeChecker, ",", ErrorChecker)
        
        prev_clipRect = clipRect  //いらない？
        prev_ciImageWithOrientation = ciImageWithOrientation
        
        if(out_put != 0) {
            out_put = 0
        }
        if(old_output != 0){
            old_output = 0
        }
        
        pre_clipx = clipx
        pre_clipy = clipy
        
        i+=1   //フレーム数の表示が変わる（画面上）
        
        /////////////フレームレート確認用//
        //        now2 = GetDate().timeIntervalSince1970
        //        print(String(format: "%.4f", (now2 - now)))
        //        now = GetDate().timeIntervalSince1970
        
        
    }
}



//ここから目検出．詳しく知りたきゃ"ios vision"でググってください
extension ViewController {
    
    func detectFace(on image: CIImage) {
        try? faceDetectionRequest.perform([faceDetection], on: image)
        if let results = faceDetection.results as? [VNFaceObservation] {
            if !results.isEmpty {
                faceLandmarks.inputFaceObservations = results
                detectLandmarks(on: image)
                
                DispatchQueue.main.async {
                    self.shapeLayer.sublayers?.removeAll()
                    self.textLayer.sublayers?.removeAll()
                    self.shapeLayer_l.sublayers?.removeAll()
                    self.shapeLayer_r.sublayers?.removeAll()
                }
            }
        }
    }
    
    
    func detectLandmarks(on image: CIImage) {
        try? faceLandmarksDetectionRequest.perform([faceLandmarks], on: image)
        if let landmarksResults = faceLandmarks.results as? [VNFaceObservation] {
            for observation in landmarksResults {
                DispatchQueue.main.async {
                    if let boundingBox = self.faceLandmarks.inputFaceObservations?.first?.boundingBox {
                        let faceBoundingBox = boundingBox.scaled(to: self.view.bounds.size)
                        
                        //左目の検出
                        let leftEye = observation.landmarks?.leftEye
                        self.convertPointsForFace(leftEye, faceBoundingBox, 0)
                        //右目の検出
                        let rightEye = observation.landmarks?.rightEye
                        self.convertPointsForFace(rightEye, faceBoundingBox, 1)
                        
                        //唇(内側)の検出
                        let lips = observation.landmarks?.innerLips
                        self.convertPointsForFace(lips, faceBoundingBox, 2)
                    }
                }
            }
        }
    }
    
    func convertPointsForFace(_ landmark: VNFaceLandmarkRegion2D?, _ boundingBox: CGRect, _ t: Int) {
        if let points = landmark?.normalizedPoints, let count = landmark?.pointCount {
            let convertedPoints = convert(points, with: count)
            
            let faceLandmarkPoints = convertedPoints.map { (point: (x: CGFloat, y: CGFloat)) -> (x: CGFloat, y: CGFloat) in
                let pointX = point.x * boundingBox.width + boundingBox.origin.x
                let pointY = point.y * boundingBox.height + boundingBox.origin.y
                
                //                print("x: \(pointX), y: \(pointY)")
                return (x: pointX, y: pointY)
            }
            
            DispatchQueue.main.async {
                self.draw(points: faceLandmarkPoints, t: t)
            }
        }
    }
    
    func draw(points: [(x: CGFloat, y: CGFloat)], t: Int) {
        let newLayer = CAShapeLayer()
        newLayer.strokeColor = color
        newLayer.lineWidth = 5.0
        let newLayer_l = CAShapeLayer()
        newLayer_l.strokeColor = UIColor.cyan.cgColor
        newLayer_l.lineWidth = 2.0
        let newLayer_r = CAShapeLayer()
        newLayer_r.strokeColor = UIColor.magenta.cgColor
        newLayer_r.lineWidth = 2.0
        
        let text = CATextLayer()
        if self.ImmediatelyAfter == 0{
            text.foregroundColor = UIColor.black.cgColor
        }
        else{
            text.foregroundColor = UIColor.red.cgColor
        }
        text.string  = String(i)
        
        
        //目の座標の最大値と最小値を取得
        ////まず初期化(座標の配列の最初の値を代入)
        if(t == 0){
            
            Lmaxx = points[0].x
            Lmaxy = points[0].y
            Lminx = points[0].x
            Lminy = points[0].y
        }else if(t == 1){
            
            Rmaxx = points[0].x
            Rmaxy = points[0].y
            Rminx = points[0].x
            Rminy = points[0].y
        }
        ////最大値と最小値を探して代入
        for i in 0..<points.count - 1  {
            
            if(t == 0){
                
                if points[i].x > Lmaxx {
                    Lmaxx = points[i].x
                }
                if points[i].y > Lmaxy {
                    Lmaxy = points[i].y
                }
                if points[i].x < Lminx {
                    Lminx = points[i].x
                }
                if points[i].y < Lminy {
                    Lminy = points[i].y
                }
                
            }else if(t == 1){
                
                if points[i].x > Rmaxx {
                    Rmaxx = points[i].x
                }
                if points[i].y > Rmaxy {
                    Rmaxy = points[i].y
                }
                if points[i].x < Rminx {
                    Rminx = points[i].x
                }
                if points[i].y < Rminy {
                    Rminy = points[i].y
                }
            }
        }
        
        
        
        if(t == 1){
            
            maxx = max(Lmaxx, Rmaxx)
            maxy = max(Lmaxy, Rmaxy)
            minx = min(Lminx, Rminx)
            miny = min(Lminy, Rminy)
            
            //矩形を描画．最大値と最小値をそのまま結ぶと，目の端っこが入らないため，いろいろ調整してる
            rectx = (maxx+minx)/2 - ((maxx+minx)/2 - minx)*6/5
            recty = (maxy+miny)/2 - ((maxy+miny)/2 - miny)*6/5
            
            //高さはまばたきで幅がめっちゃ小さくなるため，広さに合わせる
            //        let path = UIBezierPath(rect: CGRect(x: minx, y: miny - 10, width: (maxx - minx), height: (maxx - minx)/4))
            //        newLayer.path = path.cgPath
            //        shapeLayer.addSublayer(newLayer)//←目の位置の表示
            
            //片目ずつの矩形を描画
            //左目
            rectx_l = (Lmaxx+Lminx)/2 - ((Lmaxx+Lminx)/2 - Lminx)*6/5
            recty_l = (Lmaxy+Lminy)/2 - ((Lmaxy+Lminy)/2 - Lminy)*6/5
            let path_l = UIBezierPath(rect: CGRect(x: Lminx-10, y: miny - 10, width: (Lmaxx - Lminx)+10, height: (Lmaxx - Lminx)*0.8))
            newLayer_l.path = path_l.cgPath
            shapeLayer_l.addSublayer(newLayer_l)//←左目の位置の表示
            //右目
            rectx_r = (Rmaxx+Rminx)/2 - ((Rmaxx+Rminx)/2 - Rminx)*6/5
            recty_r = (Rmaxy+Rminy)/2 - ((Rmaxy+Rminy)/2 - Rminy)*6/5
            let path_r = UIBezierPath(rect: CGRect(x: Rminx, y: miny - 10, width: (Rmaxx - Rminx)+10, height: (Rmaxx - Rminx)*0.8))
            newLayer_r.path = path_r.cgPath
            shapeLayer_r.addSublayer(newLayer_r)//←右目の位置の表示
            
            
            text.frame = CGRect(x: 180, y: 30, width: 100, height: 50)//←フレーム数の表示(画面上部)
            textLayer.addSublayer(text)
            
        }
    }
    
    
    func convert(_ points: UnsafePointer<CGPoint>, with count: Int) -> [(x: CGFloat, y: CGFloat)] {
        var convertedPoints = [(x: CGFloat, y: CGFloat)]()
        for i in 0...count {
            convertedPoints.append((CGFloat(points[i].x), CGFloat(points[i].y)))
        }
        
        return convertedPoints
    }
}






