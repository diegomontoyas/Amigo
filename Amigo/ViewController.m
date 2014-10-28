//
//  ViewController.m
//  Amigo
//
//  Created by Diego on 9/30/14.
//  Copyright (c) 2014 Amigo. All rights reserved.
//

#import "ViewController.h"
#import "MotorVoz.h"
#import "Sistema.h"

@interface ViewController () <DelegateSistema>

@property (strong, nonatomic) IBOutlet UIButton *botonPantalla;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void) inicializar
{
    [Sistema S].delegate = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(botonPresionadoConDobleToque:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.botonPantalla addGestureRecognizer:doubleTap];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self inicializar];
}

- (void) botonPresionadoConDobleToque:(id)sender
{
    [[Sistema S]anunciarUbicacionActual];
}

- (IBAction)botonPantallaPresionado:(id)sender
{
    [[Sistema S] comenzarReconocimientoVoz];
}

-(void)sistema:(Sistema *)sistema nuevoReconocimientoVoz:(NSString *)textoDetectado
{
    self.label.text = textoDetectado;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
