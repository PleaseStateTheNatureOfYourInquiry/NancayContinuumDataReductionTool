
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------Pro SKY_LOAD_OBS----------------------------------------------------
;----------date: 16 - 08 - 2004------------------------------------------------


      PRO SKY_LOAD_OBS

;----------The common blocks used in this procedure----------------------------

       @CHANNEL.CB
       @CUT_SETTING.CB
       @SKY_CHANNEL.CB
       @SKY_CUT_SETTING.CB
       @SKY_LOAD_OBS.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_SKY.CB


;----------Start SKY_LOAD_OBS--------------------------------------------------

;----------Read a sky observation----------------------------------------------

       sky_channel_files = STRARR(8)

       sky_file_base = $
        DIALOG_PICKFILE(/READ,FILTER='*_f1.fits',GET_PATH=sky_data_path)

       If sky_file_base EQ '' Then Begin

        message = 'No sky file selected'
        Widget_control , sky_process_info , Set_value = message
        Goto, r100
        
       Endif

       dump = STRPOS(sky_file_base,'f0')
       sky_scan_number = STRMID(sky_file_base,dump,7)


;----------Read the sky data of the 8 channels---------------------------------

       sky_channel_files(0) =  sky_data_path + sky_scan_number + '_f1.fits'
       sky_channel_files(1) =  sky_data_path + sky_scan_number + '_f2.fits'
       sky_channel_files(2) =  sky_data_path + sky_scan_number + '_f3.fits'
       sky_channel_files(3) =  sky_data_path + sky_scan_number + '_f4.fits'
       sky_channel_files(4) =  sky_data_path + sky_scan_number + '_f5.fits'
       sky_channel_files(5) =  sky_data_path + sky_scan_number + '_f6.fits'
       sky_channel_files(6) =  sky_data_path + sky_scan_number + '_f7.fits'
       sky_channel_files(7) =  sky_data_path + sky_scan_number + '_f8.fits'

       sky_channel_dump = READFITS(sky_channel_files(0),/SILENT,header)


;---------Identify the object, the central frequency and the mid time of the---
;---------observation from the information in the 'pou' file-------------------

       pou_file = $
        sky_data_path + 'pou' + STRMID(sky_file_base,dump+1,6) + '.213'

       dump = STRING(1)
       sky_object = STRING(35)
       sky_time_start = FLTARR(6) & sky_time_end = sky_time_start

       Get_lun , file_unit
    
       Openr , file_unit , pou_file
       Readf , file_unit , dump
       Readf , file_unit , dump
       Readf , file_unit , Format='(28x,A35)' , sky_object
       Readf , file_unit , Format='(44x,F6.1)' , sky_central_freq

 r240: Readf , file_unit , dump   
       If STRMID(dump,10,5) EQ  'Duree' Then Goto, r250
       Goto, r240       

 r250: Readf , file_unit , Format = '(32x,6(1x,I2))' , $
        day_start , month_start , year_start , $
        hour_start , minute_start , second_start
  
       year_start = year_start + 2000 
       sky_time_start = $
        [year_start,month_start,day_start,hour_start,minute_start,second_start]

       Readf , file_unit , dump

       Readf , file_unit , Format = '(32x,6(1x,I2))' , $
        day_end , month_end , year_end , $
        hour_end , minute_end , second_end

       year_end = year_end + 2000 
       sky_time_end = $
        [year_end,month_end,day_end,hour_end,minute_end,second_end]

       Close , file_unit

       Free_lun ,file_unit


       JULDATE,sky_time_start,sky_julian_start
       JULDATE,sky_time_end,sky_julian_end

       sky_julian_obs = (sky_julian_start + sky_julian_end) / 2.


;---------Read the data from all 8 channels------------------------------------

       sky_channel_dump = REFORM(sky_channel_dump)
       sky_dim_channel = SIZE(sky_channel_dump)

       If sky_dim_channel(1) NE n_points Then Begin

        sky_file_base = ''
        message = $
         ['Sky and observation must have same number of points. Select other sky file.']
        Widget_control , sky_process_info , Set_value = message
        Goto, r100
        
       Endif

       sky_channel_data = FLTARR(16,n_points-3)

       sky_channel_data(0,*) = sky_channel_dump(3:n_points-1)

       For i = 1,7 Do Begin

        sky_channel_dump = READFITS(sky_channel_files(i),/SILENT)
        sky_channel_dump = REFORM(sky_channel_dump)
        sky_channel_data(i,*) = sky_channel_dump(3:n_points-1)

       Endfor


