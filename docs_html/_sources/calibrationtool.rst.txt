
.. _calibrationtool:

Calibration Tool
================

The calibration tool allows  to create and change calibration tables,
as well as  apply or de-apply calibration parameters  to data.  NCDRT
must be  in the eight  channel mode (no  averaging) for this  tool to
work properly. 


Text windows and buttons
------------------------


Create New Calibration Table 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:file:`calibration_display_event.pro`


Create a  new calibration table and  write it to  the file selected
with the pick file dialog widget. Any file name can be given.


Read Existing Calibration Table
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:file:`read_cal_table.pro`

Read  an existing calibration  table. The  pick file  dialog widget
allows to chose the file. NCDRT checks if the file is a calibration
table or not.


Calibration table information text window
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This  window contains  the information  about the  currently loaded
calibration table.


Write To Calibration Table
^^^^^^^^^^^^^^^^^^^^^^^^^^

:file:`write_2_cal_table.pro`

This is  the routine  which does the  actual calibration.  The user
must program  the calibrators and  frequencies. At the  time of
writing,  three  calibrators  are  included, with  the  frequencies
corresponding to  the maps  1 -  6 of the  P3B01 Mars  project. The
routine uses the frequency read  by load_obs.pro in the pou file to
identify the frequency set to use (parameter central_freq). It next
checks  the name  of the  object (parameter  object), also  read by
:file:`load_obs.pro`  from   the  :file:`pou`   file.  If  it   does  not   find  a
correspondance   between   the  object   name   and  the   included
calibrators, it will notify that no calibrator was found.

The  absolute fluxes  for  the three  calibrators included  (3C123,
3C161  and 3C295)  are taken  from  `Ott et al. (A&A  284, 331-339,
1994, Table 5) <https://articles.adsabs.harvard.edu/pdf/1994A%26A...284..331O>`_.

Once the absolute fluxes  are calculated, the routine compares them
to  the  measured  fluxes  from the  calibrator  observation.   The
calibration factor  for each  channel is determined  (including the
error, which  is the  total error, see  section 5.1), also  for the
averaging  channels.  It  is  assumed that  the  calibrator is  non
polarised,  so that every  channels corresponds  to half  the total
flux (in fact, the total flux  is what is written in these channels
by NAPS).


The results of this exercise  are written to the calibration table.
They  are  also  plotted   in  the  calibration  plot  window  (see
calibration plot window for explanation).

Here  the channel select  string is  taken into  account !  You can
select the good and bad channels for your calibrator.


Delete From Calibration Table 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:file:`delete_from_cal_table.pro`


Delete  the current calibrator  from the  calibration table,  if it
exists in the table.


Create :file:`.ps` Of Calibration Table: calibration_display_event.pro
Create a postscript  file of the calibration table  data.  The file
name  of  the  postscript  file  will  be  the  file  name  of  the
calibration table followed by :file:`.ps`.


Calibration process information
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This window contains information (warnings etc.) about the current
process.


Apply Current Calibration 
^^^^^^^^^^^^^^^^^^^^^^^^^^

:file:`apply_calibration.pro`

Apply the  calibration factors of the current  calibration table to
the  current  data.  Each  channel  is  multiplied  by the  set  of
calibration factors (8+4 channels)  from the calibration table that
is  closest  in time  to  the  current  observation.  This  can  be
different  for different channels,  as not  all channels  will have
good  calibration data  for each  observation! 
In  this version, nothing is done with the calibration factor error.


De-apply Current Calibration 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:file:`calibration_display_event.pro`


De-apply any calibration of the  current data. In fact, the current
data is restored to  its initial values (copy from :code:`channel_data_ori`
to the :code:`channel_data parameter`).


Dismiss
^^^^^^^

:file:`calibration_display_event.pro`


Dismiss the calibration tool, and  kill the plot window if any.  If
any calibration  table was loaded,  this table will stay  loaded in
NCDRT.



Explanation on the calibration plot window
------------------------------------------


In this window  the calibration factors for each  channel as from the
current calibration  table are plotted  and updated if any  action is
taken (new calibration data  or deleting of calibration data).  There
are 8 sets of 2 frames.  These correspond to the eight channels.  The
top  frame of each  set shows  the entire  calibration data  for that
channel, the lower frame shows a  detail of that data only around the
time of the current observation. A dotted vertical line indicates the
position of the current observation time.  If this time is out of the
calibrator table range, the whole  set is also plotted in the smaller
frame.

In the  first seven sets, the  dashed line correspond  to the average
channels (9-15).

A cross  means that the channel  was not selected  for the particular
time.

If a  new data file is  loaded, while the calibration  tool is active
with calibration  table loaded, then  the calibration plot  window is
updated to show the time of the current observation.




