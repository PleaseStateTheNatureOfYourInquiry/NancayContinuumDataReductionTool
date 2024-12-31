
.. _workingwithncdrt:


Working with NCDRT
==================


Preparing for using NCDRT
--------------------------

Data from the NRT come in four files with the following structure:

.. code-block::

    fil050673.213
    pou050673.213
    log050673.213
    sfr050673.213

:file:`050673` is  the observation id, :file:`213`  is the observer id.  
The data are stored  in the :file:`fil` file. The  :file:`pou` file  contains information  on the
observation setup. The :file:`log` file contains a log of the observations.

The programme NAPS,  developed  by the NRT-team,  must  be used  to preprocess the  data. 
NCDRT uses  fits files.
NAPS can  transform the initial NRT data to fits format.

In order to  use NCDRT correctly, the fits files must  be in the same
directory as the  original data files. In order  to achieve this, set
the directory to write the fits files in NAPS:

.. code-block::

    NAPS> set result fits
    NAPS> set dirdata /home/your_name/ncdrt/data/
    NAPS> set dirfits /home/your_name/ncdrt/data/

With the NAPS  save command NRT data read into NAPS  is saved to fits
files with the following file  format, averaging over the cylces, one
fits file for each of the eight channels:

.. code-block::

    f050673_f1.fits
    f050673_f2.fits
    f050673_f3.fits
             .
             .
    f050673_f8.fits



Starting NCDRT
--------------

Once the  data has been transformed  into fits files,  NCDRT can read
them.  Start a new session of IDL and type

.. code-block::
    
    idl> @ncdrt.com  

to compile the programme files. 

Then type  

.. code-block::

    idl> ncdrt  

to start NCDRT.



Text windows and buttons
------------------------

The NCDRT  main interaction widget has several buttons, sliders and
information windows, which are now described.


Description of  the left column of  the widget and  going through the
rows from top to bottom:


.. _loaddatafile:


Load Data File
^^^^^^^^^^^^^^

:file:`load_obs.pro`  with  switch  :code:`next_obs = 0`.

A pick file dialog widget pops up.
The files listed by this widget are the :file:`f*_f1.fits` files present in the directory.
Select a file to load the data into NCDRT.

The eight channels are loaded and stored.
Seven average channels are being calculated and stored as channels 9-15.
Default is:

.. code-block::

    channel  9 = (channel 1 + channel 3) / 2
    channel 10 = (channel 2 + channel 4) / 2
    channel 11 = (channel 5 + channel 7) / 2
    channel 12 = (channel 6 + channel 8) / 2
    channel 13 = (channel 1 to channel 4) / 4
    channel 14 = (channel 5 to channel 8) / 4
    channel 15 = (channel 1 to channel 8) / 8

This can  of course  be changed  by the user.   In this  case, also
change the naming of the channels stored in parameter channel_print
and  defined  in  :file:`ncdrt_display.pro`. 
Average  channel  calibration needs also to be redefined in the :file:`routine write_2_cal_table.pro`, 
as well as  the automatic (de-)selection of averaging  channels if the

:code:`Averaging Switch` (see description of this switch) is pressed for to
change  from normal to  average mode  in the  current observation's
process  (:file:`ncdrt_display_event.pro`).
The :file:`sky_load_obs.pro` routine also needs to be adapted.

Search for the  :code:`USER: AVERAGING`  keyword in these programme files.

Whenever a fits  file is loaded, the fits file  list of the current
directory is  determined and stored in  NCDRT. This is  used in the
Load Next Data File and  Load Previous Data File actions (see below
for description).

Information  on the  current data  is read  from the  pou  file and
displayed in the first text window.  This is why it is mandatory to
have these files in the same directory as the fits files.

load_obs.pro  will also  search for  the presence  of  result files
produced previously. If it finds such  a file, it will read and set
the  slider settings  from it.  The order  of priority  is  :file:`.res_cal`
:file:`.res_av_cal`, :file:`.res` :file:`.res_av` (see :ref:`Save Result <saveresults>`).
The routines involved are :file:`read_res.pro and` :file:`read_res_av.pro`.
In case  there is  no result file, NCDRT will define standard settings for the sliders.

