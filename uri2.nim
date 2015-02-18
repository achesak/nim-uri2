# Nim module for improved URI handling.
# Based on the "uri" module in the Nim standard library and the 
# "purl" Python module at https://github.com/codeinthehole/purl.

# Written by Adam Chesak.
# Released under the MIT open source license.


import uri
import strutils


type
    URI2* = ref URI2Internal
    
    URI2Internal* = object
        scheme : string
        username : string
        password : string
        hostname : string
        port : string
        path : string
        anchor : string
        queries : seq[seq[string]]


proc parseURI2*(uri : string): URI2 = 
    ## Parses a URI.
    
    var u : URI = parseUri(uri)
    
    var queries : seq[string] = u.query.split("&")
    var queries2 : seq[seq[string]] = newSeq[seq[string]](len(queries))
    for i in 0..high(queries):
        queries2[i] = queries[i].split("=")
    
    var newuri : URI2 = URI2(scheme: u.scheme, username: u.username, password: u.password, hostname: u.hostname, port: u.port, 
                             path: u.path, anchor: u.anchor, queries: queries2)
    
    return newuri


proc 
        
    

var test : URI2 = parseURI2("http://www.google.com/index.html?test=my%20data&test2=something1234")
echo(test.username)

