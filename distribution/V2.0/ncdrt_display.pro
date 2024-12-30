
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro NCDRT_DISPLAY---------------------------------------------------
;----------date: 23 - 07 - 2004------------------------------------------------


      Pro NCDRT_DISPLAY

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LONGITUDE.CB
       @WIDGET_IDS.CB


;----------Create the base of NCDRT--------------------------------------------

       base = Widget_base(title='Nancay CDR Tool (V2.0)'$
                          , column=2)



;----------Load new observation button-----------------------------------------

       load_obs = Widget_button(base, value='Load Data File' , $
                                      uvalue = 'LOADOBS')


;----------Switch between normal and detailed scissor mode---------------------

       scissor_switch = Widget_button(base, value='Scissor Switch' , $
                                      uvalue = 'SCISSORSWITCH')

;----------Load next observation button----------------------------------------

       next_obs = Widget_button(base, value='Load Next Data File' , $
                                      uvalue = 'NEXTOBS')


;----------Load previous observation button------------------------------------

       previous_obs = Widget_button(base, value='Load Previous Data File' , $
                                      uvalue = 'PREVIOUSOBS')


;----------Averaging on or off-------------------------------------------------

       averaging_switch = Widget_button(base , $
        value='Averaging Switch' , uvalue = 'AVERAGINGSWITCH')


;----------Information about the current observation---------------------------

       file_info = Widget_text(base , xsize=40 , ysize=6)



;----------Messages------------------------------------------------------------

       process_info = Widget_text(base , xsize=40 , ysize=2)



;----------Calibration tool button---------------------------------------------

       calibration_tool = Widget_button(base , $
        value='NCDRT Calibration Tool' , uvalue = 'CALIBRATIONTOOL')


;---------Create .ps of the current result-------------------------------------

       write_result_2_ps = Widget_button(base , $
        value='Create .ps Of Result (Standard)' , uvalue = 'WRITERESULT2PS')


;---------Create .ps of the current result-------------------------------------

       write_result_2_ps_name = Widget_button(base , $
        value='Create .ps Of Result (Choose Name)' , $
        uvalue = 'WRITERESULT2PSNAME')


;---------Short cut to apply calibration---------------------------------------

       apply_calibration_short_cut = Widget_button(base , $
        value='Apply Calibration (Short Cut)' , $
        uvalue = 'APPLYCALIBRATIONSHORTCUT')


;----------Comment string to write to the result file--------------------------

       comment_string = Widget_text(base , xsize=40 , /Editable , $
                                    uvalue='COMMENTSTRING')


;----------save button---------------------------------------------------------

       save_res = Widget_button(base, value='Save Result' , $
                                      uvalue = 'SAVERES')


;----------The cutting sliders-------------------------------------------------

       slider_offset_low = Widget_slider(base, minimum = 0, maximum = 119 , $
        title = 'Offset Low' , uvalue = 'SLIDERCUTLOW', scroll = 1)

       slider_offset_high = Widget_slider(base, minimum = 0, maximum = 119 , $
        title = 'Offset High' , uvalue = 'SLIDERCUTHIGH', scroll = 1)

       slider_peak_low = Widget_slider(base, minimum = 0, maximum = 119 , $
        title = 'Peak Low' , uvalue = 'SLIDERPEAKLOW', scroll = 1)

       slider_peak_high = Widget_slider(base, minimum = 0, maximum = 119 , $
        title = 'Peak High' , uvalue = 'SLIDERPEAKHIGH', scroll = 1)


;----------Print the results with the current selection for the cut values-----

       current_res = Widget_text(base , xsize=50 , ysize=11, $
                                 uvalue='CURRENTRES')


;----------Select the channels to be saved to file-----------------------------

       channel_select = Widget_text(base , xsize=40 , /Editable , $
                                    uvalue='CHANNELSELECT')


;----------The QUIT button-----------------------------------------------------

       button = Widget_button(base , value='Quit' , uvalue = 'QUIT')


;---------Realize the widgets--------------------------------------------------

       Widget_control , base , /realize


;---------Set the number of scans processed in current session to zero---------
;---------(defined in CHANNEL.CB)----------------------------------------------

       n_scan_processed = 0