After  loading the  data and  setting  the sliders,  the result  is
determined by  calling :file:`show_lin_cut.pro` and  :file:`apply_lin_cut.pro`
(see section 5.1 on the working of these routines).

The  results are  shown on  the  plots (:ref:`scissors <scissorswitch>`  and results)  and
written to the large text window in the right column.

The :code:`n_channel`  and :code:`ch_address`  are kept as  they are.   For the
first file of a new session, they are set to

.. code-block::

    n_channel = 8
    ch_address = 0
   
This means that the first eight channels are being processed.


.. _scissorswitch:


Scissor Switch
^^^^^^^^^^^^^^

:file:`show_lin_cut.pro`  with switch :code:`scissor`.

This function changes the scissor window between the normal mode and
the detailed  mode. The normal mode  shows the entire  drift and the
current  cutting settings. The  detailed mode  devides the  drift in
three  parts, the  offset  (left  and right)  and  the central  part
(peak).  This is useful  is the  contrast between  the peak  and the
offset is large.


.. _loadnextdatafile:


Load Next Data File
^^^^^^^^^^^^^^^^^^^

:file:`load_obs.pro`  with  switch  :code:`next_obs = 1`.

Loads the next  data file in the current  directory.  In case there
are  no more  files,  the  pick file  dialog  widget appears.   The
settings of the sliders are not changed.


.. _loadpreviousdatafile:


Load Previous Data File
^^^^^^^^^^^^^^^^^^^^^^^

:file:`load_obs.pro`  with  switch  :code:`next_obs = -1`.

Loads the previous data file in the current directory. If there are
no  previous  files, the  pick  file  dialog  widget appears.   The
settings of the sliders are not changed.


.. _averagingswitch:


Averaging Switch
^^^^^^^^^^^^^^^^^


:file:`ncdrt_display_event.pro`  switches  :code:`n_channel` and :code:`ch_address`.
   
The  :code:`n_channel` and :code:`ch_address`  switches are  changed to  their
other values. The possible values for these switches are

.. code-block::

    (n_channel,ch_address)  = (8,0)  or  (7,8)
   
   
The  first set  means  that  the first  eight  channels are  being
processed,  the  second  set  is  for the  last  seven  (averaging
channels).

Upon changing  from normal to averaging the  channel select string
information  of  the normal  setting  is  kept.   Also an  average
channel is automatically deselected  if one of the normal channels
that are included in this average channel are deselected.




Observation information window
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Shows  information (name,  time, etc.)  of the  current observation loaded into NCDRT.


Process information window
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Shows information (warnings etc.) of the current process.


NCDRT Calibration Tool
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:file:`calibration_display.pro`  and associated routines.

Invokes the calibration tool. See :ref:`Calibration Tool <calibrationtool>` for a detailed description.

Create :file:`.ps`  Of Result (Standard): :file:`write_result_2_ps.pro`.

This creates a standard postscript file of the current result, like
in :ref:`Save Result <saveresults>`. 
The  postscript file is  named like in :ref:`Save Result <saveresults>`, with the extention :file:`.ps` to it.

Only  those channels are  selected which  have a  1 in  the channel select string.
In this way, you  can for example  output just the result of 1 channel at wish.

The slider  settings are indicated  in the plot by  dotted (offset)
and dashed (peak) lines.

Other information  is also written in  the plot. From  the pou file
come the indications  of the frequency and the  name of the object.
The indication (cal) (or (not cal)) after the 'peak flux' string in
the plot indicate that the data were calibrated (or not calibrated)
with a calibration table.


Create :file:`.ps`  Of Result (Choose Name): :file:`write_result_2_ps.pro`.
Same as  previous button, but  now you can  choose the name  of the result file.


.. _applycalibration:

Apply Calibration (Short Cut)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:file:`apply_calibration.pro`

