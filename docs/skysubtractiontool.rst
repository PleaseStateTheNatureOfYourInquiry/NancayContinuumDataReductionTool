
.. _skysubtractiontool:


Sky Subtraction Tool
====================

The  Sky Subtraction Tool  allows to  subtract two  observations from
each other.  
This is of particular  use when the  data concern solar system objects,
in which the same  spot of the sky  is observed with and without the object.

If  calibration is  applied to  the data,  then the  same calibration
table is used to simultaneously calibrate the sky data. Note that the
calibration   factors  can   differ  between   the  object   and  sky
observations,  as  both  observations  could have  been  made  during
different epochs.

The process  of subtraction takes places AFTER  the individual offset
corrections to both the object and the sky observations.

.. admonition:: important

    If  you want to save  the results of the  subtraction to a :file:`.res` file  using the  'save' button in  the main widget
    (see :ref:`save results <saveresults>`), then the Sky Subtraction Tool must be open!


Text windows and buttons
------------------------


Load Sky Data File
^^^^^^^^^^^^^^^^^^

:file:`sky_load_obs.pro`

Load a  file that contains the  sky observation. The  format of the
file and the  loading process are entirly similar  to the Load Data
File in the main widget. This includes the averaging. The result is
shown in a plot with the same structure as the Results plot.


Observation information window
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Shows  information (name,  time, etc.)  of the  current observation
loaded into NCDRT.


Process information window
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Shows  information (warnings etc.) of the current process.


Main Slider Tracking Switch
^^^^^^^^^^^^^^^^^^^^^^^^^^^

:file:`sky_subtract_event.pro`  switch  :code:`main_slider_track`

By default, the  offset cutting sliders of the  sky observation are
set  to the  same values  as the  object observation.  If  the main
sliders  are changed, the  sky sliders  will also  change. Pressing
this   button   will   give   independent  control   of   the   sky
sliders.  Pressing it  again will  undo  this control  and set  the
sliders back to the main slider values.


Sky Offset Low
^^^^^^^^^^^^^^

:file:`sky_subtract_event.pro`


The cutting value for the low offset. The value is shown in the top
left frame of  the plot (with a dotted line).  The default value is
the offset value from the main widget.


Sky Offset High
^^^^^^^^^^^^^^^

:file:`sky_subtract_event.pro`

The cutting  value for the high  offset. The value is  shown in the
top left frame of the plot  (with a dotted line). The default value
is the offset value from the main widget.


Sky Shift
^^^^^^^^^
:file:`sky_apply_lin_cut.pro`

The time shift  in the sky observation before  subtracting from the
object. The extremes  are set to -25 and +25, and  can of course be
changed  (in sky_subtract_display.pro).  The shifting  takes places
after  the offset correction  has been  performed. The  time points
left blank are set to zero.


Do Sky Subtraction 
^^^^^^^^^^^^^^^^^^^

:file:`sky_subtract_event.pro`  switch  :code:`sky_subtract_apply`

Apply the sky subtraction to the data.


Undo Sky Subtraction
^^^^^^^^^^^^^^^^^^^^ 

:file:`sky_subtract_event.pro`  switch  :code:`sky_subtract_apply`

Undo the sky subtraction.


Dismiss
^^^^^^^

Dismiss the Sky Subtraction Tool.

