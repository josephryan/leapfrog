# leapfrog

## DESCRIPTION

identify BLAST hits between two datasets by employing a third intermediate dataset

## AVAILABILITY

https://github.com/josephryan/leapfrog (click the "Download ZIP" button at the bottom of the right column).

### DEPENDENCIES

General system tools:
- [Perl] (http://www.cpan.org/), comes with most operating systems

## INSTALLATION

To install `leapfrog` and documentation, type the following:

    perl Makefile.PL
    make
    sudo make install

If you do not have permission to install to the system see the following:

    http://www.perlmonks.org/index.pl?node_id=128077#permission

## RUN

   leapfrog [--eval=EVALUECUTOFF] [--help] [--version] --1v2=TABBLAST --2v1=TABBLAST --1v3=TABBLAST --2v3=TABBLAST --3v2=TABBLAST

## DOCUMENTATION

Documentation is embedded inside of `leapfrog` in POD format and
can be viewed by running any of the following:

        leapfrog --help
        perldoc leapfrog
        man leapfrog  # available after installation

## COPYRIGHT AND LICENSE

Copyright (C) 2015 Joseph F. Ryan

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program in the file LICENSE.  If not, see
http://www.gnu.org/licenses/.


