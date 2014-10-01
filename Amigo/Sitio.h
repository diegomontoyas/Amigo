//
//  Sitio.h
//  Peluquerias
//
//  Created by Diego on 6/18/14.
//  Copyright (c) 2014 Diamob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Sitio : NSObject

#pragma mark Notificaciones

FOUNDATION_EXPORT NSString *const NotificacionServicioSeleccionado;

#pragma mark Propiedades

@property (nonatomic) NSString *ID;
@property (nonatomic) CLLocation *ubicacion;
@property (nonatomic) NSString *nombre;

@property (nonatomic) NSString *ciudad;
@property (nonatomic) NSString *direccion;
@property (nonatomic) NSString *telefono;
@property (nonatomic) UIImage *icono;

#pragma mark Métodos

-(instancetype) initConUbicacion:(CLLocation *) ubicacion nombre:(NSString *)nombre ID:(NSString *)ID;

@end
