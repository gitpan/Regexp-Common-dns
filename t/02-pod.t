# $Id: 02-pod.t,v 1.1 2003/11/11 21:15:32 ctriv Exp $

use strict;
use Test::More;

eval "use Test::Pod 1.00";

plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;

all_pod_files_ok();

