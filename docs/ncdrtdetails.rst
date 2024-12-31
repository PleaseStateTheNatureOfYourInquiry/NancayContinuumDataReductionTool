
.. _ncdrtdetails:


Some details working with NCDRT
================================

The source files are all human readable files. All the programmes are
.pro files. The .CB files  are the Common Blocks.  The ncdrt_v1.0.pro
file contains the  first version of NCDRT, which  is quite primitive.
NCDRT uses the READFITS.PRO routine from the IDL astro routines. 
This routine was found at the time of development of this application at URL *idlastro.gsfc.nasa.gov/homepage.html*, 
which does not exist anymore.
A search gives this `IDL Astro GitHub repository <https://github.com/wlandsman/IDLAstro/tree/master>`_.

The (old) routine is included in this distribution of NCDRT.


SHOW_LIN_CUT and APPLY_LIN_CUT
------------------------------

A NRT drift scan is a measure  of the flux as a function of time. The
first three seconds  of the scan are used  to observe the calibration
noise tube.  NCDRT ignores these  first three items.  The rest of the
scan sees the  system noise and the source, as  it drifts through the
field of view  of the system. In order to  measure the source's flux,
the  system noise needs  to be  subtracted. It  is assumed  that this
noise, the offset, is a line as a function of time.

The offset :ref:`sliders <sliders>` determine which part of the scan
is  used for  the  offset line  determination.  This is  from :code:`t=1`  to
:code:`t=offset_low` plus :code:`t=offset_high` to  :code:`t=end_scan`. The offset limits are
defined  and  the  same  for  all  the channels.  The  line  is  then
subtracted from the whole scan.  Now the peak value of the object can
be measured.

The offset sliders determine the part  of the data to be used for the
determination  of the offset.   There is  a build-in  protection that
prevents  these sliders  from having  inappropriate values:  the peak
sliders  must  be at  least  4 time  units  apart  for the  curve_fit
procedure  in the  :file:`apply_lin_cut.pro`  routine to  work,  and the  low
offset  slider cannot  be larger  than the  high offset  slider.  low
sliders cannot be  set to more than half the  range, Also, the offset
sliders cannot  be set  to 0 or  to the  maximum of points.   This is
checked  in  the   :file:`show_lin_cut.pro`  routine.   The  :file:`show_lin_cut.pro`
routine then plots the first channel (by default, this can be changed
by  the  user), corrected  by  the offset,  in  a  small plot  window
(scissors) and shows the offset lines.

The peak  sliders determine which part of  the scan is to  be used to
fit the peak of the object. This is also plotted in the scissors-plot
by :file:`show_lin_cut.pro`.

The  routine  :file:`apply_lin_cut.pro`  fits  a  gaussian  function  to  the
selected  peak.   It  uses  the  IDL routine  GAUSSFIT  with  initial
estimates of the four parameters :math:`a(0), a(1), a(2), a(3)`:

.. math::

    f(x) = a (0) * \exp { \frac {-z^2}{2} } + a (3)

with   

.. math::

    z = \frac{ x- a (1) }{ a (2) }

The results  are shown in  the result plot  window and in  the result
text box in  the right hand colomn of the NCDRT  widget.  The flux at
the peak is 

.. math::

    a (0) + a (3)


Three estimates of the noise level are calculated and reported:

(1) standard deviation  of the (peak  - gaussian fit) for  the peak selection of the scan only;

(2) standard deviation  of the (scan - offset_line)  for the offset selection of the scan only;

(3) standard deviation of the combination of (1) and (2).

