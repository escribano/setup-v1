# The -o /dev/null is only necessary if you truly don't care about errors, since without that errors will be written to stderr (while the file is written to stdout)
# AFAIK, no need to -o /dev/null because that goes to stderr anyway.
wget -O - -o /dev/null  http://google.com

# You can use wget -qO- $URL to simplify things.
# wget -qO- $URL works if you're using Wget on Windows

# http://curl.haxx.se/
curl http://www.google.com/

lynx -source http://www.google.com

w3m -dump_source http://www.google.com

URL='http://wordpress.org/extend/plugins/akismet/'
curl -s "$URL" | egrep -o "http://downloads.wordpress.org/plugin/[^']+" | xargs wget -qO-