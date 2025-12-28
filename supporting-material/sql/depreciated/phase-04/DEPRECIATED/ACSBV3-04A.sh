#!/bin/bash

FILE_ROOT="$( dirname $BASH_SOURCE )"

mysql acore_world < "${FILE_ROOT}/ACSBV3-04-00A.sql"
mysql acore_world < "${FILE_ROOT}/ACSBV3-04-00B.sql"
mysql acore_world < "${FILE_ROOT}/ACSBV3-04-00C.sql"

mysql acore_world < "${FILE_ROOT}/ACSBV3_proc_smooth_curve.sql"

mysql acore_world < "${FILE_ROOT}/ACSBV3-04-01A.sql"

echo "ACSBV3-04-01B is not automated. Please review ${FILE_ROOT}/ACSBV3-04-01B-Python-CMD.txt "
echo "Once ACSBV3-04-01B is complete, run ${FILE_ROOT}/04B.sh"
