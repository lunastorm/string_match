#!/usr/bin/perl

my @patterns;
open(my $fh, "patterns") or die("cannot open patterns");
while ( ! eof($fh) ) {
  $pattern = <$fh>;
  push(@patterns, $pattern);
}

while($line=<STDIN>){
  foreach $pattern (@patterns){
    if ($line =~ /$pattern/){
      print "$line matches $pattern";
    }
  }
  #if ($line =~ /.*asdf.*/){
  #  print "fuck";
  #}
}
