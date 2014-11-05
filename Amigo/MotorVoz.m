//
//  MotorVoz.m
//  Amigo
//
//  Created by Diego on 9/30/14.
//  Copyright (c) 2014 Amigo. All rights reserved.
//

#import "MotorVoz.h"

const unsigned char SpeechKitApplicationKey[] = {0x3e, 0xd0, 0x93, 0x36, 0xde, 0x26, 0x6f, 0xcc, 0x74, 0x65, 0xfa, 0x2e, 0xb9, 0x6c, 0x2f, 0x92, 0xe1, 0xf0, 0x9f, 0x32, 0x5c, 0x5a, 0x2f, 0x8d, 0x08, 0x91, 0x77, 0x7a, 0x0c, 0x3a, 0x59, 0x4b, 0x0a, 0xec, 0x81, 0xe9, 0x13, 0xf0, 0xb5, 0x87, 0x55, 0xaf, 0xb6, 0x0f, 0x1c, 0xe5, 0xa1, 0xfd, 0xd5, 0x40, 0x30, 0x31, 0x9a, 0x5f, 0xbe, 0xa2, 0xf0, 0x35, 0x1c, 0xfc, 0x6f, 0x75, 0x47, 0x7a};

@interface MotorVoz () <SpeechKitDelegate, SKRecognizerDelegate, SKVocalizerDelegate>

@property (nonatomic) SKRecognizer* recognizer;
@property (nonatomic) SKVocalizer* vocalizer;

@property (nonatomic) BOOL hablando;

@end

@implementation MotorVoz

enum {
    TS_IDLE,
    TS_INITIAL,
    TS_RECORDING,
    TS_PROCESSING,
    TS_SPEAKING
} transactionState;

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
    [SpeechKit setupWithID:@"NMDPTRIAL_diegomontoyas20140930114102"
                      host:@"sslsandbox.nmdp.nuancemobility.net"
                      port:443
                    useSSL:YES
                  delegate:self];
    
    // Set earcons to play
    SKEarcon* earconStart	= [SKEarcon earconWithName:@"beginRecording.wav"];
    SKEarcon* earconStop	= [SKEarcon earconWithName:@"stopRecording.wav"];
    SKEarcon* earconCancel	= [SKEarcon earconWithName:@"recordingCancelled.wav"];
    
    [SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
    [SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
    [SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];
    
    self.hablando = false;
}

-(void) comenzarReconocimiento
{
    if (transactionState == TS_IDLE)
    {
        transactionState = TS_INITIAL;
        
        self.recognizer = [[SKRecognizer alloc] initWithType:SKDictationRecognizerType
                                                    detection:SKLongEndOfSpeechDetection
                                                     language:@"es_MX"
                                                     delegate:self];
    }
}

-(void) detenerReconocimiento
{
    if (transactionState == TS_RECORDING)
    {        
        [self.recognizer stopRecording];
    }
}

-(void) dictar:(NSString *) textoALeer
{
    if (!self.hablando)
    {
        self.vocalizer = [[SKVocalizer alloc] initWithLanguage:@"spa-MEX" delegate:self];
        [self.vocalizer speakString:textoALeer];
    }
}

#pragma mark SKRecognizerDelegate

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording started.");
    
    transactionState = TS_RECORDING;
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording finished.");
    
    transactionState = TS_PROCESSING;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    NSLog(@"Got results.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    [self.recognizer cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.delegate motorVoz:self terminoReconocimientoConResultados:results];
        transactionState = TS_IDLE;
    });
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"Got error.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    [self.recognizer cancel];
    transactionState = TS_IDLE;
}

#pragma mark SKVocalizerDelegate methods

- (void)vocalizer:(SKVocalizer *)vocalizer willBeginSpeakingString:(NSString *)text
{
    self.hablando = true;
    transactionState = TS_SPEAKING;
}

- (void)vocalizer:(SKVocalizer *)vocalizer willSpeakTextAtCharacter:(NSUInteger)index ofString:(NSString *)text
{
}

- (void)vocalizer:(SKVocalizer *)vocalizer didFinishSpeakingString:(NSString *)text withError:(NSError *)error
{
    [self.vocalizer cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.delegate motorVozTerminoDictado:self];
        transactionState = TS_IDLE;
        self.hablando = false;
    });
}

@end
