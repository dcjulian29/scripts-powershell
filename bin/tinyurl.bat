@setlocal enableextensions & C:\python\python.exe -x %~f0 %* & goto :EOF
import httplib
import sys

conn = httplib.HTTPConnection("tinyurl.com")
turl = sys.argv[1]

conn.request("GET", "/api-create.php?url=" + turl)

response = conn.getresponse()
data = response.read()

conn.close()

print
print "TinyURL for %s:" % turl
print
print data
print
