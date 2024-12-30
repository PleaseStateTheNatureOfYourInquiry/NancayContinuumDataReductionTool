
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------Pro READ_LIST-------------------------------------------------------
;----------date: 19 - 07 - 2004------------------------------------------------


      PRO READ_LIST

;----------The common blocks used in this procedure----------------------------

       @LOAD_OBS.CB


;----------Start READ_LIST-----------------------------------------------------


;----------Create the listing of the fit files in the current directory--------
;----------USER: LS command----------------------------------------------------

       Spawn,'/bin/ls *f1.fits > ncdrt_f1.list'


;----------Determine the number of files in the list---------------------------

       Get_lun , file_unit

       Openr , file_unit , 'ncdrt_f1.list'

       dump = STRING(60)

       n_obs = 0L
         
 r2:   Readf , file_unit , dump
       n_obs = n_obs + 1
       If NOT EOF(file_unit) Then Goto, r2

       Close , file_unit

       Free_lun , file_unit


;----------Read the file names-------------------------------------------------

       file_list = STRARR(n_obs)

       Get_lun , file_unit

       Openr , file_unit , 'ncdrt_f1.list'

       For i = 0 , n_obs-1 Do Begin
         
        Readf , file_unit , dump
        file_list(i) = data_path + STRCOMPRESS(dump)

       Endfor

       Close , file_unit

       Free_lun , file_unit


;----------Detete the file listing---------------------------------------------
;----------USER: RM and CP commands--------------------------------------------

       Spawn,'/bin/rm ncdrt_f1.list'

      End


;----------Pro READ_LIST-------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------END-----------------------------------------------------------------
