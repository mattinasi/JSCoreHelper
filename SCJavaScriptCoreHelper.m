//
//  SCJavascriptCoreHelper.m
//  JSCore
//
//  Created by Attinasi, Marc on 7/9/14.
//  Copyright (c) 2014 Intuit, Inc. All rights reserved.
//

#import "SCJavaScriptCoreHelper.h"

@implementation SCJavaScriptCoreHelper


-(id) initJS:(NSString*)script
{
    self = [super init];
    if(self) {
        self.jsException = NULL;
        
        // create the global JS context that contains everything else
        self.jsContext = JSGlobalContextCreate(NULL);

        if(script) {
            JSValueRef jsException = NULL;
            
            // get the flowJo script and evaluate it, capturing the object returned as our enginePlugin
            JSStringRef scriptJS = JSStringCreateWithUTF8CString([script cStringUsingEncoding:NSUTF8StringEncoding]);
            JSValueRef result = JSEvaluateScript(self.jsContext, scriptJS, NULL, NULL, 0, &jsException );
            
            if (jsException)
            {
                self.jsException = jsException;
                NSLog(@"Exception loading script: %@",[self stringWithJSValue:jsException]);
            }
            else
            {
                // check result OR exception??
                self.jsEnginePlugin = JSValueToObject(self.jsContext, result, &jsException);
                if(jsException) {
                    self.jsException = jsException;
                }
            }
            
            // cleanup stuff we do not need
            JSStringRelease(scriptJS);
        }
    }
    return self;
}

-(JSValueRef) callJSFunction:(NSString*)fcnName
                    onObject:(JSObjectRef) target
              withJSArgument:(JSObjectRef)argument
{
    JSValueRef args[1];
    args[0] = argument;
    return [self callJSFunction:fcnName onObject:target withArgs:args andCount:1];
}

-(JSValueRef) callJSFunction:(NSString*)fcnName
                    onObject:(JSObjectRef) target
         withStringArguments:(NSArray*)arguments
{
    // convert string arguments
    //
    JSValueRef args[arguments.count];
    int i = 0;
    for(NSString* arg in arguments) {
        JSStringRef jsString = JSStringCreateWithUTF8CString([arg cStringUsingEncoding:NSUTF8StringEncoding]);
        args[i] = JSValueMakeString(self.jsContext, jsString);
        JSStringRelease(jsString);
        i++;
    }
    
    // call the JS function
    //
    JSValueRef result = [self callJSFunction:fcnName onObject:target withArgs:args andCount:arguments.count];
    
    return result;
}

-(JSValueRef) callJSFunction:(NSString*)fcnName
                  onObject:(JSObjectRef)target
                withCallback:(JSObjectCallAsFunctionCallback) callback
{
    JSObjectRef jsFunction = JSObjectMakeFunctionWithCallback(self.jsContext, NULL, callback);
    return [self callJSFunction:fcnName onObject:target withJSArgument:jsFunction];
}

-(JSValueRef)callJSFunction:(NSString*)fcnName
                   withArgs:(JSValueRef[])args
                   andCount:(NSUInteger)argCount
{
    return [self callJSFunction:fcnName onObject:self.jsEnginePlugin withArgs:args andCount:argCount];
}

-(JSValueRef)callJSFunction:(NSString*)fcnName
                 onObject:(JSObjectRef)target
                   withArgs:(JSValueRef[])args
                   andCount:(NSUInteger)argCount
{
    NSAssert(fcnName != nil, @"functionName argument cannot be nil");

    // default to global context if no target object, if that is nil try the global context. If still nill, bail
    if(!target) {
        target = self.jsEnginePlugin;
    }
    if(!target) {
        target = JSContextGetGlobalObject(self.jsContext);
    }
    NSAssert(target != nil, @"No target, no enginePlugin and no GlobalContext in &@", __PRETTY_FUNCTION__);

    JSValueRef jsException = NULL;
    JSValueRef result = NULL;
    self.jsException = NULL;
    
    if(target && fcnName) {
        JSStringRef fcnJSName = JSStringCreateWithUTF8CString([fcnName cStringUsingEncoding:NSUTF8StringEncoding]);
        JSValueRef jsFcnValue = JSObjectGetProperty(self.jsContext, target, fcnJSName, &jsException);
        if(!jsException && jsFcnValue) {
            JSObjectRef jsFcn = JSValueToObject(self.jsContext, jsFcnValue, &jsException);
            if(!jsException && jsFcn) {
                result = JSObjectCallAsFunction(self.jsContext, jsFcn, NULL, argCount, args, &jsException);
            } else {
                NSLog(@"Could not resolve %@ to a JS Function", fcnName);
            }
        } else {
            NSLog(@"Could not find function %@ in the enginePlugin.", fcnName);
        }
        
        if(jsException) {
            self.jsException = jsException;
        }
        JSStringRelease(fcnJSName);
    }
    return result;
}

- (void)addFunctionProperty:(NSString *)name
                   onObject:(JSObjectRef) target
               withCallback:(JSObjectCallAsFunctionCallback)theFunction {
    
    JSObjectRef targetObject = target ? target : JSContextGetGlobalObject(self.jsContext);
    if(!targetObject) {
        NSAssert(NO, @"No GlobalContext? What gives, JavaScript?");
    }
    
    // convert the name to a JavaScript string
	JSStringRef functionName = JSStringCreateWithUTF8CString([name cStringUsingEncoding:NSUTF8StringEncoding]);
	if ( functionName != NULL ) {
        // create a function object in the context with the function pointer.
		JSObjectRef functionObject = JSObjectMakeFunctionWithCallback( self.jsContext, functionName, theFunction );
		if ( functionObject != NULL ) {
            // add the function object as a property of specified object
			JSObjectSetProperty( self.jsContext, targetObject,
                                functionName, functionObject, kJSPropertyAttributeReadOnly, NULL );
		}
        // done with our reference to the function name
		JSStringRelease( functionName );
	}
}


#pragma mark -- String Helpers --

- (NSString *)stringWithJSValue:(JSValueRef)jsValue
{
    return [SCJavaScriptCoreHelper stringWithJSValue:jsValue fromContext:self.jsContext];
}

+ (NSString *)stringWithJSString:(JSStringRef)jsStringValue {
    if(jsStringValue) {
        return (__bridge NSString *) JSStringCopyCFString( kCFAllocatorDefault, jsStringValue );
    } else {
        return nil;
    }
}

/* convert a JavaScriptCore value in a JavaScriptCore context into a NSString. */
+ (NSString *)stringWithJSValue:(JSValueRef)jsValue fromContext:(JSContextRef)ctx {
    NSString* theResult = nil;
    
    /* attempt to copy the value to a JavaScriptCore string. */
    JSStringRef stringValue = JSValueToStringCopy( ctx, jsValue, NULL );
    if ( stringValue != NULL ) {
        
        /* if the copy succeeds, convert the returned JavaScriptCore
         string into an NSString. */
        theResult = [self stringWithJSString: stringValue];
        
        /* done with the JavaScriptCore string. */
        JSStringRelease( stringValue );
    }
    return theResult;
}

@end
