# Developer notes for Shibboleth and table authentation for REDCap

This document describes how to respond to issues, and how to make releases for this repo.

## Resources

This repository is the public repository for the distribution of the patches to Vanderbilt University's REDCap to allow it to use Shibboleth and table-based authentication at the same time. This repository works in tandem with the private repository, https://github.com/ctsit/shibboleth_and_table_auth_dev, where the patches and SQL files are developed. 

## Responding to issues

When end users report issues applying the patches to new versions of REDCap, use their feedback to develop the next patch in the https://github.com/ctsit/shibboleth_and_table_auth_dev. Follow the instructions in the README.md of that repo to guide your patching building work. 

## Making new releases

When the patch is built, copy the new patch file to the root of this repository and add it. Remove the previous patch file. If new SQL files were created with the patch, add them to the `shib_table_sql` folder. Do not remove old SQL files from the `shib_table_sql` folder as the entire history is important. The pull request for any changes should be against the `develop` branch. With the reviewed code merged into `develop`, do a git flow release. For the version number, use the REDCap version number of the patch, but follow it with a hyphen and serial number. E.g. the first release for the 9.1.1 patch should be 9.1.1-1, then 9.1.1-2, etc. Don't forget to update your changelog as usual. Make sure you push your tags to Github. 
