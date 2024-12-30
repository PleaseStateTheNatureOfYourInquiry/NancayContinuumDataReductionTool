
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro LOAD_OBS--------------------------------------------------------
;----------date: 23 - 07 - 2004------------------------------------------------


      PRO LOAD_OBS

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LOAD_OBS.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


;----------Start LOAD_OBS------------------------------------------------------

       If n_scan_processed EQ 0 Then channel_files = STRARR(8)


;---------Read a new observation-----------------------------------------------

       If next_obs EQ 0 Then Begin

        file_base = $
         DIALOG_PICKFILE(/READ,FILTER='*_f1.fits',GET_PATH=data_path)

        If file_base EQ '' Then Begin

         message = 'No file selected'
         Widget_control , process_info , Set_value = message
         Goto, r100
        
        Endif

        cd,data_path
        READ_LIST


;---------Read a previous or a next observation--------------------------------

       Endif Else Begin


;---------Impossible to find a better trick...all the IDL functions that work--
;---------with strings do not give the desired result, so...this is the stupid-
;---------but straight forward way around the problem--------------------------

        dump = STRPOS(channel_files(0),'f0')
        match_channel = STRMID(channel_files(0),dump,7)

        i_file = -1
        For i = 0,n_obs-1 Do Begin

         dump = STRPOS(file_list(i),'f0')
         match_list = STRMID(file_list(i),dump,7)

         If (match_list EQ match_channel) Then i_file = i

        Endfor

        If (i_file EQ n_obs-1 AND next_obs EQ 1) OR $
           (i_file EQ 0 AND next_obs EQ -1) Then Begin

         file_base = $
          DIALOG_PICKFILE(/READ,FILTER='*_f1.fits',GET_PATH=data_path)

         If file_base EQ '' Then Begin

          message = 'No file selected'
          Widget_control , process_info , Set_value = message
          Goto, r100
        
         Endif

         cd,data_path
         READ_LIST
         Goto,r2

        Endif Else Begin

         If next_obs EQ 1 Then i_file = i_file + 1
         If next_obs EQ -1 Then i_file = i_file - 1

         file_base = file_list(i_file)

        Endelse

       Endelse

 r2:   n_scan_processed = n_scan_processed + 1
       If n_scan_processed GT 1 Then n_points_before = n_points

       dump = STRPOS(file_base,'f0')
       scan_number = STRMID(file_base,dump,7)


;----------Read the data of the 8 channels-------------------------------------

       channel_files(0) =  data_path + scan_number + '_f1.fits'
       channel_files(1) =  data_path + scan_number + '_f2.fits'
       channel_files(2) =  data_path + scan_number + '_f3.fits'
       channel_files(3) =  data_path + scan_number + '_f4.fits'
       channel_files(4) =  data_path + scan_number + '_f5.fits'
       channel_files(5) =  data_path + scan_number + '_f6.fits'
       channel_files(6) =  data_path + scan_number + '_f7.fits'
       channel_files(7) =  data_path + scan_number + '_f8.fits'

       channel_dump = READFITS(channel_files(0),/SILENT,header)


;---------Identify the object, the central frequency and the mid time of the---
;---------observation from the information in the 'pou' file-------------------

       pou_file = 'pou' + STRMID(file_base,dump+1,6) + '.213'

       dump = STRING(1)
       object = STRING(20)
       time_start = FLTARR(6) & time_end = time_start

       Get_lun , file_unit
    
       Openr , file_unit , pou_file
       Readf , file_unit , dump
       Readf , file_unit , dump
       Readf , file_unit , Format='(28x,A35)' , object
       Readf , file_unit , Format='(44x,F6.1)' , central_freq

 r240: Readf , file_unit , dump   
       If STRMID(dump,10,5) EQ  'Duree' Then Goto, r250
       Goto, r240       

 r250: Readf , file_unit , Format = '(32x,6(1x,I2))' , $
        day_start , month_start , year_start , $
        hour_start , minute_start , second_start
  
       year_start = year_start + 2000 
       time_start = [year_start,month_start,day_start,hour_start,minute_start,second_start]

       Readf , file_unit , dump

       Readf , file_unit , Format = '(32x,6(1x,I2))' , $
        day_end , month_end , year_end , $
        hour_end , minute_end , second_end

       year_end = year_end + 2000 
       time_end = [year_end,month_end,day_end,hour_end,minute_end,second_end]

       Close , file_unit

       Free_lun ,file_unit


       JULDATE,time_start,julian_start
       JULDATE,time_end,julian_end

       julian_obs = (julian_start + julian_end) / 2.

