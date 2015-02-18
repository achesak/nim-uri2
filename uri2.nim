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


proc appendPathSegment*(uri : URI2, path : string) {.noreturn.} = 
    ## Appends the path segment specified by ``path`` to the end of the existing path.
    
    var newPath : string = uri.path
    var path2 : string = path
    if newPath.endsWith("/"):
        newPath = newPath[0..high(newPath) - 1]
    if path2.startsWith("/"):
        path2 = path2[1..high(path2)]
    
    newPath = newPath & "/" & path2
    uri.path = newPath


proc prependPathSegment*(uri : URI2, path : string) {.noreturn.} = 
    ## Prepends the path segment specified by ``path`` to the end of the existing path.
    
    var newPath : string = uri.path
    var path2 : string = path
    if newPath.startsWith("/"):
        newPath = newPath[1..high(newPath)]
    if path2.endsWith("/"):
        path2 = path2[0..high(path2) - 1]
    if not path2.startsWith("/"):
        path2 = "/" & path2
    
    newPath = path2 & "/" & newPath
    uri.path = newPath


proc getDomain*(uri : URI2): string = 
    ## Returns the domain of ``uri``.
    
    return uri.hostname


proc getScheme*(uri : URI2): string = 
    ## Returns the scheme of ``uri``.
    
    return uri.scheme


proc getUsername*(uri : URI2): string = 
    ## Returns the username of ``uri``.
    
    return uri.username


proc getPassword*(uri : URI2): string = 
    ## Returns the password of ``uri``.
    
    return uri.password


proc getPort*(uri : URI2): string = 
    ## Returns the port of ``uri``.
    
    return uri.port


proc getPath*(uri : URI2): string = 
    ## Returns the path of ``uri``.
    
    return uri.path


proc getPathSegments*(uri : URI2): seq[string] = 
    ## Returns the path segments of ``uri`` as a sequence.
    
    var paths : seq[string] = uri.path.split("/")
    
    return paths[1..high(paths)]


proc getPathSegment*(uri : URI2, index : int): string = 
    ## Returns the path segment of ``uri`` at the specified index.
    
    return uri.getPathSegments()[index]


proc getAnchor*(uri : URI2): string = 
    ## Returns the anchor of ``uri``.
    
    return uri.anchor


proc getAllQueries*(uri : URI2): seq[seq[string]] = 
    ## Returns all queries of ``uri``.
    
    return uri.queries


proc getQuery(uri : URI2, query : string, default : string = ""): string = 
    ## Returns a specific query in ``uri``, or the specified ``default`` if there is no query with that name.
    
    var result : string = default
    for i in uri.queries:
        if i[0] == query:
            result = i[1]
            break
    
    return result


proc setDomain*(uri : URI2, domain : string) {.noreturn.} =
    ## Sets the domain of ``uri``.
    
    uri.hostname = domain


proc setScheme*(uri : URI2, scheme : string) {.noreturn.} = 
    ## Sets the scheme of ``uri``.
    
    uri.scheme = scheme


proc setUsername*(uri : URI2, username : string) {.noreturn.} = 
    ## Sets the username of ``uri``.
    
    uri.username = username


proc setPassword*(uri : URI2, password : string) {.noreturn.} = 
    ## Sets the password of ``uri``.
    
    uri.password = password


proc setPort*(uri : URI2, port : string) {.noreturn.} = 
    ## Sets the port of ``uri``.
    
    uri.port = port


proc setPath*(uri : URI2, path : string) {.noreturn.} = 
    ## Sets the path of ``uri``.
    
    uri.path = path


proc setPathSegments*(uri : URI2, paths : seq[string]) {.noreturn.} = 
    ## Sets the path segments of ``uri``.
    
    var newpath : string = ""
    for i in 0..high(paths):
        newpath &= "/" & paths[i]
    
    uri.path = newpath


proc setPathSegment*(uri : URI2, path : string, index : int) {.noreturn.} = 
    ## Sets the path segment of ``uri`` at the given index. If the given index is larger than the highest
    ## current index, there will be no change.
    
    var segments : seq[string] = uri.getPathSegments()
    if high(segments)  < index:
        return
    
    segments[index] = path
    uri.setPathSegments(segments)


proc setAnchor*(uri : URI2, anchor : string) {.noreturn.} = 
    ## Sets the anchor of ``uri``.
    
    uri.anchor = anchor


proc setAllQueries(uri : URI2, queries : seq[seq[string]]) {.noreturn.} = 
    ## Sets all the queries for ``uri``.
    
    uri.queries = queries


proc setQuery(uri : URI2, query : string, value : string, overwrite : bool = true) {.noreturn.} = 
    ## Sets the query with the specified name and value in ``uri``. If ``overwrite`` is set to false, this will not
    ## overwrite any query with the same name that is already present.
    
    if not overwrite and uri.getQuery(query) != "":
        return
    
    var exists : bool = false
    var index : int = -1
    for i in 0..high(uri.queries):
        if uri.queries[i][0] == query:
            exists = true
            index = i
            break
    
    if exists:
        uri.queries[index][1] = value
    else:
        uri.queries.add(@[query, value])


proc setQueries(uri : URI2, queryList : seq[seq[string]], overwrite : bool = true) {.noreturn.} = 
    ## Sets multiple queries with the specified names and values in ``uri``. If ``overwrite`` is set to false, this will not
    ## overwrite any query with the same name that is already present.
    ##
    ## This proc differs from ``setAllQueries()`` in that it does not remove any existing queries, but instead
    ## just appends the new ones.
    
    for i in queryList:
        uri.setQuery(i[0], i[1], overwrite)


proc `/`*(uri : URI2, path : string) {.noreturn.} = 
    ## Operator version of ``appendPathSegment()``.
    
    uri.appendPathSegment(path)


proc `/`*(path : string, uri : URI2) {.noreturn.} = 
    ## Operator version of ``prependPathSegment()``.
    
    uri.prependPathSegment(path)


proc `$`*(uri : URI2): string = 
    ## Convers ``uri`` to a string representation.
    
    var query : string = ""
    for i in 0..high(uri.queries):
        query &= uri.queries[i][0] & "=" & uri.queries[i][1]
        if i != high(uri.queries):
            query &= "&"
    
    # Let's be lazy about this. :P
    var u : URI = URI(scheme: uri.scheme, username: uri.username, password: uri.password, hostname: uri.hostname,
                      port: uri.port, path: uri.path, query: query, anchor: uri.anchor)
    
    return $u

