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

## Input files
All files must bin in excel format (.xlsx or .xls)

* **GenMoz database**
     * Columns: ```NUM, STUDY, SAMPLE.ID, EXTRACTION, VOL, TubeBarcode, CT, PARASITEMIA, GROUP, LIBRARY1, LIBRARY2, LIBRARY3, LIBRARY4, LIBRARY5, RackBarcode, Position, FREEZER, RUN, RUN2, RUN3, RUN4, RUN5, NOTES```
* **Library file**
     * Tab: ```Wilmut Scan Output``` 
     * Columns: ```Well, Sample ID, Library, Plate, Position, Barcode, Barcode check, Parasitemia, Group, Check```
* **Sequncing file**
    * Filename: name of the sequencing run
    * Tab: ```Balancing```
    * Columns: ```Well, Sample ID, Plate, Position, Barcode, Parasitemia, Group, Volume```

* **Scan file**
     * Columns: ```RackBarcode, Tube Row Text, Tube Column, Position, TubeBarcode```


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
* Import the GenMoz Lab database.
* Import the library, sequencing, and scan files (could be either or).
* Clean the data in the imported data frames.
* If a library file was provided, merge it with the database data frame based on the tube barcode.
* If a sequencing file was provided, merge it with the database data frame based on the tube barcode.
* If a scan file was provided, update the database with the new RackBarcodes and their resepctive positions.
* Reorder columns, final formatting.
* Save the modified database to a new output file with timestamp in the name (outputs are never overtwritten).
