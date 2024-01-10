curl https://jihulab.com/sunnybug/pubshell/-/raw/main/other/gs_svn_ignore/svn_ignore.txt -o svn_ignore.txt
svn propset svn:ignore -F svn_ignore.txt .
