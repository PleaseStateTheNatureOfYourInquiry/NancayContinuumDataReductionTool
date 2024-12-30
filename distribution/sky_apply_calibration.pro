
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------Pro SKY_APPLY_CALIBRATION-------------------------------------------
;----------date: 16 - 08 - 2004------------------------------------------------


      PRO SKY_APPLY_CALIBRATION

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @SKY_CALIBRATION.CB
       @SKY_CHANNEL.CB


;----------Start SKY_APPLY_CALIBRATION-----------------------------------------

       cal_time = calibration_time

       For i = 0,14 Do Begin

        cal_time(*) = 0.

        cal_factors = calibration_factors(*,i)

        cal_factors_valid = WHERE(cal_factors GE 0,count_valid)

        If count_valid LE 0 Then Begin

         sky_apply_factors(i) = 1.
         sky_apply_factors_error(i) = 0.
         Goto, r10

        Endif

        cal_time(cal_factors_valid) = calibration_time(cal_factors_valid)

        dtime = ABS(cal_time - sky_julian_obs)

        time_id = WHERE(dtime EQ MIN(dtime))

        sky_apply_factors(i) = calibration_factors(time_id,i)
        sky_apply_factors_error(i) = calibration_factors_error(time_id,i)

  r10:
       Endfor


      End

;----------Pro SKY_APPLY_CALIBRATION-------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------END-----------------------------------------------------------------
