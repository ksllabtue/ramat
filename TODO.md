Reformat:
https://gitmind.com/app/flowchart/01775759e2358b3eadf4ed190218156c

# Features

## Plotting
* Add legend to spectral plots
* Change axes in PCA plot

## LA Scans
* Add masks
* Set filter position

## Project import/export
* Does appending data work?
* Skip textfiles option
* Does overwriting work?

## GUI
* Recent files
* Save currently opened .ramat file vs save as...
* Dump to CLI

## Peak analysis
* Implement peak analysis

## PCA
* Display groups in tree, to change names
* Merge groups

## Background subtraction

# Bugs

* When selecting `Baseline correction...` when no dataset is loaded, the following error is shown:
```
Error using BgSubApp/startupFcn (line 176)
Function argument definition error in BgSubApp.startupFcn. Class 'ramatgui' is undefined or does not
support function validation.
```