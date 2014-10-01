//
//  MotorVoz.h
//  Amigo
//
//  Created by Diego on 9/30/14.
//  Copyright (c) 2014 Amigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpeechKit/SpeechKit.h>

@class MotorVoz;

@protocol DelegateMotorVoz <NSObject>

@required

-(void) motorVoz:(MotorVoz *)motorVoz terminoReconocimientoConResultados:(SKRecognition *)results;

-(void) motorVozTerminoDictado:(MotorVoz *)motorVoz;

@end

@interface MotorVoz : NSObject

@property (nonatomic, weak) id<DelegateMotorVoz> delegate;

-(void) comenzarReconocimiento;

-(void) detenerReconocimiento;

-(void) dictar:(NSString *) textoALeer;

@end
