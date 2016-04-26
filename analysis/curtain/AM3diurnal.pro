pro alldiurnal

mychoice=['O3','OH','HO2','ISOP','MACR','MVK','PAN','MPAN','NO','NO2','NO3','CH2O','CO','NOy','ONITR','N2O5','C10H16','HNO3','HO2NO2','ISOPNO3','ISOPO2']

for i=0,n_elements(mychoice)-1 do begin

AM3diurnal, species=mychoice(i)

status=execute("screen2png, 'diurnal"+mychoice(i)+".png'")

endfor

end

pro AM3diurnal,species=species
;indir1 = '/archive/j1m/fms/riga_201012/c48L48_am3p9_RHpdnAVNT85_ox_o3s_dep/prod/pp/atmos/ts/hourly/1yr/'
;indir2 = '/archive/j1m/fms/riga_201012/c48L48_am3p9_RHpdnAVNT85_ox_o3s/prod/pp/atmos/ts/hourly/1yr/'
indir1='/vftmp/Jingqiu.Mao/dep/'
indir2='/vftmp/Jingqiu.Mao/nodep/'

;species='ISOP'

file1=indir1+'atmos.2009010100-2009123123.'+species+'.nc'
file2=indir2+'atmos.2009010100-2009123123.'+species+'.nc'
ncdf_read, result1, file=file1, variables=["time","lat","lon","pfull_sub01",species]
ncdf_read, result2, file=file2, variables=["time","lat","lon","pfull_sub01",species]

; For 18 to 21 plots
FirstHour   = JULDAY( 07 , 01 , 2009 , 06 , 00 , 00)-julday(1,0,2009, 06, 00, 00)

; Create final date if we want
LastHour   = JULDAY( 07 , 31, 2009 , 06 , 00 , 00)-julday(1,0,2009, 06, 00, 00)

Location=[36.6,-86.8]; lat, lon 36.6, -86.8 This is somewhere in Tennessee
;Location=[-2,-60]
;local_time,Location(1),FirstHour_utc,FirstHour
;local_time,Location(1),LastHour_utc,LastHour

index=where((result1.Time ge FirstHour) and (result1.Time le LastHour))
TimeArray=result1.Time(index)+Location(1)/15/24
;now change to hour
hour=(TimeArray-fix(TimeArray))*24

;now what???
;hour=hour+Location(1)/15

zmid=result1.pfull_sub01

;convert to local time
;local_time, Location(1),timearray, mylocaltime


;select data from the lat/lon
Latindx=where(result1.Lat ge Location(0) and (result1.Lat le Location(0)+2))
if Location(1) le 0L then Location(1)=Location(1)+360
Lonindx=where(result1.Lon ge Location(1) and (result1.Lon le Location(1)+2.5))

s1='curtain1=reform(result1.'+species+'(Lonindx,Latindx,*,index))'
s2='curtain2=reform(result2.'+species+'(Lonindx,Latindx,*,index))'

status=execute(s1)
status=execute(s2)

level=4
species_median1=tapply(curtain1(level,*),hour,'median')
species_median2=tapply(curtain2(level,*),hour,'median')
hour_median=findgen(24)+0.5

plot,hour_median,species_median1*1e9,color=1,title=species
oplot,hour_median,species_median2*1e9,color=2
legend, lcolor=[1,2],line=[0,0],lthick=[1,1],label=['fast','slow'],halign=0.9,valign=0.9,charsize=1.2,/colo
end

pro MVKMACRratio
;indir1 = '/archive/j1m/fms/riga_201012/c48L48_am3p9_RHpdnAVNT85_ox_o3s_dep/prod/pp/atmos/ts/hourly/1yr/'
;indir2 = '/archive/j1m/fms/riga_201012/c48L48_am3p9_RHpdnAVNT85_ox_o3s/prod/pp/atmos/ts/hourly/1yr/'
indir1='/vftmp/Jingqiu.Mao/nodep/'
;indir2='/vftmp/Jingqiu.Mao/nodep/'

species1='MVK'
species2='MACR'

file1=indir1+'atmos.2009010100-2009123123.'+species1+'.nc'
file2=indir1+'atmos.2009010100-2009123123.'+species2+'.nc'
ncdf_read, result1, file=file1, variables=["time","lat","lon","pfull_sub01",species1]
ncdf_read, result2, file=file2, variables=["time","lat","lon","pfull_sub01",species2]

; For 18 to 21 plots
FirstHour   = JULDAY( 07 , 01 , 2009 , 06 , 00 , 00)-julday(1,0,2009, 06, 00, 00)

; Create final date if we want
LastHour   = JULDAY( 07 , 31, 2009 , 06 , 00 , 00)-julday(1,0,2009, 06, 00, 00)

Location=[36.6,-86.8]; lat, lon 36.6, -86.8 This is somewhere in Tennessee
;Location=[-2,-60]
;local_time,Location(1),FirstHour_utc,FirstHour
;local_time,Location(1),LastHour_utc,LastHour

index=where((result1.Time ge FirstHour) and (result1.Time le LastHour))
TimeArray=result1.Time(index)+Location(1)/15/24
;now change to hour
hour=(TimeArray-fix(TimeArray))*24

;now what???
;hour=hour+Location(1)/15

zmid=result1.pfull_sub01

;convert to local time
;local_time, Location(1),timearray, mylocaltime


;select data from the lat/lon
Latindx=where(result1.Lat ge Location(0) and (result1.Lat le Location(0)+2))
if Location(1) le 0L then Location(1)=Location(1)+360
Lonindx=where(result1.Lon ge Location(1) and (result1.Lon le Location(1)+2.5))

s1='curtain1=reform(result1.'+species1+'(Lonindx,Latindx,*,index))'
s2='curtain2=reform(result2.'+species2+'(Lonindx,Latindx,*,index))'

status=execute(s1)
status=execute(s2)

level=4
species_median1=tapply(curtain1(level,*)/curtain2(level,*),hour,'median')
;species_median2=tapply(curtain2(level,*),hour,'median')
hour_median=findgen(24)+0.5

plot,hour_median,species_median1,color=1,title='MVK/MACR'
;oplot,hour_median,species_median2*1e9,color=2
;legend, lcolor=[1,2],line=[0,0],lthick=[1,1],label=['fast','slow'],halign=0.9,valign=0.9,charsize=1.2,/colo
end
