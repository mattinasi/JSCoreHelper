//
//  SCJavascriptCoreHelper.h
//
//  A class to help manage calling into JavaScriptCore from Mac programs running on 10.6, 10.7 and 10.8
//   (Objective-C bindings to JavaScriptCore were introduced in 10.9, making it very easy to use JS, however
//    prior to 10.9 the interface to JavaScriptCore was in C, which is a bit more tedious.)
//
//
//  Created by Attinasi, Marc on 7/9/14.
//  Copyright (c) 2014 Intuit, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

/**
 *  SCJavaScriptCoreHelper - a simple class that is built on the C-bindings to JavaScriptCore
 *
 *  - manages a GlobalContet and a object-reference to a JavaScript object that acts as an engine-plugin
 *
 *  - has support for calling function on the engine-plugin, setting callbacks, and managing JSString conversion to NSString
 */
@interface SCJavaScriptCoreHelper : NSObject

@property JSGlobalContextRef    jsContext;
@property JSObjectRef           jsEnginePlugin;
@property JSValueRef            jsException;

/**
 *  initJS will initialize a new JS Global Context, load the specified script into the context
 *   and save a reference to the object returned
 *
 *  properties jsContext and jsEnginePlugin will be set upon successful return: 
 *   * jsContext is set to the global JavaScript context that was initialized, and
 *   * jsEnginePlugin is set to the JavaScript Object retrurned from the script execution
 *
 *  @param script the JSON string to load into the JS runtime. If nil no script wil be loaded
 */
-(id) initJS:(NSString*)script;

/**
 *  Call a JavaScript funtion, passing the argument provided
 *
 *  @param fcnName  The name of the JavaScript function to call. The functionName must be a valid function in the current context and target
 *  @param target   The object on whick to find the name function. If nil, self.jsEnginePlugin will be used. If that's null, the global context
 *  @param argument the JavaScript object to pass as an argument. This can be any JSObject that is valid in the current context, including a function-callback
 *
 *  @return the value returned from the JavaScript function, or NULL if it could not be called
 */
-(JSValueRef) callJSFunction:(NSString*)fcnName onObject:(JSObjectRef)onTarget withJSArgument:(JSObjectRef)argument;

/**
 *  Call a JavaScript function, passing an array of string arguments
 *
 *  @param fcnName  The name of the JavaScript function to call. The functionName must be a valid function in the current context and target
 *  @param target   The object on whick to find the name function. If nil, self.jsEnginePlugin will be used. If that's null, the global context
 *  @param arguments An Array of NSStrings that will be converted and passed to the JavaScript function
 *
 *  @return the value returned from the JavaScript function, or NULL if it could not be called
 */
-(JSValueRef) callJSFunction:(NSString*)fcnName  onObject:(JSObjectRef)onTarget withStringArguments:(NSArray*)arguments;

/**
 *  Call a JavaScript function, passing a callback function
 *
 *  @param fcnName  The name of the JavaScript function to call. The functionName must be a valid function in the current context and target
 *  @param target   The object on whick to find the name function. If nil, self.jsEnginePlugin will be used. If that's null, the global context
 *  @param callback The function to use as the callback
 *
 *  @return the value returned from the JavaScript function, or NULL if it could not be called
 */
-(JSValueRef) callJSFunction:(NSString*)fcnName  onObject:(JSObjectRef)onTarget withCallback:(JSObjectCallAsFunctionCallback) callback;

/**
 *  Call a JavaScript function, passing an array of JavaScript values as arguments
 *
 *  @param fcnName  The name of the JavaScript function to call. The functionName must be a valid function in the current context and target
 *  @param target   The object on whick to find the name function. If nil, self.jsEnginePlugin will be used. If that's null, the global context
 *  @param args     the arguments, as an array of JSValueRef's that are valid in the current context
 *  @param argCount number of arguments in the args-array
 *
 *  @return the value returned from the JavaScript function, or NULL if it could not be called
 */
-(JSValueRef)callJSFunction:(NSString*)fcnName  onObject:(JSObjectRef)onTarget withArgs:(JSValueRef[])args andCount:(NSUInteger)argCount;

/**
 *  Add a C callback function as a property to a javascript object
 *
 *  @param name        the name of the property to associate the function with
 *  @param target      the object ot add the junction to, or nil to add to the enginePlugin
 *  @param theFunction the C function to add to the object
 */
-(void)addFunctionProperty:(NSString *)name onObject:(JSObjectRef) target withCallback:(JSObjectCallAsFunctionCallback)theFunction;

/**
 *  Convert a JavaScript String into an NSString
 *
 *  @param jsValue js string - cannot be null
 *
 *  @return an allocated NSString - ownership is transferred to caller
 */
-(NSString *)stringWithJSValue:(JSValueRef)jsValue;

/**
 *  Convert a JSStringRef into an NSString
 *
 *  @param jsStringValue the jsStringValue to convert
 *
 *  @return a new NSString instance
 */
+(NSString *)stringWithJSString:(JSStringRef)jsStringValue;

/**
 *  Get an NSString from a JSValueRef, using the supplied context
 *
 *  @param jsValue a jsValueRef representing a JSString
 *  @param ctx     the jsContext under which the string was created
 *
 *  @return NSString copy of the jsValue
 */
+(NSString *)stringWithJSValue:(JSValueRef)jsValue fromContext:(JSContextRef)ctx;

@end
