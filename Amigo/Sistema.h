//
//  Sistema.h
//  Amigo
//
//  Created by Diego on 9/30/14.
//  Copyright (c) 2014 Amigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MotorVoz.h"


@class Sistema;

@protocol DelegateSistema <NSObject>

@required

-(void) sistema:(Sistema *)sistema nuevoReconocimientoVoz:(NSString *)textoDetectado;

@end

@interface Sistema : NSObject

@property (nonatomic) MotorVoz *motorVoz;

@property (nonatomic, weak) id<DelegateSistema> delegate;

+ (Sistema *)S;

-(void) comenzarReconocimientoVoz;

-(void) detenerReconocimientoVoz;

-(void) anunciarUbicacionActual;

-(void)resultadoHabladoIdentificado:(NSString *)resultadoMasProbable;

@end
