//
//  openCV.m
//  Vision Face Detection
//
//  Created by 雑賀友 on 2020/10/22.
//  Copyright © 2020 Droids On Roids. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "openCV.h"
#import <time.h>

class C3DVec {
public:
    double x, y, r;
};


@implementation openCV
-(void)avop:(UIImage *)previmg :(UIImage *)nextimg :(double *)array{

    cv::Mat prev, next;
    UIImageToMat(previmg, prev);   //前フレーム
    UIImageToMat(nextimg, next);   //現在のフレーム
    
    resize(prev, prev, cv::Size(), 0.5, 0.5);    //処理速度を上げるために，画像サイズを縮小
    resize(next, next, cv::Size(), 0.5, 0.5);    //処理速度を上げるために，画像サイズを縮小

    cv::cvtColor(prev, prev, cv::COLOR_BGR2GRAY); //グレースケール変換
    cv::cvtColor(next, next, cv::COLOR_BGR2GRAY); //グレースケール変換
    

    

    

    //ここからオプティカルフロー
    std::vector<cv::Point2f> prev_pts;
        
    cv::Size flowSize(20, 20);  //15×15の点
    cv::Point2f center = cv::Point(prev.cols / 2., prev.rows / 2.);
    for (int i = 0; i < flowSize.width; ++i) {
        for (int j = 0; j < flowSize.height; ++j) {
            cv::Point2f p (i*double(prev.cols) / (flowSize.width - 1), j*double(prev.rows) / (flowSize.height - 1));
            prev_pts.push_back((p - center)*0.9f + center);
        }
    }
    cv::Mat flow;

    //Let'sオプティカルフロー
    cv::calcOpticalFlowFarneback(prev, next, flow, 0.5, 3, 15, 3, 5, 1.1, 0);
//    cv::calcOpticalFlowFarneback(prev, next, flow, 0.8, 10, 15, 3, 5, 1.1, 0);   こんへんの変数意味わからん

//    400個の計測点
    double pointmax = 20 * 20;
    std::vector<std::vector<double>>alloptical;
        alloptical.resize(pointmax);
        for (int a = 0; a < pointmax; a++)
            alloptical[a].resize(2);   //xとy
    
        int counter = 0;
        double aveX = 0, aveY = 0;
//        double devX = 0, devY = 0;

////    左右200個ずつの計測点
//    double pointmax_lr = 10 * 20;
//    std::vector<std::vector<double>>alloptical_l;
//    std::vector<std::vector<double>>alloptical_r;
//        alloptical_l.resize(pointmax_lr);
//        alloptical_r.resize(pointmax_lr);
//        for (int a = 0; a < pointmax_lr; a++){
//                alloptical_l[a].resize(2);   //xとy
//                alloptical_r[a].resize(2);   //xとy
//        }
        
        
//        int counter_l = 0, counter_r = 0;
//        double aveX_l = 0, aveY_l = 0;
//        double aveX_r = 0, aveY_r = 0;

    
    
        std::vector<cv::Point2f>::const_iterator p = prev_pts.begin();
        for (; p != prev_pts.end(); ++p) {
            const cv::Point2f& fxy = flow.at<cv::Point2f>(p->y, p->x);
            alloptical[counter][0] = fxy.x;
            alloptical[counter][1] = fxy.y;
            aveX = aveX + fxy.x;
            aveY = aveY + fxy.y;
            
//            if (counter < 200){
//                alloptical_l[counter][0] = fxy.x;
//                alloptical_l[counter][1] = fxy.y;
//                aveX_l = aveX_l + fxy.x;
//                aveY_l = aveY_l + fxy.y;
//            }
//            else{
//                alloptical_r[counter-200][0] = fxy.x;
//                alloptical_r[counter-200][1] = fxy.y;
//                aveX_r = aveX_r + fxy.x;
//                aveY_r = aveY_r + fxy.y;
//            }
            
//            if ((counter / 10) % 2 == 0){   //上とどっちかが正しい
//                alloptical_l[counter_l][0] = fxy.x;
//                alloptical_l[counter_l][1] = fxy.y;
//                aveX_l = aveX_l + fxy.x;
//                aveY_l = aveY_l + fxy.y;
//                counter_l++;
//            }
//            else{
//                alloptical_r[counter_r][0] = fxy.x;
//                alloptical_r[counter_r][1] = fxy.y;
//                aveX_r = aveX_r + fxy.x;
//                aveY_r = aveY_r + fxy.y;
//                counter_r++;
//            }
//
            counter++;
        }

        //平均
        aveX = aveX / counter;
        aveY = aveY / counter;
    
//        aveX_l = aveX_l / counter/2;
//        aveY_l = aveY_l / counter/2;
//        aveX_r = aveX_r / counter/2;
//        aveY_r = aveY_r / counter/2;

//        //分散値の算出
//        for (int c = 0; c < counter; c++) {
//        devX = devX + ((alloptical[c][0] - aveX)*(alloptical[c][0] - aveX));
//        devY = devY + ((alloptical[c][1] - aveY)*(alloptical[c][1] - aveY));
//        }
//
//        devX = devX / counter;
//        devY = devY / counter;

    
        int comp1, comp2;
        double dumyX, dumyY;
    
        
        //ｙ方向でソート処理
        for (comp1 = 0; comp1 <= pointmax; comp1++) {
            for (comp2 = comp1 + 1; comp2 < pointmax; comp2++) {
                if (abs(alloptical[comp1][1]) < abs(alloptical[comp2][1])) {
                    dumyY = alloptical[comp1][1];
                    alloptical[comp1][1] = alloptical[comp2][1];
                    alloptical[comp2][1] = dumyY;
                    
                    //ｘ方向は手ブレと混同しやすいため，ｙ成分と同じ箇所を取るようにする
                    dumyX = alloptical[comp1][0];
                    alloptical[comp1][0] = alloptical[comp2][0];
                    alloptical[comp2][0] = dumyX;

                }
            }
        }
    
//        for (comp1 = 0; comp1 <= pointmax_lr; comp1++) {
//            for (comp2 = comp1 + 1; comp2 < pointmax_lr; comp2++) {
//                if (abs(alloptical_l[comp1][1]) < abs(alloptical_l[comp2][1])) {
//                    dumyY = alloptical_l[comp1][1];
//                    alloptical_l[comp1][1] = alloptical_l[comp2][1];
//                    alloptical_l[comp2][1] = dumyY;
//
//                    //ｘ方向は手ブレと混同しやすいため，ｙ成分と同じ箇所を取るようにする
//                    dumyX = alloptical_l[comp1][0];
//                    alloptical_l[comp1][0] = alloptical_l[comp2][0];
//                    alloptical_l[comp2][0] = dumyX;
//
//                }
//                if (abs(alloptical_r[comp1][1]) < abs(alloptical_r[comp2][1])) {
//                    dumyY = alloptical_r[comp1][1];
//                    alloptical_r[comp1][1] = alloptical_r[comp2][1];
//                    alloptical_r[comp2][1] = dumyY;
//
//                    //ｘ方向は手ブレと混同しやすいため，ｙ成分と同じ箇所を取るようにする
//                    dumyX = alloptical_r[comp1][0];
//                    alloptical_r[comp1][0] = alloptical_r[comp2][0];
//                    alloptical_r[comp2][0] = dumyX;
//
//                }
//            }
//        }
    
    
        double percent, percentY, percentlimit, percentYlimit;    //視線移動の上位α%を平均化することで視線移動を抽出する。その範囲αの変数。
        //percentとpercentYは下限、percentlimitが上限。たとえばpercentが0.05でpercentlimitが0.01なら上位1%〜5%を平均化する。
        percent = 0.10;
        percentlimit = 0;
        percentY = 0.10;
        percentYlimit = 0;
    
        int range = floor(pointmax * percent); //水平方向計算に含める点の数の下限。floorは小数点以下を切り捨てる。
        int rangelimit = floor(pointmax * percentlimit);    //水平方向の計算に含める点の数の上限
        int rangeY = floor(pointmax * percentY);    //垂直方向の点数の下限。基本的には↑と同じところを見るので変えないが、
        int rangeYlimit = floor(pointmax * percentYlimit);    //今後変える可能性があるので関数を分けておく
    
        int averagecounter;
        double xave = 0, yave = 0;
//        double xave_l = 0, yave_l = 0;
//        double xave_r = 0, yave_r = 0;
    
        for (averagecounter = rangelimit; averagecounter < range; averagecounter++)
            xave += alloptical[averagecounter][0];
        xave = -xave / averagecounter;
    
        for (averagecounter = rangeYlimit; averagecounter < rangeY; averagecounter++)
            yave += alloptical[averagecounter][1];
        yave = -yave / averagecounter;
    
    
//        for (averagecounter = rangelimit/2; averagecounter < range/2; averagecounter++){
//                xave_l += alloptical_l[averagecounter][0];
//                xave_r += alloptical_r[averagecounter][0];
//        }
//        xave_l = -xave_l / averagecounter;
//        xave_r = -xave_r / averagecounter;
//
//
//        for (averagecounter = rangeYlimit/2; averagecounter < rangeY/2; averagecounter++){
//                yave_l += alloptical[averagecounter][1];
//                yave_r += alloptical[averagecounter][1];
//        }
//        yave_l = -yave_l / averagecounter;
//        yave_r = -yave_r / averagecounter;
    
    
        
//        print(alloptical[0][1])
//    手ブレの影響を除去するため，上位数％の平均から全体の平均を引く．
//    ただ，水平方向は正負が逆転する可能性あるから，全体の方が大きい場合はそのままにしとく
        double valuex = 0, valuey = 0;
//        double valuex_l = 0, valuey_l = 0;
//        double valuex_r = 0, valuey_r = 0;
    if(abs(xave) < abs(aveX)) {//aveX,aveYが全体    xave, yaveが上位％
        valuex = xave;
    }else {
            valuex = xave + aveX;
    }
//    if(abs(xave_l) < abs(aveX_l)) {//aveX,aveYが全体    xave, yaveが上位％
//        valuex_l = xave_l;
//    }else {
//            valuex_l = xave_l + aveX_l;
//    }
//    if(abs(xave_r) < abs(aveX_r)) {//aveX,aveYが全体    xave, yaveが上位％
//        valuex_r = xave_r;
//    }else {
//            valuex_r = xave_r + aveX_r;
//    }
    valuey = yave + aveY;
//    valuey_l = yave_l + aveY_l;
//    valuey_r = yave_r + aveY_r;

    
//        //xave,yaveが負の場合，正負を反転
//        if(valuex < 0){
//            devX = -devX;
//        }
//
//        if(valuey < 0){
//            devY = -devY;
//        }

    

      array[0] = valuex;
      array[1] = valuey;
//    array[2] = devX;
//    array[3] = devY;
//    array[4] = valuex_l;
//    array[5] = valuey_l;
//    array[6] = valuex_r;
//    array[7] = valuey_r;
    
    
  
    }

