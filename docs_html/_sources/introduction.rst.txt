

.. _introduction:

Introduction
============



Installing and adapting NCDRT to your system
--------------------------------------------


NCDRT uses  IDL 5.4  or higher.  Untar  the :file:`NCDRT_V2.1.tar` file  to a
directory      of      your      choice,     for      example      in
:file:`/home/your_name/idlproc/NCDRT/`.  Also include  the following  line in
your :file:`.cshrc` file:

.. code-block::

    setenv IDL_PATH /home/your_name/idlproc/NCDRT:${IDL_PATH}


This will make IDL search this directory for programme files.

Some routines in NCDRT use  the :code:`/bin/rm` and :code:`/bin/cp` command to remove
and copy temporary files. On some computer systems these commands are
located in the :file:`/sbin` or other directories.  Please check the location
of these executables before you run NCDRT. If necessary make changes
in the following routines:

| :file:`delete_from_cal_table.pro`
| :file:`read_list.pro`
| :file:`write_2_cal_table.pro`

look for the  :code:`USER: RM and CP commands`  keyword in these files.

The routine  :file:`read_list.pro`  uses the command :code:`/bin/ls`. Look for the 
'USER: LS command' keyword in this file if a change is required.


