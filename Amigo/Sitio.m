
//
//  Sitio.m
//  Peluquerias
//
//  Created by Diego on 6/18/14.
//  Copyright (c) 2014 Diamob. All rights reserved.
//

#import "Sitio.h"

@implementation Sitio

#pragma mark inicialización

-(instancetype) initConUbicacion:(CLLocation *) ubicacion nombre:(NSString *)nombre ID:(NSString *)ID
{
    self = [super init];
    
    if (self)
    {
        self.ubicacion = ubicacion;
        self.nombre = nombre;
        self.ID = ID;
    }
    return self;
}

@end
