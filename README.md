JSCoreHelper
============

A helper class for accessing JavaScriptCore from Mac OS prior to 10.9


If you ever find yourself needing to integrate with JavaScript code in your Mac app, but you have to support 10.6, 10.7, or 10.8, then you will need something like this.

The focus of the API is on installing a javascript document that returns an object with the functions to access, referred to as the enginePlugin. (Note: The enginePlugin is optional, but it is a good way to structure javascript libraries for access from Mac programs)

