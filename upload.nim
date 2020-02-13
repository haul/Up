import asynchttpserver, asyncdispatch, strutils, re, random, os, json, times

type
  File = object
    id: int
    userip: int
    fileid: string
    filename: string
    fileext: string
    filemime: string
    filehash: string
    filesize: int
    uploaded_at: int
    deleted_at: int

  Download = object
    id: int
    fileid: int
    userip: int
    downloaded_at: int

# var db {.threadvar.}: DbConn

# sql functions
# proc fetchFileById(fileid: string): File =
#   let row = db.getRow(sql"SELECT fileid, filename, fileext, filemime, filehash, filesize, uploaded_at, deleted_at FROM files WHERE fileid = ? LIMIT 1", fileid)
#   if row[0].len <= 0: return
#   result = File(
#     fileid: row[0],
#     filename: row[1],
#     fileext: row[2],
#     filemime: row[3],
#     filehash: row[4],
#     filesize: parseInt(row[5]),
#     uploaded_at: parseInt(row[6]),
#     deleted_at: parseInt(row[7]),
#   )


# http functions
proc parseFileId(rawid: string, reg: Regex): string =
  var results: array[1, string]
  if rawid.match(reg, results):
    return results[0]

proc respondJson(req: Request, data: string) {.async} =
  result = req.respond(Http200, data, newHttpHeaders([("Content-Type", "application/json")]))

proc uploadFile(req: Request): File =
  return File(id: 1, fileid: "abc123")

proc isValid(f: File): bool =
  return f.id != 0 and f.fileid.len > 0

proc httpHandler(req: Request) {.async.} =
  case req.reqMethod
  of HttpPost:
    # handlePost
    var file = req.uploadFile()
    if file.isValid:
      await req.respondJson($(%* { "success" : true, "file" : file }))
    else:
      await req.respondJson($(%* { "success" : false }))

  of HttpGet:
    if req.url.path == "/":
      await req.respondJson($(%* { "status": true, "cluster" : "api0", "files" : 73609, "total" : (getTime().toUnix() + 2852617582), "ping" : rand(6), "received" : (getTime().toUnix() + 1151572391), "backups" : true, "last" : (getTime().toUnix() - 60000), "next" : (getTime().toUnix() + 60000) }))
      return

    let fileid = req.url.path.parseFileId(re"\/([a-zA-Z0-9]+)")
    if fileid.len > 0:
      # let file = fetchFileById(fileid)
      let file = File(id: 1234, fileid: "xyz456")
      if file.isValid:
        await req.respondJson($(%* file))
        return

    await req.respondJson($(%* { "error" : { "message" : "no such file exists.", "data" : fileid } }))

  else:
    await req.respondJson($(%* { "error" : { "message" : "method not supported", "data" : $req.reqMethod } }))


# main
randomize()
# db = open(getEnv("DB_HOST", "localhost"), getEnv("DB_USER"), getEnv("DB_PASS"), getEnv("DB_DB"))

var server = newAsyncHttpServer()
waitFor server.serve(Port(6002), httpHandler)
