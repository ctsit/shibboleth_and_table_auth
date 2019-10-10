# Change Log for the `shibboleth_and_table_auth` repo

All notable changes to this project will be documented in this file.
Version numbers for this project include the REDCap version number for which the patch was released followed by a hyphen and a release serial number. e.g. 9.1.1-1 is the version number for the first release of a patch designed for REDCap 9.1.1.


## [9.3.0-1] - 2019-10-10
### Added
- Add 9.3.0 patch and SQL files for multiIdP support (Kyle Chesney)
- Migrated development tools and documentation into this repository.

### Changed
- Alter apply_patch.sh from p4 > p1 as patch was created via vandy repo workflow (Kyle Chesney)


## [9.2.2-1] - 2019-08-11
### Added
- Add patch for REDCap 9.2.2 (Philip Chase)


## [9.1.1-3] - 2019-08-11
### Changed
- Automatically determine proper patch version to use (Kyle Chesney, Philip Chase)


## [9.1.1-2] - 2019-07-23
### Changed
- fix missing comment in shib_table_auth.conf (Philip Chase)


## [9.1.1-1] - 2019-07-22
### Summary
- First release of repo. Created for REDCap 9.1.1
