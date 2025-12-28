#!/bin/bash

FILE_ROOT="$( dirname $BASH_SOURCE )"

mysql acore_world < "${FILE_ROOT}/ACSBV3-04-02A.sql"
mysql acore_world < "${FILE_ROOT}/ACSBV3-04-02B.sql"
mysql acore_world < "${FILE_ROOT}/ACSBV3-04-02C.sql"
mysql acore_world < "${FILE_ROOT}/ACSBV3-04-02D.sql"
mysql acore_world < "${FILE_ROOT}/ACSBV3-04-02E.sql"
mysql acore_world < "${FILE_ROOT}/ACSBV3-04-02F.sql"
