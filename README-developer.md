# Developer notes for Shibboleth and table authentication for REDCap

This document describes how to respond to issues, and how to make releases for this repo.

## Resources

This repository is the public repository for the distribution of the patches to Vanderbilt University's REDCap to allow it to use Shibboleth and table-based authentication at the same time. This repository works in tandem with a local fork of Vanderbilt University's private REDCap repository, `https://github.com/vanderbilt/REDCap`, where REDCap is developed. This functionality will be added to REDCap core code, as such this repo now only exists to create patches for testers before the contents of the patch are included in future versions of REDCap.

## Responding to issues

When end users report issues applying the patches to new versions of REDCap, use their feedback to develop the next patch. Follow the instructions in the [Creating new patches](#Creating-new-patches) section to guide your patching building work.

# Creating new patches

## How to use this repo

This repo must be updated every time the shib-table patch needs to change. If a new REDCap version breaks the patch, development will be done in your fork of the Vanderbilt REDCap repository.  
You may need to edit the variables set in `scripts/version.config` to fit your particular development environment.

* `REDCAP_VERSION`: should be set to the same version as the file you are using (`N.M.O` of the `redcapN.M.O.zip`).
* `VANDY_REDCAP_DIR`: the `/path/to/your/fork/of/REDCap`.
* `VANDY_REDCAP_BRANCH_A`: the name of the base branch used to compare against for patch creation. Typically `master`, but may need to be detached at whichever commit is tagged with the `REDCAP_VERSION` being targeted.
* `VANDY_REDCAP_BRANCH_B`: the name of the branch containing the changes made. This is your development branch and should be branched off of `VANDY_REDCAP_BRANCH_A`.
  - Leaving this blank will allow you to create a patch based on the current state of your `VANDY_REDCAP_DIR` directory, that is, modified (but unstaged) git tracked files will be used to create the patch.
    - Note that if you do not have `VANDY_REDCAP_BRANCH_B` checked out in your `VANDY_REDCAP_DIR` leaving this blank will track _whatever is currently checked out_.

## Developing & Testing
Files will be edited in your `VANDY_REDCAP_DIR`. Again, you must have `VANDY_REDCAP_BRANCH_B` checked out. If you need to make any SQL changes, store them in `shib_table_sql` as `<REDCAP_VERSION>.sql`. 

### Testing
Test code by rsyncing to `stage_c` using `scripts/sync_to_staging.sh` and visiting [`https://redcapstage.ctsi.ufl.edu/stage_c/`](https://redcapstage.ctsi.ufl.edu/stage_c/). `stage_c` must have your `REDCAP_VERSION` installed and running.  
This can become tedious if making repeated small tweaks. You may find it helpful to run the following script while making changes to "live edit":  
```bash
while true; do bash ./scripts/sync_to_staging.sh; sleep 1; done;
```

## Review Stage 1 - site functionality

If you are satisfied with the functionality of the website, ask a reviewer to test it on `stage_c`. There will be no PR at this step as it depends on code changes made in your `VANDY_REDCAP_DIR`. If enough changes need to be made to make the website functional that someone else could suggest, they should make a PR against your fork of Vanderbilt's REDCap repo.  
If the functionality of the website is approved of, it is time to move on to creating and testing a patch. _You should still not have made any commits to **this repo** at this point._

## Creating a patch file

Adding a REDCap version patch to this repo should follow these procedures. In these steps the new version is described as version `N.M.O`, `N.M.O` is your `REDCAP_VERSION`.

1. Run `bash scripts/make_diff.sh` to create a file named `redcap-N.M.O.patch` from your `VANDY_REDCAP_DIR`.
2. Put a fresh `redcapN.M.O.zip` file in the root directory of this repository.
3. Use `bash apply_patch.sh redcap_N.M.O.zip` to create a patched zip file at `output/redcapN.M.O.zip`.
4. Copy the _patched_ `redcapN.M.O.zip ` and `N.M.O.sql` to your `redcap_deployment` directory and use them make a vagrant image.
   - `fab vagrant package:redcap.N.M.O.zip && fab vagrant upgrade:redcap-N.M.O.tar.gz && fab apply_sql_to_db:N.M.O.sql`
5. Test your VM of the patched REDCap, ensure default values from `N.M.O.sql` appear where expected and functionality does not differ from `stage_c`.
   - Note you will not be able to follow Shibboleth login links in your VM as Shibboleth must be set up on a server. That is fine, its functionality should have been tested on `stage_c`.
6. After the code has been tested successfully, submit a pull request for code review.

## Review stage 2 - patch file

A reviewer should only be testing a PR containing a `redcap-N.M.O.patch file` and (if needed) an `N.M.O.sql` file; to this end, they should only need to complete steps 2-5 of [Creating a patch file](#creating-a-patch-file).

## Making new releases

When the patch is built, copy the new patch file to the root of this repository and add it. If new SQL files were created with the patch, add them to the `shib_table_sql` folder. Do not remove old SQL files from the `shib_table_sql` folder as the entire history is important. Do not remove any old patch files either as the `apply_patch.sh` knows how to pick the correct patch. 

The pull request for any changes should be against the `develop` branch of this repo. With the reviewed code merged into `develop`, do a git flow release. For the version number, use the REDCap version number of the patch, but follow it with a hyphen and serial number. E.g. the first release for the 9.1.1 patch should be 9.1.1-1, then 9.1.1-2, etc. Don't forget to update your changelog as usual. Make sure you push your tags to Github. 
