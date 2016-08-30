# Project Title

biogrid.pl - a script used to identify physical interactions based on 
             the biogrid database

### Prerequisities

you need HumRef2015.fa.gz from https://github.com/josephryan/reduce_refseq

## Getting Started

The following commands should be sufficient to run the program:

<pre>$ gzip -d Homo_sapiens.gene_info.gz 
$ gzip -d BIOGRID-ORGANISM-Homo_sapiens-3.4.139.tab2.txt.gz
$ gzip -d smed.leapfrog.gz
$ wget https://github.com/josephryan/reduce_refseq/raw/master/HumRef2015.fa.gz
$ gzip -d HumRef2015.fa.gz
$ perl biogrid.pl</pre>

## biogrid.pl.output

This is the output of the command included in Martin-Duran et al.

## Author

* **Joseph Ryan** 

## License

    Copyright (C) 2016  Joseph F. Ryan

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Acknowledgments

* Thanks to an anonymous reviewer who suggested we look at interactions


