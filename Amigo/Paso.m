//
//  Paso.m
//  Amigo
//
//  Created by Diego on 10/27/14.
//  Copyright (c) 2014 Amigo. All rights reserved.
//

#import "Paso.h"

@implementation Paso

-(instancetype)initConUbicacion:(CLLocation *)ubicacion descripcionHablada:(NSString *)descripcion
{
    self = [super init];
    
    if (self)
    {
        self.ubicacionInicio = ubicacion;
        self.descripcionHablada = descripcion;
    }
    return self;
}

@end
