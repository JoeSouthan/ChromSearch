#! /usr/bin/perl -w
use strict;
use SOAP::Transport::HTTP;
SOAP::Transport::HTTP::CGI   
  -> dispatch_to('/home/lighttpd/coursework/http/cgi-bin/Modules', 'ChromoDB', 'DBinterface')     
  -> handle;