pro makecurtain
input1='f0'
input3='f1Spin'

ModelInfo = ctm_type( 'GEOS5_47L', res = 2 )
GridInfo  = ctm_grid(ModelInfo)
ztop=12
; Find the index of the vertical gridbox nearest to the top of the
; domain, specified by ztop.
near_z = Min(abs(gridinfo.zmid-ztop),iztop)
zmid = GridInfo.zmid(0:iztop)

nlon=144
nlat=47
nlev=47
;
;dates=['20040701','20040702','20040703','20040704','20040705','20040706','20040707',$
;      '20040708','20040709','20040710','20040711','20040712','20040713','20040714',$
;      '20040715','20040716','20040717','20040718','20040719','20040720','20040721',$
;      '20040722','20040723','20040724','20040725','20040726','20040727','20040728',$
;      '20040728','20040729','20040730']
dates=['20040701','20040702','20040703','20040704','20040705','20040706','20040707','20040708','20040709']
tracers=[ 1, 2, 3, 4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]

tracername=['NOx','Ox','PAN','CO','ALK4','ISOP','HNO3','H2O2','ACET','MEK','ALD2','RCHO','MVK','MACR',$
            'PMN','PPN','R4N2','PRPE','C3H8','CH2O','C2H6','N2O5','HNO4','MP','DMS']
;DiagN=

dir='/as/scratch/2011-04/jmao/ts_compare/'
for idate=0,n_elements(dates)-1  do begin
infile1=dir+'ts'+strtrim(string(dates(idate)),2)+'.'+input3+'.bpch'

tmp=fltarr(nlon,nlat,nlev,24)&tmp(*,*,*)=!values.f_NaN
O3a=fltarr(nlon,nlat,nlev,24)&O3a(*,*,*)=!values.f_NaN

ctm_diaginfo,/all,/force_reading,filename=dir+'diaginfo.dat'
ctm_tracerinfo,/all,/force_reading, filename=dir+'tracerinfo.dat'


 CTM_Get_Data, DataInfo1,File=InFile1,'IJ-AVG-$',tracer=tracernumber
;CTM_Get_Data, DataInfo2,File=InFile1,'TIME-SER',tracer=2

  Tau0a = DataInfo1[*].Tau0
  Tau0a = Tau0a[Uniq( Tau0a, Sort( Tau0a ) ) ]
;  undefine,datainfo 
; get time in the format of YYYYMMDDHH
time1=lonarr(24)
for n_tau=0,n_elements(Tau0a)-1 do begin
  t=tau2yymmdd(Tau0a[n_tau],/nformat)&time1[n_tau]=t[1]/10000;time[n_tau]=t[0]*100+t[1]/10000
  ;end of the loop for Tau0
endfor


for j=0,n_elements(tracername)-1 do begin
;  CTM_Get_Data, DataInfo1,File=InFile1,'IJ-AVG-$'
  ; THISDATAINFO is an array of data blocks for time TAU0
  ;O3 is ppbv
  Ind = Where( DataInfo1[*].Tracername eq tracername(j) )
  for n=0,n_elements(Ind)-1 do begin
    i=Ind[n] 
    if Datainfo1[i].tau0 eq Tau0a[n] then begin
    tmp[*,*,*,n]=(*(DataInfo1[i].data))*1e-9&O3a[*,*,*,n]=tmp[*,*,*,n]
    endif else begin
    print,'problems in tau'&stop
    endelse
  endfor


  ;90w is -85, and index is 39? 35N is 16 (since I only output 45 to 91) 
  curtain1=O3a[39,16,0:iztop,*]*1e9

  timearray=[time1]
curtain=[transpose(reform(curtain1))]
s=tracername(j)+'=curtain'
result=execute(s)

;for tracers
endfor
save,NOx,Ox,PAN,CO,ALK4,ISOP,HNO3,H2O2,ACET,MEK,ALD2,RCHO,MVK,MACR,$
            PMN,PPN,R4N2,PRPE,C3H8,CH2O,C2H6,N2O5,HNO4,MP,DMS,$
     filename=input3+'.'+strtrim(string(dates(idate)),2)+'.sav'
undefine, DataInfo1
ctm_cleanup
;for dates
endfor

end

