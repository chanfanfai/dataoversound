//
//  ViewController.m
//  dataoversound
//
//  Created by DavidFF Chan on 17/5/2017.
//  Copyright © 2017 DavidFF Chan. All rights reserved.
//

#import "ViewController.h"
#import <QuietModemKit/QuietModemKit.h>
#import <MIKMIDI/MIKMIDI.h>
@interface ViewController ()
{
    int sfindex;
    
}
@property (strong, nonatomic) NSArray *modeList;
@property (strong, nonatomic) IBOutlet UIButton *recordBtn;
@property (strong, nonatomic) IBOutlet UILabel *statusLbl;

@property (nonatomic, strong, readonly) MIKMIDISynthesizer *synthesizer;

@property (assign, nonatomic) int modeIndex;
@end

@implementation ViewController
@synthesize chatWindows;


static QMFrameReceiver *rx;
static NSString * curentMode;
static UITextView * staticChatView;
static UIButton * staticrecordBtn;
static UILabel * staticstatusLbl;
static NSMutableDictionary * record;

- (void)viewDidLoad {
    [super viewDidLoad];

    sfindex = 0;
    
    _modeList = [NSArray arrayWithObjects:@"ultrasonic",@"audible",@"audible-7k-channel-0",@"audible-7k-channel-1",@"cable-64k",@"hello-world",@"ultrasonic-3600",@"ultrasonic-whisper",@"ultrasonic-experimental", nil];
    _modeIndex = 0;
    
    curentMode = [_modeList objectAtIndex:_modeIndex];
    
    //AVAudioSessionCategoryPlayAndRecord
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
  [[AVAudioSession sharedInstance] requestRecordPermission:request_callback];
    staticChatView = self.chatWindows;
    staticrecordBtn = self.recordBtn;
    staticstatusLbl = self.statusLbl;
    record = [[NSMutableDictionary alloc] init];

    
}
- (IBAction)recordBtnAction:(id)sender {

        
        chatWindows.text = @"";
        
        [_recordBtn setTitle:@"Cleaning" forState:UIControlStateNormal];
        record = [[NSMutableDictionary alloc] init];
        double delayInSecondssss = 2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSecondssss * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [_recordBtn setTitle:@"Clean" forState:UIControlStateNormal];
        });
    
    
}

