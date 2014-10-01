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

@end

@implementation ViewController

- (void) inicializar
{
    [Sistema S].delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self inicializar];
}

- (IBAction)botonPantallaPresionado:(id)sender
{
    [[Sistema S] comenzarReconocimientoVoz];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