;---------USER: AVERAGING------------------------------------------------------
;---------Take the average for channels 1+3, 2+4, 5+7 and 6+8 and store them---
;---------in sky_channel_data(8,*), (9,*), (10,*) and (11,*)-------------------
;---------Take the average for channels 1 to 4, 5 to 8, and 1 to 8, and store--
;---------them in sky_channel_data(12,*), (13,*) and (14,*)--------------------

;---------This can be changed to whatever combination is desired---------------

       sky_channel_data(8,*) = $
        ( sky_channel_data(0,*) + sky_channel_data(2,*) ) / 2
       sky_channel_data(9,*) = $
        ( sky_channel_data(1,*) + sky_channel_data(3,*) ) / 2
       sky_channel_data(10,*) = $
        ( sky_channel_data(4,*) + sky_channel_data(6,*) ) / 2
       sky_channel_data(11,*) = $
        ( sky_channel_data(5,*) + sky_channel_data(7,*) ) / 2

       sky_channel_data(12,*) = $
        ( sky_channel_data(0,*) + sky_channel_data(1,*) + $
          sky_channel_data(2,*) + sky_channel_data(3,*) ) /4

       sky_channel_data(13,*) = $
        ( sky_channel_data(4,*) + sky_channel_data(5,*) + $
          sky_channel_data(6,*) + sky_channel_data(7,*) ) /4

       sky_channel_data(14,*) = $
        ( sky_channel_data(0,*) + sky_channel_data(1,*) + $
          sky_channel_data(2,*) + sky_channel_data(3,*) + $
          sky_channel_data(4,*) + sky_channel_data(5,*) + $
          sky_channel_data(6,*) + sky_channel_data(7,*) ) /8

       sky_channel_data(15,*) = -1.


;----------Keep a copy of the current data-------------------------------------

       sky_channel_data_ori = sky_channel_data


;----------Information about current sky observation for the information widget

       info = sky_scan_number + ', no. of points: ' + $
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
                     STRCOMPRESS(STRING(sky_julian_obs))

       freq_info = 'Central Frequency = ' + $
                   STRCOMPRESS(STRING(sky_central_freq)) + ' MHz'


       file_information = $
        [sky_object,start_info,end_info,julian_info,freq_info,info]


;----------Write information in the file_info part of the main widget----------

       Widget_control , sky_file_info , Set_value = file_information


;----------Set the offset cut boundaries to a default value--------------------

;       sky_t_offset_low = FIX((n_points-3-1)/2)
;       sky_t_offset_high = FIX((n_points-3-1)/2) + 1

       If sky_t_offset_low_res EQ 0 Then Begin

        sky_t_offset_low = t_offset_low
        sky_t_offset_high = t_offset_high
        main_slider_track = 1

        message = ['Main offset sliders are tracked',$
        'Use Main Slider Track Switch for independend offset control']
        Widget_control , sky_process_info , Set_value = message

       Endif Else Begin

        sky_t_offset_low = t_offset_low
        sky_t_offset_high = t_offset_high
        main_slider_track = 1

        message_1 = $
         'Previous result file contained following slider settings: ' + $
         STRCOMPRESS(STRING(sky_t_offset_low_res)) + ' , ' + $
         STRCOMPRESS(STRING(sky_t_offset_high_res)) + ' , ' + $
         STRCOMPRESS(STRING(sky_shift))

        message_2 = sky_file_previous(0)
        message = [message_1,message_2]

        Widget_control , sky_process_info , Set_value = message

       Endelse

       Widget_control , sky_slider_offset_low , Set_value = sky_t_offset_low
       Widget_control , sky_slider_offset_high , Set_value = sky_t_offset_high

       sky_shift = 0
       Widget_control , sky_slider_shift , Set_value = sky_shift


 r100:
      End


;----------Pro SKY_LOAD_OBS----------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------END-----------------------------------------------------------------


