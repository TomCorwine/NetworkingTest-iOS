//
//  TRKViewController.m
//  Networking Test
//
//  Created by Tom Corwine on 7/30/12.
//  Copyright (c) 2012 Tracks Media. All rights reserved.
//

#import "TRKViewController.h"

#import "AFNetworking.h"

#define kTRKViewController_DownloadURLString				@"https://s3.amazonaws.com/networking-test/sample.mp4"

#define kTRKViewController_ProgressBarTagOffset				400
#define kTRKViewController_NumberOfProgressBars				20

#define kTRKViewController_ProgressBarActiveAlpha			1
#define kTRKViewController_ProgressBarInactiveAlpha			0.2

@interface TRKViewController ()
{
	UILabel *_label;
	UIStepper *_stepper;
	
	NSOperationQueue *_networkQueue;
	AFHTTPClient *_httpClient;
}

- (void)stepperValueWasChanged:(id)sender;
- (void)goButtonWasPressed:(id)sender;

@end

@implementation TRKViewController

- (id)init
{
    self = [super init];
    
	if (self)
	{
		_networkQueue = [[NSOperationQueue alloc] init];
		_httpClient = [[AFHTTPClient alloc] initWithBaseURL:nil];
		
		NSAssert(kTRKViewController_DownloadURLString.length, @"You must set the download URL before running this app.");
    }
    
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	CGFloat width = self.view.frame.size.width;
	
	// Stepper
	_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 22, 20, 20)];
	_label.textAlignment = UITextAlignmentRight;
	_label.text = @"1";
	[self.view addSubview:_label];
	
	_stepper = [[UIStepper alloc] initWithFrame:CGRectMake(40, 20, 80, 40)];
	[_stepper addTarget:self action:@selector(stepperValueWasChanged:) forControlEvents:UIControlEventValueChanged];
	_stepper.autorepeat = YES;
	_stepper.wraps = NO;
	_stepper.continuous = YES;
	_stepper.minimumValue = 1;
	_stepper.maximumValue = 20;
	_stepper.stepValue = 1;
	[self.view addSubview:_stepper];
	
	// Go Button
	UIButton *goButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	goButton.frame = CGRectMake(width - 170, 10, 160, 44);
	[goButton setTitle:@"Go" forState:UIControlStateNormal];
	[goButton setTitle:@"Stop" forState:UIControlStateSelected];
	[goButton addTarget:self action:@selector(goButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:goButton];
	
	// Progress Bars
	for (int i = 0; i < kTRKViewController_NumberOfProgressBars; i++)
	{
		UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 60 + (i * 20), width - 20, 10)];
		progressView.tag = kTRKViewController_ProgressBarTagOffset + i;
		progressView.alpha = kTRKViewController_ProgressBarInactiveAlpha;
		[self.view addSubview:progressView];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (void)stepperValueWasChanged:(id)sender
{
	UIStepper *stepper = sender;
	_label.text = [NSString stringWithFormat:@"%d", (NSInteger)stepper.value];
}

- (void)goButtonWasPressed:(id)sender
{
	UIButton *button = sender;
	
	[_networkQueue cancelAllOperations];
	
	button.selected = (button.selected == NO);
	
	switch (button.selected)
	{
		case NO:
			
			_stepper.enabled = YES;
			
			for (int i = 0; i < kTRKViewController_NumberOfProgressBars; i++)
			{
				UIProgressView *progressView = (UIProgressView *)[self.view viewWithTag:kTRKViewController_ProgressBarTagOffset + i];
				progressView.progress = 0;
				progressView.alpha = kTRKViewController_ProgressBarInactiveAlpha;
			}
			
			break;
			
		default:
		{
			_stepper.enabled = NO;
			
			NSInteger maxNumberOfOperations = _stepper.value;
			_networkQueue.maxConcurrentOperationCount = maxNumberOfOperations;
			
			for (int i = 0; i < maxNumberOfOperations; i++)
			{
				UIProgressView *progressView = (UIProgressView *)[self.view viewWithTag:kTRKViewController_ProgressBarTagOffset + i];
				progressView.alpha = kTRKViewController_ProgressBarActiveAlpha;
				
				NSMutableURLRequest *request = [_httpClient requestWithMethod:@"GET" path:kTRKViewController_DownloadURLString parameters:nil];
				AFHTTPRequestOperation *operation = [_httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject){

					progressView.progress = 1;
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error){

					progressView.progress = 0;
				}];
				
				[operation setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead){
					
					float progress = (double)totalBytesRead / (double)totalBytesExpectedToRead;
					progressView.progress = progress;
				}];
				
				[_networkQueue addOperation:operation];
			}
			
			break;
		}
	}
}

@end
