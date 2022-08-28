# [wit_io: A MATLAB toolbox for WITec Project/Data (\*.wip/\*.wid) files][file-exchange]

[![wit_io v1.2.0 Changelog Badge][changelog-badge]][changelog] [![BSD License Badge][license-badge]][license]

Toolbox can directly **read**/**write** [WITec] Project/Data (\*.wip/\*.wid)
files in [MATLAB] with or without GUI. It also provides data analysis tools.

![Example image](example.png)



## Overview

### Description
This [MATLAB] toolbox is intended for users of [WITec.de][WITec] microscopes
(i.e. Raman or SNOM), who work with **\*.wip**/**\*.wid** files (**v0** &ndash; **v7**)
and wish to directly **read**/**write** and **analyze** them in MATLAB. The
main aim of this project is to reduce the time consumed by importing, exporting
and various post-processing steps. Toolbox can also [read/write **any** WIT-tag
formatted files](#any-wit-tag-formatted-file).

### Background
The **wit_io** (or earlier *wip_reader*) project began in 2016 as a side product
of MATLAB analysis of huge Raman spectroscopic datasets obtained by WITec Raman
Alpha 300 RA. The hope was to reduce time spent to manual exporting (from WITec
software) and importing (in MATLAB software) and benefit from MATLAB's many
libraries, scriptability, customizability and better suitability to BIG data
analysis. During its development author worked for prof. Harri Lipsanen's group
in Aalto University, Finland.



## Usage

### License
This is published under **free** and **permissive** [BSD 3-Clause License][license].
Only exceptions to this license can be found in the *'[helper/3rd party]'* folder.

### Installation to MATLAB (for R2014b or newer)
Download [the latest toolbox installer] and double-click it to
install it.

### Installation to MATLAB (from R2011a to R2014a)
Download [the latest zip archive] and extract it as a new folder (i.e. *'wit_io'*)
to your workfolder.

**For the first time**, go to the created folder and run *(or F5)* *'[wit_io_permanent_load_or_addpath.m]'*
to **permanently** add it and its subfolders to MATLAB path so that the toolbox
can be called from anywhere. **This requires administration rights.**
* Without the rights, do one of the following once per MATLAB instance to make
**wit_io** findable:
    1. Execute `addpath(genpath('toolbox_path'));`, where `'toolbox_path'`
is **wit_io**'s full installation path.
    2. Manually right-click **wit_io**'s main folder in "Current Folder"-view
and from the context menu left-click "Add to Path" and "Selected Folders and
Subfolders".

### Installation to context menus (for MATLAB R2011a or newer)
**Optionally**, run *(or F5)* also *'[wit_io_update_context_menus_for_wip_and_wid_files.m]'*
to add *'MATLAB'*-option to the **\*.wip** and **\*.wid** file right-click
context menus to enable a quick call to `[O_wid, O_wip, O_wid_HtmlNames] = wip.read(file);`.
**This also requires administration rights.**

### Example cases
Run *(or F5)* interactive code (*\*.m*) under *'[EXAMPLE cases]'* folder to
learn **wit_io**. Begin by opening and running *'E_01_A_import_file_to_get_started.m'*.

### Semi-automated scripts
Consider using semi-automated scripts under *'[SCRIPT cases]'* folder on your
WITec Project/Data files. They will read the given file, interact with the
user, process the relevant file contents and finally write back to the original
file.

### Requirements and compatibility:
* Requires [Image Processing Toolbox](https://se.mathworks.com/products/image.html).
* Compatible with MATLAB R2011a (or newer) in Windows, macOS and Linux operating
systems.

## Advanced users

### Any WIT-tag formatted file
Toolbox can also **read** from and **write** to **arbitrary** WIT-tag formatted
files with use of `O_wit = wit.read(file);` and `O_wit.write();`, respectively.
Any WIT-tag tree content can be modified using `S_DT = wit.DataTree_get(O_wit);`
and `wit.DataTree_set(O_wit, S_DT);` class functions. Trees can also be viewed
in collapsed form from workspace after call to `S = O_wit.collapse();` (read-only)
or `O_wit_debug = wit_debug(O_wit);` (read+write).

### Format details of \*.wip/\*.wid-files
For more information, read *'[README on WIT-tag formatting.txt]'*. Please note
that it is by no means an all exhaustive list, but rather consists of formatting
for the relevant WIT-tags.



## Bugs
Please report any bugs in [Issues](https://gitlab.com/jtholmi/wit_io/issues)-page.



## Additional information

### Citation *(optional)*
J. T. Holmi (2019). wit_io: A MATLAB toolbox for WITec Project/Data (\*.wip/\*.wid) files (https://gitlab.com/jtholmi/wit_io), GitLab. Version \<x.y.z\>. Retrieved \<Month\> \<Day\>, \<Year\>.

### 3rd party content
* [export_fig](https://se.mathworks.com/matlabcentral/fileexchange/23629-export_fig)
* [mpl colormaps](https://bids.github.io/colormap/)
* [The Voigt/complex error function (second version)](https://se.mathworks.com/matlabcentral/fileexchange/47801-the-voigt-complex-error-function-second-version)

### Acknowledgments
[*] [jtholmi](https://gitlab.com/jtholmi)'s supervisor: [Prof. Harri Lipsanen](https://people.aalto.fi/harri.lipsanen), Aalto University, Finland  
[1] *'[clever_statistics_and_outliers.m]'*: G. Buzzi-Ferraris and F. Manenti (2011) "Outlier detection in large data sets", http://dx.doi.org/10.1016/j.compchemeng.2010.11.004  
[2] *'[apply_MRLCM.m]'* (and deprecated *wip_reader*): J. T. Holmi (2016) "Determining the number of graphene layers by Raman-based Si-peak analysis", pp. 27&ndash;28,35, freely available to download at: http://urn.fi/URN:NBN:fi:aalto-201605122027

[file-exchange]: https://se.mathworks.com/matlabcentral/fileexchange/70983-wit_io-toolbox-for-witec-project-data-wip-wid-files
[changelog]: ./CHANGELOG.md
[license]: ./LICENSE
[changelog-badge]: https://img.shields.io/badge/changelog-wit__io_v1.2.0-0000ff.svg
[license-badge]: https://img.shields.io/badge/license-BSD-ff0000.svg
[WITec]: https://witec.de/
[MATLAB]: https://www.mathworks.com/products/matlab.html
[the latest toolbox installer]: ./wit_io.mltbx
[the latest zip archive]: https://gitlab.com/jtholmi/wit_io/-/archive/master/wit_io-master.zip
[helper/3rd party]: ./helper/3rd%20party
[EXAMPLE cases]: ./EXAMPLE%20cases
[SCRIPT cases]: ./SCRIPT%20cases
[wit_io_permanent_load_or_addpath.m]: ./wit_io_permanent_load_or_addpath.m
[wit_io_update_context_menus_for_wip_and_wid_files.m]: ./wit_io_update_context_menus_for_wip_and_wid_files.m
[README on WIT-tag formatting.txt]: ./README%20on%20WIT-tag%20formatting.txt
[clever_statistics_and_outliers.m]: ./helper/clever_statistics_and_outliers.m
[apply_MRLCM.m]: ./helper/corrections/apply_MRLCM.m