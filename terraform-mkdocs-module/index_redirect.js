'use strict';

exports.handler = (event, context, callback) => {
    
    const request = event.Records[0].cf.request;
    if ((request.uri !== "/")
        && (request.uri.endsWith("/") 
            || (request.uri.lastIndexOf(".") < request.uri.lastIndexOf("/")) 
            )) {
        if (request.uri.endsWith("/"))
            request.uri = request.uri.concat("index.html");
        else
            request.uri = request.uri.concat("/index.html");
    }
    callback(null, request);
};