;       julian_obs = 2400000. + (julian_start + julian_end) / 2.


;---------Read the data from all 8 channels------------------------------------

       channel_dump = REFORM(channel_dump)
       dim_channel = SIZE(channel_dump)

       n_points = dim_channel(1)

       If n_scan_processed EQ 1 Then n_points_before = n_points

       channel_data = FLTARR(16,n_points-3)

       channel_data(0,*) = channel_dump(3:n_points-1)

       For i = 1,7 Do Begin

        channel_dump = READFITS(channel_files(i),/SILENT)
        channel_dump = REFORM(channel_dump)
        channel_data(i,*) = channel_dump(3:n_points-1)

       Endfor


;---------USER: AVERAGING------------------------------------------------------
;---------Take the average for channels 1+3, 2+4, 5+7 and 6+8 and store them---
;---------in channel_data(8,*), (9,*), (10,*) and (11,*)-----------------------
;---------Take the average for channels 1 to 4, 5 to 8, and 1 to 8, and store--
;---------them in channel_data(12,*), (13,*) and (14,*)------------------------

;---------This can be changed to whatever combination is desired---------------

       channel_data(8,*) = ( channel_data(0,*) + channel_data(2,*) ) / 2
       channel_data(9,*) = ( channel_data(1,*) + channel_data(3,*) ) / 2
       channel_data(10,*) = ( channel_data(4,*) + channel_data(6,*) ) / 2
       channel_data(11,*) = ( channel_data(5,*) + channel_data(7,*) ) / 2

       channel_data(12,*) = $
        ( channel_data(0,*) + channel_data(1,*) + $
          channel_data(2,*) + channel_data(3,*) ) /4

       channel_data(13,*) = $
        ( channel_data(4,*) + channel_data(5,*) + $
          channel_data(6,*) + channel_data(7,*) ) /4

       channel_data(14,*) = $
        ( channel_data(0,*) + channel_data(1,*) + $
          channel_data(2,*) + channel_data(3,*) + $
          channel_data(4,*) + channel_data(5,*) + $
          channel_data(6,*) + channel_data(7,*) ) /8

       channel_data(15,*) = -1.


;----------Keep a copy of the current data-------------------------------------

       channel_data_ori = channel_data


;----------Information about current observation for the information widget----

       info = scan_number + ', no. of points: ' + $
        STRCOMPRESS(STRING(n_points))
 
       start_info = 'start obs.: ' + $
                    STRCOMPRESS(STRING(FIX(day_start))) + $
                    STRCOMPRESS(STRING(FIX(month_start))) + $
                    STRCOMPRESS(STRING(FIX(year_start))) + ' at ' + $
                    STRCOMPRESS(STRING(FIX(hour_start))) + 'h:' + $
                    STRCOMPRESS(STRING(FIX(minute_start))) + 'm:' + $
                    STRCOMPRESS(STRING(FIX(second_start))) + 's'

       end_info = 'end obs.  : ' + $
                  STRCOMPRESS(STRING(FIX(day_end))) + $
                  STRCOMPRESS(STRING(FIX(month_end))) + $
                  STRCOMPRESS(STRING(FIX(year_end))) + ' at ' + $
                  STRCOMPRESS(STRING(FIX(hour_end))) + 'h:' + $
                  STRCOMPRESS(STRING(FIX(minute_end))) + 'm:' + $
                  STRCOMPRESS(STRING(FIX(second_end))) + 's'
                   

       julian_info = 'Julian date (mid obs.): ' + $
                     STRCOMPRESS(STRING(julian_obs))

       freq_info = 'Central Frequency = ' + $
                   STRCOMPRESS(STRING(central_freq)) + ' MHz'


       file_information = $
        [object,start_info,end_info,julian_info,freq_info,info]


;----------Write information in the file_info part of the main widget----------

       Widget_control , file_info , Set_value = file_information


;----------Reset the calibration factors and the calibration_applied switch at-
;----------this point----------------------------------------------------------

       apply_factors(*) = 1.0
       apply_factors_error(*) = 0.0

       calibration_applied = 0

       If cal_tool_active EQ 1 Then $
        Widget_control, cal_process_info , Set_value = ''
        

;----------Reset the comment text----------------------------------------------

       read_comment = 'No comment'


