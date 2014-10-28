//
//  Sistema.m
//  Amigo
//
//  Created by Diego on 9/30/14.
//  Copyright (c) 2014 Amigo. All rights reserved.
//

#import "Sistema.h"
#import "Sitio.h"
#import <CoreLocation/CoreLocation.h>

#define kGOOGLE_API_KEY @"AIzaSyBhwNyfF9aoBiu48cMiAZVLzMHBncLmjrk"

@interface Sistema () <DelegateMotorVoz, CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSMutableArray *sitiosUltimaConsulta;
@property (nonatomic) Sitio *ultimaUbicacionActualRegistrada;

@end

@implementation Sistema

enum {
    AMEsperandoPregunta,
    AMEsperandoRespuestaSitio
} estado;

#pragma mark Inicializacion

+ (Sistema *)S
{
    static Sistema *instancia = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instancia = [[Sistema alloc] init];
    });
    return instancia;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self inicializar];
    }
    return self;
}

-(void) inicializar
{
    self.motorVoz = [[MotorVoz alloc]init];
    self.motorVoz.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
    estado = AMEsperandoPregunta;
}

-(NSMutableArray *)sitiosUltimaConsulta
{
    if (!_sitiosUltimaConsulta)
    {
        _sitiosUltimaConsulta = [NSMutableArray array];
    }
    return _sitiosUltimaConsulta;
}

#pragma mark Métodos

-(void) comenzarReconocimientoVoz
{
    [self.motorVoz comenzarReconocimiento];
}

-(void) detenerReconocimientoVoz
{
    [self.motorVoz detenerReconocimiento];
}

-(void)buscarSitiosConPalabrasClave:(NSString *) palabrasClave
{
    CLLocationCoordinate2D coordendas = self.locationManager.location.coordinate;
    int radioBusqueda = 300;
    
    NSString *stringUrl = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%d&sensor=true&name=%@&key=%@", coordendas.latitude, coordendas.longitude, radioBusqueda, palabrasClave, kGOOGLE_API_KEY];
    
    NSURL *URL = [NSURL URLWithString:[stringUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (data) [self informacionSitiosRecibidaConRespuesta:response data:data error:connectionError];
                           }];
}

-(void)informacionSitiosRecibidaConRespuesta:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error
{
    if (data && !error)
    {
        self.sitiosUltimaConsulta = [NSMutableArray array];
        
        NSError *error = nil;
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableContainers error:&error];
        
        NSArray *resultadosJSON = JSONResponse[@"results"];
        
        for (NSDictionary *resultadoJSON in resultadosJSON)
        {
            NSDictionary *ubicacionJSON = resultadoJSON[@"geometry"][@"location"];
            NSString *nombre = resultadoJSON[@"name"];
            NSString *ID = resultadoJSON[@"id"];
            NSString *direccion = resultadoJSON[@"vicinity"];
            
            Sitio *sitio = [[Sitio alloc]initConUbicacion:[[CLLocation alloc]initWithLatitude:[ubicacionJSON[@"lat"]floatValue]
                                                                                   longitude:[ubicacionJSON[@"lon"]floatValue]]
                                                                                      nombre:nombre
                                                                                          ID:ID];
            sitio.direccion = direccion;
            
            [self.sitiosUltimaConsulta addObject:sitio];
        }
        
        NSMutableString *respuestaHablada = [NSMutableString stringWithString:@"Diego, Encontré estos sitios cerca de ti. "];
        
        for (int i = 0; i< self.sitiosUltimaConsulta.count && i<5; i++)
        {
            Sitio *sitio = self.sitiosUltimaConsulta[i];
            
            [respuestaHablada appendString:[sitio.nombre stringByAppendingString:@" , "]];
            
            if (sitio.direccion)
            {
                [respuestaHablada appendString:@" , en"];
                [respuestaHablada appendString:[sitio.direccion stringByAppendingString:@" ,"]];
            }
        }
        
        [respuestaHablada appendString:@", ¿a cuál de ellos deseas ir?"];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            estado = AMEsperandoRespuestaSitio;
            [self.motorVoz dictar:respuestaHablada];
        });
    }
}

-(void) anunciarUbicacionActual
{
    [self buscarInformacionUbicacionActual];
}

-(void)buscarInformacionUbicacionActual
{
    CLLocationCoordinate2D coordendas = self.locationManager.location.coordinate;
    
    NSString *stringUrl = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true&key=%@", coordendas.latitude, coordendas.longitude, kGOOGLE_API_KEY];
    
    NSURL *URL = [NSURL URLWithString:[stringUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (data) [self informacionUbicacionActualRecibidaConRespuesta:response data:data error:connectionError];
                           }];
}

