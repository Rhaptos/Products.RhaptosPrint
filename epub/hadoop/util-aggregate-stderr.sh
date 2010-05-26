#!/bin/bash

# Set XSLTPROC_ARGS so it only outputs aggregate bugs
declare -x XSLTPROC_ARGS="--stringparam outputAggregateOnly yes"

# Run the command, swapping stderr and stdout
# Each line in stderr (from xsl:message in xsl/debug.xsl will create an entry
#   for hadoop to coulnt and tally, while anything originally sent to stdout
#   (Like the current module it's working on when hadoop failed)
#   will be sent to hadoop's logging

# Since we need to add a 1 as the value, replace all tabs in the output of the script with a space, and tack on a tab at the end.
$@ 3>&2 2>&1 1>&3- | sed 's/|/(pipe)/g' | sed 's/	/\ /g' | sed 's/^.*$/LongValueSum:&	1/'
# | tee /dev/stderr