;----------Check if a result file (either .res, .res_av, .res_cal or ----------
;---------- .res_av_cal) already exists----------------------------------------

       res_check = scan_number + '.res'

       Get_lun , check_lun
       Openr , check_lun , res_check , error = res_not_exist
       Close , check_lun
       Free_lun , check_lun


       res_av_check = scan_number + '.res_av'

       Get_lun , check_lun
       Openr , check_lun , res_av_check , error = res_av_not_exist
       Close , check_lun
       Free_lun , check_lun


       res_cal_check = scan_number + '.res_cal'

       Get_lun , check_lun
       Openr , check_lun , res_cal_check , error = res_cal_not_exist
       Close , check_lun
       Free_lun , check_lun


       res_av_cal_check = scan_number + '.res_av_cal'

       Get_lun , check_lun
       Openr , check_lun , res_av_cal_check , error = res_av_cal_not_exist
       Close , check_lun
       Free_lun , check_lun


;---------If one of these files exist, read the settings and apply to the------
;---------current data. No calibration is applied, even if it exists-----------
 
;---------No averaging and .res_cal exists-------------------------------------

       If (ch_address EQ 0 AND res_cal_not_exist EQ 0) Then Begin 

        READ_RES , res_cal_check
        message = '.res_cal file exists. Use settings.'
        Goto, r200

       Endif


;---------No averaging and .res exists-----------------------------------------

       If (ch_address EQ 0 AND res_not_exist EQ 0) Then Begin 

        READ_RES , res_check
        message = '.res file exists. Use settings.'
        Goto, r200

       Endif


;---------No averaging and .res_av_cal exists----------------------------------

       If (ch_address EQ 0 AND res_av_cal_not_exist EQ 0) Then Begin 

        READ_RES_AV , res_av_cal_check
        message = '.res_av_cal file exists. Use settings.'
        channel_include = ' 1 1 1 1 1 1 1 1'
        Goto, r200

       Endif


;---------No averaging and .res_av exists--------------------------------------

       If (ch_address EQ 0 AND res_av_not_exist EQ 0) Then Begin 

        READ_RES_AV , res_av_check
        message = '.res_av file exists. Use settings.'
        channel_include = ' 1 1 1 1 1 1 1 1'
        Goto, r200

       Endif


;---------Averaging and .res_av_cal exists-------------------------------------

       If (ch_address EQ 8 AND res_av_cal_not_exist EQ 0) Then Begin 

        READ_RES_AV , res_av_cal_check
        message = '.res_av_cal file exists. Use settings.'
        Goto, r200

       Endif


;---------Averaging and .res_av exists-----------------------------------------

       If (ch_address EQ 8 AND res_av_not_exist EQ 0) Then Begin 

        READ_RES_AV , res_av_check
        message = '.res_av file exists. Use settings.'
        Goto, r200

       Endif


;---------Averaging and .res_cal exists----------------------------------------

       If (ch_address EQ 8 AND res_cal_not_exist EQ 0) Then Begin 

        READ_RES , res_cal_check
        message = '.res_cal file exists. Use settings.'
        channel_include = ' 1 1 1 1 1 1 1 0'
        Goto, r200

       Endif


;---------Averaging and .res exists--------------------------------------------

       If (ch_address EQ 8 AND res_not_exist EQ 0) Then Begin 

        READ_RES , res_check
        message = '.res file exists. Use settings.'
        channel_include = ' 1 1 1 1 1 1 1 0'
        Goto, r200

       Endif



       message = 'No previous result file exists.'

       If ch_address EQ 0 Then Begin

        channel_include = ' 1 1 1 1 1 1 1 1'

       Endif Else Begin 

        channel_include = ' 1 1 1 1 1 1 1 0'

       Endelse


 r200:
       average_done = 0

       Widget_control , process_info , Set_value = message
       Widget_control , comment_string , Set_value = read_comment
       Widget_control , channel_select , Set_value = channel_include


;----------Set the offset and peak cut boundaries to a default value if this---
;----------is the first scan or if the number of points changed----------------

       If (n_scan_processed EQ 1 OR n_points NE n_points_before) $
          AND (res_not_exist NE 0) AND (res_av_not_exist NE 0) $
          AND (res_cal_not_exist NE 0) AND (res_av_cal_not_exist NE 0) $
          Then Begin

        t_offset_low = FIX(n_points / 4)
        t_peak_low = t_offset_low
        t_offset_high = FIX(3 * n_points / 4)
        t_peak_high = t_offset_high

       Endif

       Widget_control , slider_offset_low , Set_value = t_offset_low
       Widget_control , slider_offset_high , Set_value = t_offset_high
       Widget_control , slider_peak_low , Set_value = t_peak_low
       Widget_control , slider_peak_high , Set_value = t_peak_high


 r100:
      End

;----------Pro LOAD_OBS--------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------