-(void)informacionUbicacionActualRecibidaConRespuesta:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error
{
    if (data && !error)
    {
        self.sitiosUltimaConsulta = [NSMutableArray array];
        
        NSError *error = nil;
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableContainers error:&error];
        
        NSDictionary *resultadoJSON = JSONResponse[@"results"][0];
        NSString *direccion = resultadoJSON[@"formatted_address"];
        direccion = [direccion componentsSeparatedByString:@"Bogotá"][0];
        
        Sitio *sitio = [[Sitio alloc]init];
        sitio.direccion = direccion;
        
        self.ultimaUbicacionActualRegistrada = sitio;
        
        NSMutableString *respuestaHablada = [NSMutableString stringWithString:@"Estás en, "];
        [respuestaHablada appendString:self.ultimaUbicacionActualRegistrada.direccion];
        [respuestaHablada appendString:@" , mirando hacia el "];
        [respuestaHablada appendString:[self direccionCardinalAPartirDeHeading:self.locationManager.heading]];
        
        [self.motorVoz dictar:respuestaHablada];
    }
}

-(NSString *)direccionCardinalAPartirDeHeading:(CLHeading *) heading
{
    NSString *direccion;
    CLLocationDirection trueHeading = heading.trueHeading;
    
    
    if (trueHeading >= 0 && trueHeading < 45)
    {
        direccion = @"Norte";
    }
    else if (trueHeading >= 45 && trueHeading < 90)
    {
        direccion = @"Nororiente";
    }
    else if (trueHeading >= 90 && trueHeading < 135)
    {
        direccion = @"Oriente";
    }
    else if (trueHeading >= 135 && trueHeading < 180)
    {
        direccion = @"Suroriente";
    }
    else if (trueHeading >= 180 && trueHeading < 225)
    {
        direccion = @"Suroccidente";
    }
    else if (trueHeading >= 225 && trueHeading < 270)
    {
        direccion = @"Occidente";
    }
    else if (trueHeading >= 270 && trueHeading < 315)
    {
        direccion = @"Noroccidente";
    }
    else if (trueHeading >= 315 && trueHeading <= 360)
    {
        direccion = @"Norte";
    }
    
    return direccion;
}

#pragma mark DelegateMotorVoz

-(void)motorVoz:(MotorVoz *)motorVoz terminoReconocimientoConResultados:(SKRecognition *)results
{
    NSString *resultadoMasProbable = [[results firstResult] lowercaseString];
    
    [self.delegate sistema:self nuevoReconocimientoVoz:resultadoMasProbable];
    
    if ([resultadoMasProbable isEqualToString:@"cancelar"])
    {
        estado = AMEsperandoPregunta;
    }
    else if (estado == AMEsperandoPregunta)
    {
        if ([resultadoMasProbable containsString:@"llévame a"])
        {
            NSArray *componentes = [resultadoMasProbable componentsSeparatedByString:@"llévame a"];
            
            //[self.motorVoz dictar:resultadoMasProbable];
            
            if (componentes.count > 1)
            {
                [self buscarSitiosConPalabrasClave:componentes[1]];
            }
        }
        else
        {
            [self.motorVoz dictar:@"Lo siento Diego, no te entendí"];
        }
    }
    else if (estado == AMEsperandoRespuestaSitio)
    {
        BOOL encontroSitio = NO;
        
        for (int i = 0; i< self.sitiosUltimaConsulta.count && i<5 && !encontroSitio; i++)
        {
            Sitio *sitio = self.sitiosUltimaConsulta[i];
            
            if ([[sitio.direccion lowercaseString] containsString:resultadoMasProbable])
            {
                NSMutableString *resultadoHablado = [NSMutableString stringWithString:@"De acuerdo, vamos a "];
                [resultadoHablado appendString:sitio.nombre];
                [resultadoHablado appendString:@" en, "];
                [resultadoHablado appendString:sitio.direccion];
                
                [self.motorVoz dictar:resultadoHablado];
                estado = AMEsperandoPregunta;
                encontroSitio = YES;
            }
        }
        
        if (!encontroSitio) [self.motorVoz dictar:@"Parece que eso no está en los resultados. quizás intenta otra vez"];
    }
}

-(void)motorVozTerminoDictado:(MotorVoz *)motorVoz
{
    if (estado == AMEsperandoRespuestaSitio)
    {
        //[self comenzarReconocimientoVoz];
    }
}

-(void)probarConTexto:(NSString *)results
{
    //[self.motorVoz dictar:results];
    
    NSString *resultadoMasProbable = results;
    
    NSArray *componentes = [resultadoMasProbable componentsSeparatedByString:@"voy para"];
    
    if (componentes.count > 1)
    {
        //[self buscarSitiosConPalabrasClave:componentes[1]];
    }
}

#pragma mark CLLocationManagerDelegate

@end
