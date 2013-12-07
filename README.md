otp-geocode-server
==================

code for simple geocoder based on stops.txt

You will need to install some perl stuff

sudo perl -MCPAN -e 'install "HTTP::Server::Simple::CGI Compress::Zlib Text::CSV"'

Then copy your stops.txt file into the current directory.
It runs on port 8088, hack that to change.