pro plotcurtain
speicename='Ox'
ModelInfo = ctm_type( 'GEOS5_47L', res = 2 )
GridInfo  = ctm_grid(ModelInfo)
ztop=12
; Find the index of the vertical gridbox nearest to the top of the
; domain, specified by ztop.
near_z = Min(abs(gridinfo.zmid-ztop),iztop)
zmid = GridInfo.zmid(0:iztop)

dates=['20040701','20040702','20040703','20040704','20040705','20040706','20040707',$
       '20040708','20040709','20040710','20040711','20040712','20040713','20040714',$
       '20040715','20040716','20040717','20040718','20040719','20040720','20040721',$
       '20040722','20040723','20040724','20040725','20040726','20040727']

;dates=['20040701','20040702','20040703','20040704','20040705','20040706','20040707']
input1='f0'

restore,input1+'.'+strtrim(string(dates(0)),2)+'.sav'
s= 'species='+ string(speicename)
result=execute(s)

for idate=1,n_elements(dates)-1 do begin
restore,input1+'.'+strtrim(string(dates(idate)),2)+'.sav'

s = 'tmp1=' + string(speicename)
result=execute(s)
species=[species,tmp1]
endfor
curtain1=species
input3='f1all'

restore,input3+'.'+strtrim(string(dates(0)),2)+'.sav'
s= 'species='+ string(speicename)
result=execute(s)

for idate=1,n_elements(dates)-1 do begin
restore,input3+'.'+strtrim(string(dates(idate)),2)+'.sav'

s = 'tmp1=' + string(speicename)
result=execute(s)
species=[species,tmp1]
endfor
curtain3=species

MyCt, /WhGrYlRd
window,1
tvcurtain_mao, curtain1, indgen(n_elements(dates)*24)+1, zmid, /ystyle, color = 1, $
           mindata=mmindata, maxdata=mmaxdata, ytitle=ytitle, nXtick=n_elements(dates)+1,title='f0=0',cbunit='ppb',$
           /CBar,/CBVertical,/NoAdvance,/NoZInterp

window,2
tvcurtain_mao, curtain3, indgen(n_elements(dates)*24)+1, zmid, /ystyle, color = 1, $
           mindata=mmindata, maxdata=mmaxdata, ytitle=ytitle, title='f0=1',cbunit='ppb',$
           /CBar,/CBVertical,/NoAdvance,/NoZInterp

  diff=curtain3-curtain1
  Max3 = max(abs(diff),/nan)
  Max3=1
  Min3 = - Max3
  MinData = Min3
  MaxData = Max3
   if ( N_Elements( DiffNColors ) eq 0 ) then DiffNColors = 12
   
   ; Use difference colortable w/ doubled midrange color for even
   ; DiffNColors. Tip 1: pass YELLOW=0 to have White in the middle,
   ; instead of yellow.
   ; Tip 2: replace 63 with 65 to get a smoother orange transition
   ; (need to modify MYCT to overwrite ct # with a kwrd)
;--prior to 09/22/09 
;   MyCt, /BuYlYlRd, NColors=DiffNColors
   MyCt, 63, NColors=DiffNColors, /MidCol, /Yello, /Reverse, _extra=e
    
   ; Default # of colortable divisions        
   if ( N_Elements( DiffDiv ) eq 0 ) $        
      then DiffDiv = ColorBar_NDiv( DiffNColors, MaxDiv=6 ) 

window,3
tvcurtain_mao, curtain3-curtain1, indgen(n_elements(dates)*24)+1, zmid, /ystyle, color = 1, $
           mindata=mindata, maxdata=maxdata, ytitle=ytitle, title='(f0=1)-(f0=0)',cbunit='ppb',$
           /CBar,/CBVertical,/NoAdvance,/NoZInterp

  pc = (diff/curtain1)*100.
  Min4    = Min( pc, Max=Max4 )
  Maxpc = max(abs(pc), /nan)
  Maxpc = 25
  MinData = -Maxpc
  MaxData = Maxpc
  ; set to zero if diff is already 0
  double_zero = where(diff eq 0., count)
  if count ne 0 then pc[double_zero] = 0.

window,4
tvcurtain_mao, pc, indgen(n_elements(dates)*24)+1, zmid, /ystyle, color = 1, $
           mindata=mindata, maxdata=maxdata, ytitle=ytitle, title='diff/f0',cbunit='%',$
           /CBar,/CBVertical,/NoAdvance,/NoZInterp
ctm_cleanup

end