-(void)avopLR:(UIImage *)previmg :(UIImage *)nextimg :(double *)array{

    cv::Mat prev, next;
    UIImageToMat(previmg, prev);   //前フレーム
    UIImageToMat(nextimg, next);   //現在のフレーム
    
    resize(prev, prev, cv::Size(), 0.5, 0.5);    //処理速度を上げるために，画像サイズを縮小
    resize(next, next, cv::Size(), 0.5, 0.5);    //処理速度を上げるために，画像サイズを縮小

    cv::cvtColor(prev, prev, cv::COLOR_BGR2GRAY); //グレースケール変換
    cv::cvtColor(next, next, cv::COLOR_BGR2GRAY); //グレースケール変換
    

    

    

    //ここからオプティカルフロー
    std::vector<cv::Point2f> prev_pts;
        
    cv::Size flowSize(10, 10);  //15×15の点
    cv::Point2f center = cv::Point(prev.cols / 2., prev.rows / 2.);
    for (int i = 0; i < flowSize.width; ++i) {
        for (int j = 0; j < flowSize.height; ++j) {
            cv::Point2f p (i*double(prev.cols) / (flowSize.width - 1), j*double(prev.rows) / (flowSize.height - 1));
            prev_pts.push_back((p - center)*0.9f + center);
        }
    }
    cv::Mat flow;

    //Let'sオプティカルフロー
    cv::calcOpticalFlowFarneback(prev, next, flow, 0.5, 3, 15, 3, 5, 1.1, 0);
//    cv::calcOpticalFlowFarneback(prev, next, flow, 0.8, 10, 15, 3, 5, 1.1, 0);   こんへんの変数意味わからん

//    400個の計測点
    double pointmax = 10 * 10;
    std::vector<std::vector<double>>alloptical;
        alloptical.resize(pointmax);
        for (int a = 0; a < pointmax; a++)
            alloptical[a].resize(2);   //xとy
    
        int counter = 0;
        double aveX = 0, aveY = 0;
//        double devX = 0, devY = 0;

////    左右200個ずつの計測点
//    double pointmax_lr = 10 * 20;
//    std::vector<std::vector<double>>alloptical_l;
//    std::vector<std::vector<double>>alloptical_r;
//        alloptical_l.resize(pointmax_lr);
//        alloptical_r.resize(pointmax_lr);
//        for (int a = 0; a < pointmax_lr; a++){
//                alloptical_l[a].resize(2);   //xとy
//                alloptical_r[a].resize(2);   //xとy
//        }
        
        
//        int counter_l = 0, counter_r = 0;
//        double aveX_l = 0, aveY_l = 0;
//        double aveX_r = 0, aveY_r = 0;

    
    
        std::vector<cv::Point2f>::const_iterator p = prev_pts.begin();
        for (; p != prev_pts.end(); ++p) {
            const cv::Point2f& fxy = flow.at<cv::Point2f>(p->y, p->x);
            alloptical[counter][0] = fxy.x;
            alloptical[counter][1] = fxy.y;
            aveX = aveX + fxy.x;
            aveY = aveY + fxy.y;
            
//            if (counter < 200){
//                alloptical_l[counter][0] = fxy.x;
//                alloptical_l[counter][1] = fxy.y;
//                aveX_l = aveX_l + fxy.x;
//                aveY_l = aveY_l + fxy.y;
//            }
//            else{
//                alloptical_r[counter-200][0] = fxy.x;
//                alloptical_r[counter-200][1] = fxy.y;
//                aveX_r = aveX_r + fxy.x;
//                aveY_r = aveY_r + fxy.y;
//            }
            
//            if ((counter / 10) % 2 == 0){   //上とどっちかが正しい
//                alloptical_l[counter_l][0] = fxy.x;
//                alloptical_l[counter_l][1] = fxy.y;
//                aveX_l = aveX_l + fxy.x;
//                aveY_l = aveY_l + fxy.y;
//                counter_l++;
//            }
//            else{
//                alloptical_r[counter_r][0] = fxy.x;
//                alloptical_r[counter_r][1] = fxy.y;
//                aveX_r = aveX_r + fxy.x;
//                aveY_r = aveY_r + fxy.y;
//                counter_r++;
//            }
//
            counter++;
        }

        //平均
        aveX = aveX / counter;
        aveY = aveY / counter;
    
//        aveX_l = aveX_l / counter/2;
//        aveY_l = aveY_l / counter/2;
//        aveX_r = aveX_r / counter/2;
//        aveY_r = aveY_r / counter/2;

//        //分散値の算出
//        for (int c = 0; c < counter; c++) {
//        devX = devX + ((alloptical[c][0] - aveX)*(alloptical[c][0] - aveX));
//        devY = devY + ((alloptical[c][1] - aveY)*(alloptical[c][1] - aveY));
//        }
//
//        devX = devX / counter;
//        devY = devY / counter;

    
        int comp1, comp2;
        double dumyX, dumyY;
    
        
        //ｙ方向でソート処理
        for (comp1 = 0; comp1 <= pointmax; comp1++) {
            for (comp2 = comp1 + 1; comp2 < pointmax; comp2++) {
                if (abs(alloptical[comp1][1]) < abs(alloptical[comp2][1])) {
                    dumyY = alloptical[comp1][1];
                    alloptical[comp1][1] = alloptical[comp2][1];
                    alloptical[comp2][1] = dumyY;
                    
                    //ｘ方向は手ブレと混同しやすいため，ｙ成分と同じ箇所を取るようにする
                    dumyX = alloptical[comp1][0];
                    alloptical[comp1][0] = alloptical[comp2][0];
                    alloptical[comp2][0] = dumyX;

                }
            }
        }
    
//        for (comp1 = 0; comp1 <= pointmax_lr; comp1++) {
//            for (comp2 = comp1 + 1; comp2 < pointmax_lr; comp2++) {
//                if (abs(alloptical_l[comp1][1]) < abs(alloptical_l[comp2][1])) {
//                    dumyY = alloptical_l[comp1][1];
//                    alloptical_l[comp1][1] = alloptical_l[comp2][1];
//                    alloptical_l[comp2][1] = dumyY;
//
//                    //ｘ方向は手ブレと混同しやすいため，ｙ成分と同じ箇所を取るようにする
//                    dumyX = alloptical_l[comp1][0];
//                    alloptical_l[comp1][0] = alloptical_l[comp2][0];
//                    alloptical_l[comp2][0] = dumyX;
//
//                }
//                if (abs(alloptical_r[comp1][1]) < abs(alloptical_r[comp2][1])) {
//                    dumyY = alloptical_r[comp1][1];
//                    alloptical_r[comp1][1] = alloptical_r[comp2][1];
//                    alloptical_r[comp2][1] = dumyY;
//
//                    //ｘ方向は手ブレと混同しやすいため，ｙ成分と同じ箇所を取るようにする
//                    dumyX = alloptical_r[comp1][0];
//                    alloptical_r[comp1][0] = alloptical_r[comp2][0];
//                    alloptical_r[comp2][0] = dumyX;
//
//                }
//            }
//        }
    
    
        double percent, percentY, percentlimit, percentYlimit;    //視線移動の上位α%を平均化することで視線移動を抽出する。その範囲αの変数。
        //percentとpercentYは下限、percentlimitが上限。たとえばpercentが0.05でpercentlimitが0.01なら上位1%〜5%を平均化する。
        percent = 0.10;
        percentlimit = 0;
        percentY = 0.10;
        percentYlimit = 0;
    
        int range = floor(pointmax * percent); //水平方向計算に含める点の数の下限。floorは小数点以下を切り捨てる。
        int rangelimit = floor(pointmax * percentlimit);    //水平方向の計算に含める点の数の上限
        int rangeY = floor(pointmax * percentY);    //垂直方向の点数の下限。基本的には↑と同じところを見るので変えないが、
        int rangeYlimit = floor(pointmax * percentYlimit);    //今後変える可能性があるので関数を分けておく
    
        int averagecounter;
        double xave = 0, yave = 0;
//        double xave_l = 0, yave_l = 0;
//        double xave_r = 0, yave_r = 0;
    
        for (averagecounter = rangelimit; averagecounter < range; averagecounter++)
            xave += alloptical[averagecounter][0];
        xave = -xave / averagecounter;
    
        for (averagecounter = rangeYlimit; averagecounter < rangeY; averagecounter++)
            yave += alloptical[averagecounter][1];
        yave = -yave / averagecounter;
    
    
//        for (averagecounter = rangelimit/2; averagecounter < range/2; averagecounter++){
//                xave_l += alloptical_l[averagecounter][0];
//                xave_r += alloptical_r[averagecounter][0];
//        }
//        xave_l = -xave_l / averagecounter;
//        xave_r = -xave_r / averagecounter;
//
//
//        for (averagecounter = rangeYlimit/2; averagecounter < rangeY/2; averagecounter++){
//                yave_l += alloptical[averagecounter][1];
//                yave_r += alloptical[averagecounter][1];
//        }
//        yave_l = -yave_l / averagecounter;
//        yave_r = -yave_r / averagecounter;
    
    
        
//        print(alloptical[0][1])
//    手ブレの影響を除去するため，上位数％の平均から全体の平均を引く．
//    ただ，水平方向は正負が逆転する可能性あるから，全体の方が大きい場合はそのままにしとく
        double valuex = 0, valuey = 0;
//        double valuex_l = 0, valuey_l = 0;
//        double valuex_r = 0, valuey_r = 0;
    if(abs(xave) < abs(aveX)) {//aveX,aveYが全体    xave, yaveが上位％
        valuex = xave;
    }else {
            valuex = xave + aveX;
    }
//    if(abs(xave_l) < abs(aveX_l)) {//aveX,aveYが全体    xave, yaveが上位％
//        valuex_l = xave_l;
//    }else {
//            valuex_l = xave_l + aveX_l;
//    }
//    if(abs(xave_r) < abs(aveX_r)) {//aveX,aveYが全体    xave, yaveが上位％
//        valuex_r = xave_r;
//    }else {
//            valuex_r = xave_r + aveX_r;
//    }
    valuey = yave + aveY;
//    valuey_l = yave_l + aveY_l;
//    valuey_r = yave_r + aveY_r;

    
//        //xave,yaveが負の場合，正負を反転
//        if(valuex < 0){
//            devX = -devX;
//        }
//
//        if(valuey < 0){
//            devY = -devY;
//        }

    

      array[0] = valuex;
      array[1] = valuey;
//    array[2] = devX;
//    array[3] = devY;
//    array[4] = valuex_l;
//    array[5] = valuey_l;
//    array[6] = valuex_r;
//    array[7] = valuey_r;
    
    
  
    }

@end



