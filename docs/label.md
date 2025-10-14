# Documentation for the-label system of the carton engine

## Overview
the-label is a package within the-carton engine that is responsible for handling game level design configuration using google sheets. the-label provides two methods of configuration; key value pairs, and matricies. It is intended to have a very simple setup phase to ensure it is always a good option to include for iterative design.

## Technical
the-label is a two step process. The first is to attach sheets to .label files, and the second is to apply the .label files to game systems. The benefit of this is to be able to still do offline development and provide source control that is better than Googles, while still being able to use all of the extra benefits of the Sheets platform. Another important technical note is that there should be a compile time and run time implementation. This way you can build for the player and the values can not be changed but you can send a build to a designer who can update at runtime. Longterm support may include hot reloading

## auth.key
You need to supply an authorisation to use ggole sheets. Ill append more details later. 

## .sheet-id
This is a file format for including required sheet ids it is its own format so you can give it a nice name like camera.sheet-id and you can exclude it from your source control these unique ids can allow anyone to change val
:ues so dont leak them lol

## .label-kv
This is the file format for storing key value pairs. An example is as follows:

[Key] [CachedValue] [Cell] [SheetName] [FilepathOfSheetID]
zoom  100           A2     Camera      "../camera.sheet-id"
angle 80            B2     Camera      "../camera.sheet-id"

the-label provides a procedure for updating a .label-kv, loading a .label-kv at runtime and compile-time. This gets loaded into a struct

## .label-mat