;---------Initial setting for no averaging-------------------------------------

       n_channel = 8
       ch_address = 0


;---------Scissor set to normal mode-------------------------------------------

       scissor = 0


;---------USER: AVERAGING------------------------------------------------------
;--------define the names of the channels--------------------------------------

       channel_print = STRARR(16)
       channel_print(0) = 'Channel 1:  ' & channel_print(1) = 'Channel 2:  '
       channel_print(2) = 'Channel 3:  ' & channel_print(3) = 'Channel 4:  '
       channel_print(4) = 'Channel 5:  ' & channel_print(5) = 'Channel 6:  '
       channel_print(6) = 'Channel 7:  ' & channel_print(7) = 'Channel 8:  '
       channel_print(8) = 'Channel 1+3:' & channel_print(9) = 'Channel 2+4:'
       channel_print(10) = 'Channel 5+7:' & channel_print(11) = 'Channel 6+8:'
       channel_print(12) = 'Channel 1-4:' & channel_print(13) = 'Channel 5-8:'
       channel_print(14) = 'Channel 1-8:' & channel_print(15) = ' '


;----------Initialisation of the calibration parameters------------------------

       n_cal_points = 0
       cal_table = ''
       cal_tool_active = 0
       calibration_applied = 0
       apply_factors = FLTARR(16)
       apply_factors(*) = 1.0
       apply_factors_error = FLTARR(16)
       apply_factors_error(*) = 0.0


;----------Check if the ~/idlproc/NCDRT/planet/planet.longitude file exists----
;----------If yes, then read it.-----------------------------------------------

       Get_lun , file_unit

       Openr , file_unit , $
        '~/idlproc/NCDRT/planet/planet.longitude' , error = Err

       Close , file_unit


;----------planet.longitude file does not exist--------------------------------

       If Err NE 0 Then Begin

        planet_longitude = 0
        message = 'No planet.longitude file found.'
        Widget_control , process_info , Set_value = message
        Goto, r100

       Endif


;----------planet.longitude file does exist------------------------------------

       planet_longitude = 1

       message = 'planet.longitude file found and read.'
       Widget_control , process_info , Set_value = message


;----------Determine the number of data in the file----------------------------

       Get_lun , file_unit
       Openr , file_unit , '~/idlproc/NCDRT/planet/planet.longitude'

;---------Read the seven comment lines first-----------------------------------

       dump = STRARR(1)

       For i = 1,7 Do Begin & Readf , file_unit , dump & Endfor

       n_longitude = 0L
         
 r2:   Readf , file_unit , dump
       n_longitude = n_longitude + 1
       If NOT EOF(file_unit) Then Goto, r2

       Close , file_unit
       Free_lun , file_unit


;----------Read the file names-------------------------------------------------

       scan_list = STRARR(n_longitude)
       scan_longitude = FLTARR(n_longitude)
       scan_sublatitude = FLTARR(n_longitude)
       scan_distance = FLTARR(n_longitude)

       Get_lun , file_unit
       Openr , file_unit , '~/idlproc/NCDRT/planet/planet.longitude'


;---------Read the seven comment lines first-----------------------------------

       For i = 1,7 Do Begin & Readf , file_unit , dump & Endfor
       

;---------Read the data into the vectors---------------------------------------

       For i = 0 , n_longitude-1 Do Begin
         
        Readf , file_unit , Format='(A7,2x,F7.2,1x,F6.2,1x,F8.5)' , dump , $
         longitude_in , sublatitude_in , distance_in
        scan_list(i) = dump(0)
        scan_longitude(i) = longitude_in
        scan_sublatitude(i) = sublatitude_in
        scan_distance(i) = distance_in

       Endfor

       Close , file_unit
       Free_lun , file_unit


;----------The Xmanager takes control of the widgets---------------------------

 r100:

       Xmanager, 'NCDRT_DISPLAY', base , /NO_BLOCK

      End

;----------Pro NCDRT_DISPLAY---------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------



;       apply_lin_cut = Widget_button(base, value='Apply Linear Cut' , $
;                                    uvalue = 'APPLYLINCUT')


