     _|_|_|    _|_|_|    _|    _|                  _|              _|                    _|_|_|   
     _|    _|  _|    _|  _|    _|  _|_|_|      _|_|_|    _|_|_|  _|_|_|_|    _|_|        _|    _| 
     _|    _|  _|_|_|    _|    _|  _|    _|  _|    _|  _|    _|    _|      _|_|_|_|      _|_|_|   
     _|    _|  _|    _|  _|    _|  _|    _|  _|    _|  _|    _|    _|      _|            _|    _| 
     _|_|_|    _|_|_|      _|_|    _|_|_|      _|_|_|    _|_|_|      _|_|    _|_|_|  _|  _|    _| 
                                   _|                                                              
                                   _|                                                                                                                                                         
# DBUpdate.R
This script is designed to add library and/or sequencing data and/or update the GenMoz Lab database based on tube barcodes.

## Dependencies

* `readxl`
* `openxlsx`
* `optparse`

*Note: the script automatically installs the dependencies if not found in your system*

## User Inputs 

* `-l` or `--lib`: Path to the library file
* `-s` or `--seq`: Path to the sequencing file
* `-c` or `--scan`: Path to the scan file
* `-d` or `--db`: Path to the database file (mandatory)
* `-o` or `--out`: Path to the output file

*Note: all inputs must be in xlsx format and with the same formt as the lab templates*

## Usage

```
Rscript DBUpdate.R -l /path/to/library.xlsx -s /path/to/sequencing.xlsx -c /path/to/scan.xlsx -d /path/to/database.xlsx -o /path/to/output.xlsx
```
or

```
Rscript DBUpdate.R --lib=/path/to/library.xlsx -seq=/path/to/sequencing.xlsx -scan=/path/to/scan.xlsx --db=/path/to/database.xlsx --out=/path/to/output.xlsx
```


## Outputs
The script will output a modified version of the input database file. If an output file path is specified, the modified database will be saved to that path. Otherwise, the modified database will be saved to a file named `GenMoz_LAB_DB_yyyy-mm-dd_HH-MM-SS.xlsx` in the current working directory.

## Functionality
* Import the library, sequencing, and scan files (could be either or).
* Clean the data in the imported data frames.
* If a library file was provided, merge it with the database data frame based on the tube barcode.
* If a sequencing file was provided, merge it with the database data frame based on the tube barcode.
* If a scan file was provided, update the database with the new RackBarcodes and their resepctive positions.
* Reorder column names.
* Save the modified database to an output file or to a default file name with timetamp. Outputs are never overtwritten.
