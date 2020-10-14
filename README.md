[![Build Status](https://travis-ci.com/THCLab/odca-ruby.svg?branch=master)](https://travis-ci.com/THCLab/odca-ruby)

# OCA ruby tooling


to parse pre-prepared csv file just trigger it with:

    ruby parser.rb <FILENAME>

It will create `output` directory within which you will find sorted per schema base generated overlays.

For information about the format of the csv take a look into `examples`

## How to build input for parser

Parser is using csv files as an input. To make sure that the parser will be able to deal with the files you need to keep proper structure within those files. Parser use ';' as a column separator.

The flow of the parser is pretty simple:

1) scan third row and look for overlays. The name of the overlay needs to match with the class e.g "LabelOverlay"
2) scan each row and create schema base and specify overlays for each object. Rows should be in order sorted by schema base name. As soon as the schema base name change it is saved to the disk with all overlays and new object is created. It continues that process until eaching end of file.

All files are stored within output directory. Each time parser will override all files (in most of the case it will just create new one as the name iclude hash link)

For more details take a look on the examples or template in 'template/example.csv'


# Development

## Run test

    rake spec
