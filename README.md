otp-geocode-server
==================

code for simple geocode server based on stops.txt

You will need to install some perl stuff

sudo perl -MCPAN -e 'install "HTTP::Server::Simple::CGI Compress::Zlib Text::CSV"'

Then copy your stops.txt file into the current directory.
It runs on port 8088, hack that to change.

The program expects HTTP requests, for '/geocoder/geocode?address=XXXX', it returns an XML list of records, 

e.g.
/geocoder/geocode?address=dhak

might return

<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<geocoderResults>
  <count>2</count>
  <results>
    <result>
        <description>Hazrat Sharjalal Airport,Dhaka</description>
        <lat>23.8521053</lat>
        <lng>90.4083428</lng>
    </result>
    <result>
        <description>Kamalapur,Dhaka</description>
        <lat>23.7330725</lat>
        <lng>90.4261318</lng>
    </result>
  </results>
</geocoderResults>
