#!/bin/bash
cd .codecache
jar -cvf ../WEB-INF/lib/codecache.jar ruby
rm -rf ruby
cd ..