- (IBAction)playBtnAction:(id)sender {
    NSLog(@"record.count %lu",(unsigned long)record.count);
    
    if (record.count == 0)
    {
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [_statusLbl setText:@"Playing"];
    
    for (UIView * tmpObj in [self.view subviews])
    {
    if ([tmpObj isKindOfClass:[UIButton class]])
        {
            ((UIButton *)tmpObj).enabled = false;
        }
        if ([tmpObj isKindOfClass:[UITextView class]])
        {
            ((UITextView *)tmpObj).userInteractionEnabled = false;
        }
    }

    NSString * soundfile;
    if( ((UIButton *)sender).tag == 0)
    {
    soundfile = @"000"; //AcousticGrandPiano
    }
    if( ((UIButton *)sender).tag == 1)
    {
        soundfile = @"026"; //ElectricGuitarJazz
    }
    if( ((UIButton *)sender).tag == 2)
    {
        soundfile = @"073"; //Flute
    }
    if( ((UIButton *)sender).tag == 3)
    {
        soundfile = @"018"; //RockOrgan(SNT)
    }
    if( ((UIButton *)sender).tag == 4)
    {
        soundfile = @"099"; //TenorSax(SNT)
    }
    if( ((UIButton *)sender).tag == 5)
    {
        soundfile = @"040"; //Violin(SNT)
    }
    
        _synthesizer = [[MIKMIDISynthesizer alloc] init];
        NSURL *soundfont = [[NSBundle mainBundle] URLForResource:soundfile withExtension:@"sf2"];
        NSError *error = nil;
        if (![_synthesizer loadSoundfontFromFileAtURL:soundfont error:&error]) {
            NSLog(@"Error loading soundfont for synthesizer. Sound will be degraded. %@", error);
        }
        

        
        
        NSArray * recordsKey =    [[record allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first =  [NSNumber numberWithInt:[(NSString*)a intValue]];
        NSNumber *second = [NSNumber numberWithInt:[(NSString*)b intValue]];
        return [first compare:second];
    }];
        double startPoint = [[recordsKey objectAtIndex:0] doubleValue] ;
        
        for (NSString * tmpRecordkey in recordsKey)
        {
            
                
                double delayInSecondssss = ([tmpRecordkey doubleValue]-startPoint)/100.0;
            
            
                for (NSNumber * note in [record objectForKey:tmpRecordkey])
                {

                    [NSTimer scheduledTimerWithTimeInterval:delayInSecondssss target:self selector:@selector(playback:) userInfo:note repeats:false];
                    
                    
                    if ([tmpRecordkey isEqualToString:[recordsKey lastObject]] )
                    {
                        
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSecondssss * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            
                            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
                            [_statusLbl setText:@"Play finish"];
                            for (UIView * tmpObj in [self.view subviews])
                            {
                                if ([tmpObj isKindOfClass:[UIButton class]])
                                {
                                    ((UIButton *)tmpObj).enabled = true;
                                }
                                if ([tmpObj isKindOfClass:[UITextView class]])
                                {
                                    ((UITextView *)tmpObj).userInteractionEnabled = true;
                                }
                                
                            }

                        });
                    }
                    
                }
//                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSecondssss * NSEC_PER_SEC);
//                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//
//                                for (NSNumber * note in [record objectForKey:tmpRecordkey])
//                                {
//                                    if ([note intValue] > 0)
//                                    {
//                                        MIKMIDINoteOnCommand *noteOn = [MIKMIDINoteOnCommand noteOnCommandWithNote:[note intValue] velocity:127 channel:0 timestamp:[NSDate date] ];
//                                        [self.synthesizer handleMIDIMessages:@[noteOn]];
//                                        NSLog(@"On %@",MIKMIDINoteLetterAndOctaveForMIDINote([note intValue]));
//
//                                    }else{
//                                        MIKMIDINoteOffCommand *noteOff = [MIKMIDINoteOffCommand noteOffCommandWithNote:-[note intValue] velocity:127 channel:0 timestamp:[NSDate date] ];
//                                        [self.synthesizer handleMIDIMessages:@[noteOff]];
//                                        NSLog(@"Off %@",MIKMIDINoteLetterAndOctaveForMIDINote(-[note intValue]));
//                                    }
//                                }

//
//                                
//                

                
            
          
        }
        

        
    
}
-(void)playback:(NSTimer *)sender{
    int recData = [(NSNumber *)sender.userInfo intValue];
    
    if (recData > 0 )
    {
        int recNote = recData;
        MIKMIDINoteOnCommand *noteOn = [MIKMIDINoteOnCommand noteOnCommandWithNote:recNote velocity:127 channel:0 timestamp:[NSDate date] ];
        [self.synthesizer handleMIDIMessages:@[noteOn]];
        
    }else     {
        
        int recNote = -recData;
        MIKMIDINoteOffCommand *noteOff = [MIKMIDINoteOffCommand noteOffCommandWithNote:recNote velocity:127 channel:0 timestamp:[NSDate date] ];
        [self.synthesizer handleMIDIMessages:@[noteOff]];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



void (^recv_callback)(NSData*) = ^(NSData *frame){
//    printf("%s\n", [frame bytes]);
    [staticstatusLbl setText:@""];
//    if (staticrecordBtn.tag == 1)
//    {
    
        NSString * msg  = [[NSString alloc] initWithData:frame encoding:NSUTF8StringEncoding];
    NSLog(@"msg %@",msg);
 //[NSString stringWithFormat:@"%\n", [frame bytes]];
  
    NSString * notes_String=@"";
    NSString * notes_String_txt=@"";
        NSMutableArray * notesSession;
    
        
    NSLog(@"seq %d, %C",[msg characterAtIndex:0],[msg characterAtIndex:0]);
        int i=1;
        int seq = [msg characterAtIndex:0] * 100;
        int sessionid = 0;
        int notsessionid = 0;
    while ( i< msg.length)
    {
        
        
        NSLog(@"%d, %C",[msg characterAtIndex:i],[msg characterAtIndex:i]);
        int recData = [msg characterAtIndex:i];
        
        if (recData < 100)
        {
            sessionid = recData;
            notsessionid = seq + sessionid;

            notesSession = [[NSMutableArray alloc]init];
          

            
            if(![record objectForKey:[NSString stringWithFormat:@"%d",notsessionid]])
            {
                NSLog(@"new notsessionid %d",notsessionid);
                        [record setObject:notesSession forKey:[NSString stringWithFormat:@"%d",notsessionid]];
                        [staticstatusLbl setText:[NSString stringWithFormat:@"Add %d",notsessionid]];
                
            }
            
          
//            NSLog(@"[record allKeys] %@",[record allKeys]);

            notes_String_txt = [NSString stringWithFormat:@"\n%.02f ",(seq + sessionid)/100.00];

            
        }
        else if (recData >= 101 && recData <= 300)
        {

            int recNote = (recData-101);
   
            
            
            [notesSession addObject:[NSNumber numberWithInt:(recNote)]];
        
            notes_String = [NSString stringWithFormat:@"On:%@ ", MIKMIDINoteLetterAndOctaveForMIDINote(recNote)];
        
           
        }else if (recData >= 301 && recData <= 500)
        {

            int recNote = (recData-301);
            
            [notesSession addObject:[NSNumber numberWithInt:(-recNote)]];
            
            notes_String = [NSString stringWithFormat:@"Off:%@ ", MIKMIDINoteLetterAndOctaveForMIDINote(recNote)];
            
            
        }
        NSLog(@"notes_String %@ %@",notes_String, notesSession);
        if (notes_String.length > 0)
        {
            notes_String_txt = [NSString stringWithFormat:@"%@ %@",notes_String_txt ,notes_String];
            
            
            
            notes_String = @"";
        }
      
        i++;
    }

    
    
    staticChatView.text = [NSString stringWithFormat:@"%@\n%@", notes_String_txt,staticChatView.text];
    //[staticChatView setContentOffset:CGPointMake(0, staticChatView.contentSize.height - staticChatView.bounds.size.height) animated:YES];
   

//}
};

void (^request_callback)(BOOL) = ^(BOOL granted){
    QMReceiverConfig *rxConf = [[QMReceiverConfig alloc] initWithKey:curentMode];
    
    
    rx = [[QMFrameReceiver alloc] initWithConfig:rxConf];
    [rx setReceiveCallback:recv_callback];
};

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}
@end
