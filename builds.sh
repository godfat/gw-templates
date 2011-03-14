#!/bin/sh
ruby template_reader.rb -p Skills/*.txt > builds.html
ruby template_reader.rb -t Skills/*.txt > builds.md