Using this button the  calibration of the current calibration table
is applied to the data without having to go to the Calibration Tool
Widget.   It  is  the  same  as  Apply  Calibration  button  of  the
:ref:`Calibration  Tool <calibrationtool>`.
The  function  will  only  be   active  if  a calibration  table  is present. 
This  and  all other  calibration functions have to be performed with the :ref:`Calibration  Tool <calibrationtool>`.



Comment Text Window
^^^^^^^^^^^^^^^^^^^^

This window is  an editable window.  It allows the  user to write a
maximum of 40 characters long comment line. The line is included in
the result file when the  :ref:`Save Result <saveresults>` buttom is pressed, preceded
by the word ' Comment : '.  By using the grep and awk function in a
UNIX operating system  on all the existing result  files a log file
of all the comments can easily be made.


.. _saveresults:

Save Result
^^^^^^^^^^^^

:file:`save_res.pro`


Save the current result to a  standard file. There are four types of
result files, depending on the status of the process:
       
 f050673.res, first 8 channels with no calibration applied
 f050673.res_av, averaging channels with no calibration applied
 f050673.res_cal, first 8 channels with calibration applied
 f050673.res_av, averaging channels with calibration applied

Do never  change the  structure of these  files. NCDRT will  not be
able to read them afterwards.

.. _sliders:

Sliders
^^^^^^^^^^^^^^^^^^

:file:`ncdrt_display_event.pro`  and  :file:`show_lin_cut.pro`

There are four sliders: 

| Offset Low
| Offset High
| Peak Low
| Peak High

The offset  sliders determine the part  of the data to  be used for
the determination  of the offset.   There is a  build-in protection
that prevents  these sliders from having  inappropriate values: the
peak sliders must be at least  4 time units apart for the curve_fit
procedure  in the :file:`apply_lin_cut.pro`  routine to  work, and  the low
offset slider  cannot be larger  than the high offset  slider.  low
sliders cannot be set to more than half the range, Also, the offset
sliders cannot  be set to 0 or  to the maximum of  points.  This is
checked in  :file:`show_lin_cut.pro`.  See section 5.1  for further detail
on the working of :file:`show_lin_cut.pro` and :file:`apply_lin_cut.pro`.

The result of the cutting can  be seen in the Scissors plot window.
They change dynamically as the  slider values are changed. See also
the explanation of the :ref:`Scissor Switch <scissorswitch>` section.


Information Text Window
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This window shows the result of the current fit to the data. It are
the values  which will be written to  a file if you  press the Save
Result button. See  section 5.1 for more details  on the meaning of
the numbers.


Channel Select String
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The last text window in the right hand column contains the editable
channel select  string. A  '1' means that  the selected  channel is
processed  and  written to  the  result  file,  if this  action  is
required.  A '0' means that the channels is ignored. In the case of
processing  the  fours  averaging  channels, only  the  first  four
switches of the channels select string are taken into account.  The
use of the Averaging Switch resets the channel select string to all
default values (all '1').
                  
                   
Quit
^^^^^^^^^^^^^^^^^^
:file:`ncdrt_display_event.pro`

Quit NCDRT and close all the windows.



The planet.longitude file
--------------------------


NCDRT will search for a  file named planet.longitude in the directory
:file:`/home/your_name/idlproc/NCDRT/planet`. This  file contains a list of
the scan  numbers (preceded by the  letter 'f', and  without the user
id),  and the  Central  Meridian Longitude,  Sub  Earth Latitude  and
Distance to the Earth (AU) of  the planet that the user has observed.
The user must  create this file. It is  read in the ncdrt_display.pro
routine (near the end). The  user can change the filename, place, and
formatting at  wish. The  format of the  file must correspond  to the
format of the reading.

If  an observation  of the  planet is  reduced and  a result  file is
saved, and if that file  is listed in the planet.longitude file, then
an information  line is  written just below  the comment line  in the
result file.  If the file is  not found, or if the observation is not
in the list, then nothing is written (see the routine save_res.pro ).

This feature  can be helpful  if a study  of the radio emission  of a
planet as a function of Central Meridian Longitude and time is made.

An example  file is included  in this distribution,  corresponding to
the Mars file in the :file:`/home/your_name/idlproc/NCDRT/demo` directory.

