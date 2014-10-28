//
//  Paso.h
//  Amigo
//
//  Created by Diego on 10/27/14.
//  Copyright (c) 2014 Amigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Paso : NSObject

@property (nonatomic) NSString *descripcionHablada;
@property (nonatomic) CLLocation *ubicacionInicio;

-(instancetype)initConUbicacion:(CLLocation *)ubicacion descripcionHablada:(NSString *)descripcion;

@end
