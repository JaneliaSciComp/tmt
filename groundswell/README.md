Groundswell
===========

Groundswell is a Matlab application for browsing and analysis of
electrophysiology data, optionally in concert with video data.  It was
developed by Adam L. Taylor, under the direction of Stefan R. Pulver,
while Dr. Pulver was a fellow at HHMI Janelia.

This version was originally based on release 1.33 (commit ab86ee3) of
the standalone Groundswell repo.  Groundswell has since been folded
into the [TMT project](https://github.com/JaneliaSciComp/tmt), and
going forward will be released as part of TMT.


Contributions
-------------

Groundswell includes code from the TIFFStack project
(https://github.com/DylanMuir/TIFFStack).  This code carries a
different copyright and license (see the project README for details).


Authors
-------

[Adam L. Taylor](http://www.janelia.org/people/research-resources-staff/adam-taylor), taylora@hhmi.org  
[Scientific Computing](http://www.janelia.org/research-resources/computing-resources)  
[Janelia Research Campus](http://www.janelia.org)  
[Howard Hughes Medical Institute](http://www.hhmi.org)

[![Picture](/hhmi_janelia_160px.png)](http://www.janelia.org)


Version History
---------------

1.00
Original version.  Includes Taylor Matlab Toolbox v1.06.


-----


1.00->1.01  (August 31, 2011)
Updated to use TMT v1.10.


-----


1.01->1.02  (September 7, 2011)

Made each trace have its own timeline.  This will be useful
for, for example, looking at optical and electrical signals at the
same time, since those often have very different sampling rates.  Also
added the ability to load data from a .tcs file.


-----



1.02->1.03  (never completed)

Plan is to add ability to calculate coherency, cohereograms, and TFs.
This will require some way to select two traces that is asymmetric, in
that one signal will be the test, and one the reference, signal.
Think I will add a visual indication of the last signal selected.
Aborted this one.  Doing coherences, etc. with different sampling
rates is a royal pain, and I think not worth the effort.


-----



1.01->1.04  (September 9, 2011)

Reverting to 1.01, starting from there.  Dealing with calculating
cross-power spectra from signals on different time bases is a pain in
the ass at best.  Also, it's arguably a bad idea, because then the user
has to wonder about how the resampling is done.

Changed selections so that selected axes are indicated by a
boldface axis label.  I hope this makes it more apparent that the axes
are the things selected, not a particular stretch of the data.

Changed selections so that the most-recently-selected axes (which I
call the "pivot") is indicated visually, but italicizing the axis
label.  This also creates an asymmetry in the selection when two axes
are selected, which enables the input and output signals to be
specified when calculating coherency and TFs.

Fixed a bug with selections.  Have to keep track of complete sequence
of selection, so that the pivot one can change back to the previous
one when you ctrl-select the pivot.

Added ability to calculate coherency, cohereograms, and TFs.

Added ability to set arbitrary y ranges on axes, and optimize the y
ranges just on the selected axes.


-----



1.04->1.05 (September 13, 2011)

Added the ability to read .tcs files.  This involves upsampling of
signals to a common time base in some cases, which is warned about.

Also changed the code that does resampling to the pixel grid, to
eliminate use of blkproc(), which is deprecated.  Re-coded in JIT-able
Matlab.  Is now ~2x faster.

 
-----



1.05->1.06 (September 20, 2011)

Refactored the code so that there is a Groundswell_main class which
implements the main Groundswell window.  This let me move the
groundswell progam state into this object, and out of the figure,
axes, etc. userdata fields.  This was always one the biggest
weirdnesses with GUI programming in Matlab.

Fixed bug where debugging messages about the resampling method went to
the command window.

Fixed bug where Groundswell_main.get_spectrogram_params() and
Groundswell_main.get_spectrogram_params() didn't return enough args if
user hit 'Cancel' or there was a problem with the params.

Changed what Groundswell_main methods I could to static class methods.

Fixed bug where errordlg() would sometimes cause the main figure
contents to shrink.

Made it so y axis labels all line up w/ each other.

Deleted leading spaces from names & units on data load.


-----



1.06 -> 1.07  (September 21, 2011)

Refactored code into some approximation of the MVC style.  I think
this will make it easier to think about and maintain going forward.

Put the test code into the groundswell directory, so that I can
distribute the test code with the code proper.

First code checked into Janelia internal Subversion repository.

As with all versions since 1.01, groundswell 1.07 relies upon the 
Taylor Matlab Toolbox, version 1.10.


-----



1.07 -> 1.08 (December 16, 2011)

Made the pivot signal the reference/input signal.  This is better for
making polar plots of the coherency of many channels with respect to a
common reference (see below).

Added polar plots of coherency at a specified frequency, for multiple
test signals.  Raw data is also written to the clipboard in CSV
format.

Changed the way selected channels are shown, to make more salient.

Fixed bugs in display of spectrograms, coherograms when the time
origin for the current viewport is not zero.  

Added display of f_res_diam, N_fft for all spectral plots.  

This version relies upon Taylor Matlab Toolbox version 1.11.


-----


1.08 -> 1.09 (April 24, 2012)

Many many changes and improvements, including the integration of Roving, 
a GUI for browsing and analyzing optical data.

This version relies upon Taylor Matlab Toolbox version 1.13.


-----


1.09 -> 1.10 (May 22, 2012)

Improved synching of ROI data, especially when there are many more
exposure pulses than there are frames.

This version relies upon Taylor Matlab Toolbox version 1.13.

-----



1.10 -> 1.11 (July 17, 2012)

Roving now reads movies from disk, only loading a frame at a time into
main memory.  Also fixed a bug in which the "Coherency at probe
frequency" report that is written to the clipboard was in the order
that signals were selected, not the order they appear on screen.  They
now appear in the same order as onscreen.

This version relies upon Taylor Matlab Toolbox version 1.13.


-----



1.11 -> 1.12 (July 18, 2012)

In the "Coherency at probe frequency" report that is written to the
clipboard, when the coherency magnitude is not significant, the
coherency phase (and associated CI bounds) are reported as NaN.

This version relies upon Taylor Matlab Toolbox version 1.13.


-----



1.12 -> 1.13 (July 18, 2012)

Fixed a bug in which exporting ROI signals to a .tcs file didn't work.

This version relies upon Taylor Matlab Toolbox version 1.13.


-----



1.13 -> 1.14 (August 13, 2012)

Minor changes.

This version relies upon Taylor Matlab Toolbox version 1.13.


-----



1.14 -> 1.15 (August 14, 2012)

Fixed bug on Windows.  Re-enabled "Play as audio" function, because
it's very useful when it works.

This version relies upon Taylor Matlab Toolbox version 1.13.


-----



1.15 -> 1.16 (August 14, 2012)

Made shift-drag for square/circle ROI in Roving less fragile.  Tested
Roving on Windows XP.  Groundswell no longer chokes on reading an
all-nan signal from a .tcs file.  Other minor changes.

This version relies upon Taylor Matlab Toolbox version 1.13.


-----



1.16 -> 1.17 (August 21, 2012)

The various menu items for automatically setting the colorbar bounds
now look only at the current frame, not the whole movie.

This version relies upon Taylor Matlab Toolbox version 1.13.


-----



1.17 -> 1.18 (September 24, 2012)

Made the functions for adding ROI data more robust and more general, 
and renamed them to reflect this.

This version relies upon Taylor Matlab Toolbox version 1.13.


-----



1.18 -> 1.19 (November 16, 2012)

Added scrollbar for time axis in Groundswell.  Added options for
modifying various aspects of the view in spectrogram, coherency plots.
Added ability to resize Roving window.  Implemented a minimum window
size in Groundswell, Roving.  Improved handling of videos with no
frame rate information.  Now use shaded backdrop for displaying power
spectrum confidence interval.  Added "Revert" function to Groundswell.
Added ability to draw arbitrary polygonal ROIs in Roving.

This version relies upon Taylor Matlab Toolbox version 1.14.


-----




1.19 -> 1.20 (December 11, 2012)

Fixed bug in Scrollbar that occurred when t0!=0.

This version relies upon Taylor Matlab Toolbox version 1.14.


-----




1.20 -> 1.21 (April 26, 2013)

Refactored parts of Roving to improve scriptability.

This version relies upon Taylor Matlab Toolbox version 1.14.


-----




1.21 -> 1.22 (January 2, 2013)

Included a Spike2 script for importing .tcs files into Spike2.

This version relies upon Taylor Matlab Toolbox version 1.14.


-----




1.22 -> 1.23 (January 3, 2013)

Changed git repository to automatically include TMT 1.14 as a
submodule.  

Updated installation insttructions to match the .zip file names that
GitHub assigns automatically.



-----



1.23 -> 1.24 (January 23, 2015)

Added ability to import text files with column labels and time stamps.



-----



1.24 -> 1.25 (May 3, 2015)

Changed to TMT 1.16, to get bugfixes relating to underspecification of
character sets in load_abf() and .tcs functions.


-----


1.25 -> 1.26 (June 29, 2015)

Consolided README.txt, copyright.txt into README.md.  Added BSD 
3-clause license.  Added support for R2014b and later.  Had to 
remove a couple of UI hacks, including support for Mac command key 
instead of Alt/Option key.


-----


1.27 (June 29, 2015)

Included TMT 1.16 "by-hand", not as a submodule.  GitHub doesn't 
include submodules in their automatic .zip files, which is how we 
currently distribute Groundswell.  Fixed bug in README install 
instructions.


-----


1.28 (December 8, 2015)

Fixed bugs in Roving under >= R2014b.  Added "parula" colormap to 
Roving if using >= R2014b.  Improved initial positioning of 
Groundswell, Roving windows.


-----


1.29 (January 25, 2017)

Added support for ImageJ "jumbo" TIFF files.


-----


1.30 (January 26, 2017)

Added ability to export ROI mask image.


-----


1.31 (March 17, 2023)

Changes to make work better under Matlab r2023a.


-----


1.32 (March 17, 2023)

Updated this README.md.


-----


1.33 (January 10, 2024)

Show nonsignificant coherency phases in clipboard output
again. Eliminated another libtiff warning.




