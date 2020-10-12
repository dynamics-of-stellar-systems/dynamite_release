#!/bin/csh -f
# sdpds: script to decode a sif file and then run PDS on the output
#  ( Last modified on 23 Dec 2000 at 17:29:56 )
#
#{version}
#
# Use: sdpds [-s] [-h] [-k] [-o j] [-l secs] [-show] [-param name=value[,name=value...]] [-debug] probname[.SIF]
#
# where: options -s     : run the single precision version
#                         (Default: run the double precision version)
#                -h     : print this help and stop execution
#                -k     : keep the load module after use
#                         (Default: delete the load module)
#                -o     : 0 for silent mode, 1 for brief description of
#                         the stages executed.
#                         (Default: -o 0)
#                -l     : sets a limit of secs second on the runtime
#                         (Default: 99999999 seconds)
#                -show  : displays possible parameter settings for
#                         probname[.SIF]. Other options are ignored
#                -param : cast probname[.SIF] against explicit parameter
#                         settings. Several parameter settings may be
#                         given as a comma-separated list following
#                         -param or using several -param flags.
#                         Use -show to view possible settings
#                -debug : links all the libraries, creates the executable
#                         and stop to allow debugging. This option
#                         automatically disables -n and enables -k.
#
#       probname      probname.SIF is the name of the file containing
#                     the SIF file for the problem of interest.
#

#
#  N. Gould, D. Orban & Ph. Toint, November 7th, 2000
#

#{cmds}

#
# Environment check
#

envcheck
if( $status != 0 ) exit $status

#
#  define a short acronym for the package to which you wish to make an interface
#

setenv caller sdpds
setenv PAC pds

#
#  Check the arguments
#

set PRECISION = "double"
@ decode_problem = 0
@ last=$#argv
@ i=1

while ($i <= $last)
  set opt=$argv[$i]
  if("$opt" == '-s')then
    set PRECISION = "single"
  else if("$opt" == '-decode' ) then
    @ decode_problem = 1
  else if("$opt" == '-h' )then
    $MYCUTER/bin/helpmsg
    exit 0
  endif
  @ i++
end

if( $decode_problem == 0 ) then
  set arguments = ('-decode' "$argv[1-$last]")
else
  set arguments = ("$argv[1-$last]")
endif

# call main script

${PAC} ${arguments}

if ( $status != 0 ) exit $status

#  this is where package-dependent commands (using the commands defined
#  in the current system.(your system) file) may be inserted to clean
#  up after running the package

