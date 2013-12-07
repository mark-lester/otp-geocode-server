#!/usr/bin/perl
use strict;

 {
 package MyWebServer;
 
 use HTTP::Server::Simple::CGI;
 use base qw(HTTP::Server::Simple::CGI);
 
 my %dispatch = (
     '/geocoder/geocode' => \&resp_geocode,
     # ...
 );
 my $records;
 
sub set_records {
	shift;
	$records=shift;
}
 
 sub handle_request {
     my $self = shift;
     my $cgi  = shift;
   
     my $path = $cgi->path_info();
     my $handler = $dispatch{$path};
 
     if (ref($handler) eq "CODE") {
         print "HTTP/1.0 200 OK\r\n";
         $handler->($cgi);
         
     } else {
         print "HTTP/1.0 404 Not found\r\n";
         print $cgi->header,
               $cgi->start_html('Not found'),
               $cgi->h1('Not found'),
               $cgi->end_html;
     }
 }

 sub resp_geocode {
     my $cgi  = shift;   # CGI.pm object
     return if !ref $cgi;
     my $output;
     
     my $where = $cgi->param('address');
     my @matches=grep { $records->{$_}->{stop_name} =~ /$where/i} keys %$records ;
     $output.= '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
     $output.= "\n";
     my $num_matches=$#matches+1;
print STDERR "call($where)($num_matches)\n";
     $output.= "<geocoderResults>
  <count>$num_matches</count>
  <results>\n";

     foreach my $stop_id (@matches){
	my $rec=$records->{$stop_id};
	$output.= "    <result>
        <description>$rec->{stop_name}</description>
        <lat>$rec->{stop_lat}</lat>
        <lng>$rec->{stop_lon}</lng>
    </result>\n";
     }
     $output.= "  </results>
</geocoderResults>\n";

     use Compress::Zlib;
     my $zipped = Compress::Zlib::memGzip($output) 
        or die "Cannot compress: $gzerrno\n";
     my $length=length($zipped);
     print "Content-Type: text/xml\n".
      "Content-Encoding: gzip\n".
      "Access-Control-Allow-Origin: *\n".
      "Content-Length: $length\n".
      "\n";

     print $zipped;

 }
 
 } 
 
 # start the server on port 8088
 MyWebServer->set_records(read_stops());
 my $pid = MyWebServer->new(8088)->background();
 print "Use 'kill $pid' to stop server.\n";

use Text::CSV;

sub read_stops{
 my %records;
 my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                 or die "Cannot use CSV: ".Text::CSV->error_diag ();
 
 open my $fh, "<:encoding(utf8)", "stops.txt" or die "stops.txt: $!";
 my $cols = $csv->getline( $fh );
 while ( my $row = $csv->getline( $fh ) ) {
	my %record;
	@record{@$cols}=@$row;
	$records{$record{stop_id}}=\%record;
 }
 $csv->eof or $csv->error_diag();
 close $fh;
  return \%records;
}

