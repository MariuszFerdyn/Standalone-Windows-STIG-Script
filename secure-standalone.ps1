﻿######SCRIPT FOR FULL INSTALL AND CONFIGURE ON STANDALONE MACHINE#####
#Continue on error
$ErrorActionPreference= 'silentlycontinue'

#Require elivation for script run
#Requires -RunAsAdministrator
Write-Output "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

#Unblock all files required for script
Get-ChildItem *.ps*1 -recurse | Unblock-File

#Windows 10 Defenter Exploit Guard Configuration File
start-job -ScriptBlock {mkdir "C:\temp\Windows Defender"; copy-item -Path .\Files\"Windows Defender Configuration Files"\DOD_EP_V3.xml -Destination "C:\temp\Windows Defender\" -Force -Recurse -ErrorAction SilentlyContinue} 

#Optional Scripts 
#.\Files\Optional\sos-ssl-hardening.ps1
# powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

#Work In Progress
.\Files\Optional\sos-.net-4-stig.ps1

#Security Scripts
start-job -ScriptBlock {takeown /f C:\WINDOWS\Policydefinitions /r /a; icacls C:\WINDOWS\PolicyDefinitions /grant Administrators:(OI)(CI)F /t; copy-item -Path .\Files\PolicyDefinitions\* -Destination C:\Windows\PolicyDefinitions -Force -Recurse -ErrorAction SilentlyContinue}

#Disable TCP Timestamps
netsh int tcp set global timestamps=disabled

#####SPECTURE MELTDOWN#####
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverride -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverrideMask -Type DWORD -Value 3 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverride -Type DWORD -Value 8 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverrideMask -Type DWORD -Value 3 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverride -Type DWORD -Value 72 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverrideMask -Type DWORD -Value 3 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverride -Type DWORD -Value 8264 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name FeatureSettingsOverrideMask -Type DWORD -Value 3 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization" -Name MinVmVersionForCpuBasedMitigations -Type String -Value "1.0" -Force

#https://www.itsupportguides.com/knowledge-base/tech-tips-tricks/how-to-customise-firefox-installs-using-mozilla-cfg/
$firefox64 = "C:\Program Files\Mozilla Firefox"
$firefox32 = "C:\Program Files (x86)\Mozilla Firefox"
Write-Output "Installing Firefox Configurations - Please Wait."
Write-Output "Window will close after install is complete"
If (Test-Path -Path $firefox64){
    Copy-Item -Path .\Files\"FireFox Configuration Files"\defaults -Destination $firefox64 -Force -Recurse
    Copy-Item -Path .\Files\"FireFox Configuration Files"\mozilla.cfg -Destination $firefox64 -Force
    Copy-Item -Path .\Files\"FireFox Configuration Files"\local-settings.js -Destination $firefox64 -Force 
    Write-Host "Firefox 64-Bit Configurations Installed"
}Else {
    Write-Host "FireFox 64-Bit Is Not Installed"
}
If (Test-Path -Path $firefox32){
    Copy-Item -Path .\Files\"FireFox Configuration Files"\defaults -Destination $firefox32 -Force -Recurse
    Copy-Item -Path .\Files\"FireFox Configuration Files"\mozilla.cfg -Destination $firefox32 -Force
    Copy-Item -Path .\Files\"FireFox Configuration Files"\local-settings.js -Destination $firefox32 -Force 
    Write-Host "Firefox 32-Bit Configurations Installed"
}Else {
    Write-Host "FireFox 32-Bit Is Not Installed"
}

##JAVA STIG SCRIPT
#https://gist.github.com/MyITGuy/9628895
#http://stu.cbu.edu/java/docs/technotes/guides/deploy/properties.html

#<Windows Directory>\Sun\Java\Deployment\deployment.config
#- or -
#<JRE Installation Directory>\lib\deployment.config

If (Test-Path -Path "C:\Windows\Sun\Java\Deployment\deployment.config"){
    Write-Host "Deployment Config Already Installed"
}Else {
    Mkdir "C:\Windows\Sun\Java\Deployment\"
	New-Item "C:\Windows\Sun\Java\Deployment\deployment.config"
	Set-Content "C:\Windows\Sun\Java\Deployment\deployment.config" "#deployment.config
	deployment.system.config.mandatory=true
	deployment.system.config=C\:\\temp\\java\\deployment.properties"
    Write-Output "Deployment Config Installed"
}
If (Test-Path -Path "C:\temp\JAVA\"){
    Write-Host "Configs Already Deployed"
}Else {
    Mkdir "C:\temp\JAVA"
	New-Item "C:\temp\JAVA\deployment.properties"
	Set-Content "C:\Windows\Sun\Java\Deployment\deployment.config" "#deployment.properties
# Security Tab
# Enable Java content in the browser
deployment.webjava.enabled=true
deployment.webjava.enabled.locked
# Security Level
deployment.security.level=VERY_HIGH
deployment.security.level.locked

# Advanced Tab
# Debugging\Enable tracing
deployment.trace=false
deployment.trace.locked
# Debugging\Enable logging
deployment.log=false
deployment.log.locked
# Debugging\Show applet lifecycle exceptions
deployment.javapi.lifecycle.exception=false
deployment.javapi.lifecycle.exception.locked
# Java console
deployment.console.startup.mode.locked
deployment.console.startup.mode=HIDE
# Default Java for browsers\Microsoft Internet Explorer
deployment.browser.vm.iexplorer=true
deployment.browser.vm.iexplorer.locked
# Default Java for browsers\Mozilla family
deployment.browser.vm.mozilla.locked
deployment.browser.vm.mozilla=true
# Java Plug-in\Enable the next-generation Java Plug-in (requires browser restart)
# This must be done by executing one of the following commands as an administrator:
# [Disable]	- {JREInstallPath}\bin\ssvagent.exe -high -jpisetup -old
# [Enable]	- {JREInstallPath}\bin\ssvagent.exe -high -jpisetup -new
# Shortcut Creation
deployment.javaws.shortcut=ASK_IF_HINTED
deployment.javaws.shortcut.locked
# JNLP File/MIME Association
deployment.javaws.associations=ASK_USER
deployment.javaws.associations.locked
# Application Installation
deployment.javaws.install=IF_HINT
deployment.javaws.install.locked
#JRE Auto-Download
deployment.javaws.autodownload=NEVER
deployment.javaws.autodownload.locked
# Security Execution Environment\Enable granting elevated access to signed apps
# aka. Allow user to grant permissions to signed content
deployment.security.askgrantdialog.show=false
deployment.security.askgrantdialog.show.locked
# Security Execution Environment\Enable granting elevated access to self-signed apps
deployment.security.askgrantdialog.notinca=false
deployment.security.askgrantdialog.notinca.locked
# Security Execution Environment\Show sandbox warning banner
deployment.security.sandbox.awtwarningwindow=true
deployment.security.sandbox.awtwarningwindow.locked
# Security Execution Environment\Allow user to accept JNLP security requests
deployment.security.sandbox.jnlp.enhanced=true
deployment.security.sandbox.jnlp.enhanced.locked
# Security Execution Environment\Don't prompt for client certificate selection when no certificates or only one exists
deployment.security.clientauth.keystore.auto=true
deployment.security.clientauth.keystore.auto.locked
# Security Execution Environment\Warn if site certificate does not match hostname
deployment.security.jsse.hostmismatch.warning=true
deployment.security.jsse.hostmismatch.warning.locked
# Security Execution Environment\Show site certificate from server even if it is valid
deployment.security.https.warning.show=false
deployment.security.https.warning.show.locked
# Mixed code (sandbox vs. trusted) security verification
deployment.security.mixcode=DISABLE
deployment.security.mixcode.locked
# Perform certificate revocation checks on
deployment.security.revocation.check=ALL_CERTIFICATES
deployment.security.revocation.check.locked
# Check for certificate revocation using
# Replaces Advanced Security Settings\Check certificates for revocation using Certificate Revocation List (CRLs)
# [Certificate Revocation List (CRLs)]		- ocsp=false, crl=true
# [Online Certificate Status Protocol (OCSP)]	- ocsp=true, crl=false
# [Bot CRLs and OCSP]				- ocsp=true, crl=true
deployment.security.validation.ocsp=true
deployment.security.validation.ocsp.locked
deployment.security.validation.crl=true
deployment.security.validation.crl.locked
# Advanced Security Settings\Use certificates and keys in browser keystore
deployment.security.browser.keystore.use=true
deployment.security.browser.keystore.use.locked
# Advanced Security Settings\Check certificates for revocation using Certificate Revocation List (CRLs)
# See Check for certificate revocation using
# Advanced Security Settings\Enable list of trusted publishers
deployment.security.pretrust.list=true
deployment.security.pretrust.list.locked
# Advanced Security Settings\Enable blacklist revocation check
deployment.security.blacklist.check=true
deployment.security.blacklist.check.locked
# Advanced Security Settings\Enable caching password for authentication
deployment.security.password.cache=true
deployment.security.password.cache.locked
# Advanced Security Settings\Enable online certifcate validation
deployment.security.revocation.check=NO_CHECK
deployment.security.revocation.check.locked
# Advanced Security Settings\Use SSL 2.0 compatible ClientHello format
deployment.security.SSLv2Hello=false
deployment.security.SSLv2Hello.locked
# Advanced Security Settings\Use SSL 3.0
deployment.security.SSLv3=true
deployment.security.SSLv3.locked
# Advanced Security Settings\Use TLS 1.0
deployment.security.TLSv1=true
deployment.security.TLSv1.locked
# Advanced Security Settings\Use TLS 1.1
deployment.security.TLSv1.1=true
deployment.security.TLSv1.1.locked
# Advanced Security Settings\Use TLS 1.2
deployment.security.TLSv1.2=true
deployment.security.TLSv1.2.locked
# Miscellaneous\Place Java icon in system tray
# Miscellaneous\Java Quick Starter
deployment.system.tray.icon=false
deployment.system.tray.icon.locked
#V-66963 - Actions enforced before executing mobile code include, for example, prompting users prior to opening email attachments and disabling automatic execution.
deployment.insecure.jres=prompt
deployment.insecure.jres.locked
# Screen: Your Java version is insecure. or Your Java version is out of date.
deployment.expiration.check.enabled=false
deployment.expiration.check.enabled.locked
#
deployment.capture.mime.types=true
deployment.capture.mime.types.locked

deployment.security.expired.warning=false
deployment.security.expired.warning.locked

deployment.user.security.exception.sites=C\:\\temp\\java\\exception.sites


## Optimizations
deployment.system.cachedir=C\:\\temp\\java\\cache\\
deployment.cache.max.size=-1
deployment.cache.jarcompression=9
deployment.javapi.cache.enabled=true"

	New-Item "C:\temp\JAVA\exception.sites"
	Set-Content "C:\Windows\Sun\Java\Deployment\deployment.config" 
	"https://29PALMSBOMI-NSN.GOV
https://ABSENTEESHAWNEETRIBE-NSN.GOV
https://ACCESS-BOARD.GOV
https://ACOM.MIL
https://ADLNET.GOV
https://AF.MIL
https://AFIRM.MIL
https://AFMC.MIL
https://AFMS.MIL
https://AFRH.GOV
https://AFRICOM.MIL
https://AFSPC.MIL
https://AFTAC.GOV
https://AG.GOV
https://AGILE.MIL
https://AGUACALIENTE-NSN.GOV
https://AH.MIL
https://AHRQ.GOV
https://ALASKA.GOV
https://ALTUSANDC.GOV
https://ANTHRAX.MIL
https://APPS.MIL
https://ARCHIVES.GOV
https://ARL.MIL
https://ARLINGTONCEMETERY.MIL
https://ARMY.MIL
https://ARPA.MIL
https://ASBCA.MIL
https://ASSIST.MIL
https://ATF.GOV
https://AVIATIONWEATHER.GOV
https://BADRIVER-NSN.GOV
https://BARONA-NSN.GOV
https://BEARRIVER-NSN.GOV
https://BIA.GOV
https://BIGVALLEYRANCHERIA-NSN.GOV
https://BIHASITKA-NSN.GOV
https://BIOMETRICS.GOV
https://BLM.GOV
https://BLS.GOV
https://BLUELAKERANCHERIA-NSN.GOV
https://BOISFORTE-NSN.GOV
https://BPN.GOV
https://BRAC.GOV
https://BRB-NSN.GOV
https://BTA.MIL
https://BTO.GOV
https://BTS.GOV
https://BURNSPAIUTE-NSN.GOV
https://CA.GOV
https://CABAZONINDIANS-NSN.GOV
https://CAC.MIL
https://CADDONATION-NSN.GOV
https://CALIFORNIAVALLEYMIWOKTRIBE-NSN.GOV
https://CAMPO-NSN.GOV
https://CANCER.GOV
https://CAPITOL.GOV
https://CAPMED.MIL
https://CAYUGANATION-NSN.GOV
https://CBO.GOV
https://CCR.GOV
https://CDATRIBE-NSN.GOV
https://CDC.GOV
https://CENSUS.GOV
https://CENTCOM.MIL
https://CERT.MIL
https://CES.MIL
https://CFPB.GOV
https://CFTC.GOV
https://CHEROKEE-NSN.GOV
https://CHEYENNERIVERSIOUXTRIBE-NSN.GOV
https://CHICKASAW-GOVERNMENT-NSN.GOV
https://CHICKASAW-NSN.GOV
https://CHICKASAWARTISANS-NSN.GOV
https://CHICKASAWGOVERNMENT-NSN.GOV
https://CHICKASAWJUDICIAL-NSN.GOV
https://CHICKASAWLEGISLATURE-NSN.GOV
https://CHICKASAWNATION-NSN.GOV
https://CHICKASAWTRIBE-NSN.GOV
https://CHILKOOT-NSN.GOV
https://CHITIMACHA.GOV
https://CHUKCHANSI-NSN.GOV
https://CIA.GOV
https://CIGIE.GOV
https://CIO.GOV
https://CJIS.GOV
https://CMS.GOV
https://CMTS.GOV
https://CNCS.GOV
https://CNSS.GOV
https://COLUSA-NSN.GOV
https://COMMERCE.GOV
https://COMPLIANCE.GOV
https://COPYRIGHT.GOV
https://COUNTERWMD.GOV
https://COYOTEVALLEY-NSN.GOV
https://CPARS.GOV
https://CPSC.GOV
https://CRHC-NSN.GOV
https://CRIT-NSN.GOV
https://CROW-NSN.GOV
https://CRST-NSN.GOV
https://CSB.GOV
https://CSOSA.GOV
https://CST-NSN.GOV
https://CTTSO.GOV
https://CYBERCOM.MIL
https://DAPS.MIL
https://DARPA.MIL
https://DAU.MIL
https://DC3.MIL
https://DCAA.MIL
https://DCMA.MIL
https://DCOE.MIL
https://DCSA.MIL
https://DEA.GOV
https://DECA.MIL
https://DEFENDAMERICA.MIL
https://DEFENSE.GOV
https://DEFENSEIMAGERY.MIL
https://DEFENSEINNOVATIONMARKETPLACE.MIL
https://DEFENSELINK.MIL
https://DELAWARE.GOV
https://DEPLOYMENTHEALTH.MIL
https://DEPS.MIL
https://DFAS.MIL
https://DHHS.GOV
https://DHRA.MIL
https://DHS.GOV
https://DIA.MIL
https://DISA.MIL
https://DISAGRID.MIL
https://DLA.MIL
https://DMA.MIL
https://DMDC.MIL
https://DMDC.MIL
https://DMSO.MIL
https://DNFSB.GOV
https://DNI.GOV
https://DOC.GOV
https://DOD.GOV
https://DOD.MIL
https://DODED.MIL
https://DODIG.MIL
https://DODIIS.MIL
https://DODLIVE.MIL
https://DODTECHIPEDIA.MIL
https://DOE.GOV
https://DOI.GOV
https://DOL.GOV
https://DOT.GOV
https://DPAA.MIL
https://DRA.GOV
https://DROUGHT.GOV
https://DSCA.MIL
https://DSM.MIL
https://DSS.MIL
https://DTEPI.MIL
https://DTIC.MIL
https://DTRA.MIL
https://DTSA.MIL
https://EACLEARINGHOUSE.GOV
https://EB.MIL
https://ED.GOV
https://EEOC.GOV
https://EKLUTNA-NSN.GOV
https://ELYSHOSHONETRIBE-NSN.GOV
https://EMPLOYEESEXPRESS.GOV
https://EOP.GOV
https://EPA.GOV
https://EPLS.GOV
https://ERDC.GOV
https://ESGR.MIL
https://ESI.MIL
https://ESTOO-NSN.GOV
https://EUCOM.MIL
https://EWIIAAPAAYP-NSN.GOV
https://EXIM.GOV
https://EYAK-NSN.GOV
https://FAA.GOV
https://FBI.GOV
https://FBO.GOV
https://FCA.GOV
https://FCC.GOV
https://FCG.GOV
https://FCP-NSN.GOV
https://FCPOTAWATOMI-NSN.GOV
https://FDA.GOV
https://FDIC.GOV
https://FEC.GOV
https://FEDERALCOURTS.GOV
https://FEDRAMP.GOV
https://FEDVTE-FSI.GOV
https://FEDWORLD.GOV
https://FEMA.GOV
https://FERC.GOV
https://FERO.GOV
https://FGDC.GOV
https://FHFA.GOV
https://FIRSTGOV.GOV
https://FLRA.GOV
https://FMC.GOV
https://FMCS.GOV
https://FOODSAFETY.GOV
https://FORGE.MIL
https://FORTSILLAPACHE-NSN.GOV
https://FPDS-NG.GOV
https://FPDS.GOV
https://FPKI.GOV
https://FRB.GOV
https://FRCC.GOV
https://FREEDOMAWARD.MIL
https://FRS.GOV
https://FRTIB.GOV
https://FSAFEDS.COM
https://FTBELKNAP-NSN.GOV
https://FTC.GOV
https://FVAP.GOV
https://FWS.GOV
https://GA.GOV
https://GAO.GOV
https://GEODATA.GOV
https://GEOMAC.GOV
https://GILARIVER-NSN.GOV
https://GILARIVERINDIANCOMMUNITY-NSN.GOV
https://GLT-NSN.GOV
https://GOAA.GOV
https://GODATA.GOV
https://GOVBENEFITS.GOV
https://GPO.GOV
https://GPOACCESS.GOV
https://GPS.GOV
https://GSA.GOV
https://GSAADVANTAGE.GOV
https://GUIDELINE.GOV
https://GUNLAKETRIBE-NSN.GOV
https://HANNAHVILLEPOTAWATOMI-NSN.GOV
https://HAVASUPAI-NSN.GOV
https://HEALTH.MIL
https://HEALTHFINDER.GOV
https://HEALTHIERUS.GOV
https://HEIMDATA.GOV
https://HHS.GOV
https://HOOPA-NSN.GOV
https://HOPI-NSN.GOV
https://HOUSE.GOV
https://HPC.MIL
https://HUALAPAI-NSN.GOV
https://HUD.GOV
https://IA.MIL
https://IAD.GOV
https://IARPA-IDEAS.GOV
https://IARPA.GOV
https://ICE.GOV
https://ICH.GOV
https://ICJOINTDUTY.GOV
https://IDAHO.GOV
https://IHS.GOV
https://IIPAYNATION-NSN.GOV
https://INDIANAFFAIRS.GOV
https://INTELINK.GOV
https://INTELLIGENCE.GOV
https://INTERIOR.GOV
https://INTERPOL.GOV
https://IOSS.GOV
https://IRS.GOV
https://ISE.GOV
https://ISLETAPUEBLO-NSN.GOV
https://ITC.GOV
https://ITIS.GOV
https://JACKSONRANCHERIA-NSN.GOV
https://JALIS.MIL
https://JAST.MIL
https://JATDI.MIL
https://JBSA.MIL
https://JCCS.GOV
https://JCMOTF.MIL
https://JCOMTF.MIL
https://JCS.MIL
https://JCSE.MIL
https://JECC.MIL
https://JFCOM.MIL
https://JIEDDO.MIL
https://JLLIS.MIL
https://JOINTMODELS.MIL
https://JS.MIL
https://JSC.MIL
https://JSF.MIL
https://JSIMS.MIL
https://JTDI.MIL
https://JTEN.MIL
https://JTFGNO.MIL
https://JUSTICE.GOV
https://JWAC.MIL
https://JWOD.GOV
https://KAIBABPAIUTE-NSN.GOV
https://KAWAIKA-NSN.GOV
https://KAYENTATOWNSHIP-NSN.GOV
https://KBIC-NSN.GOV
https://KENAITZE-NSN.GOV
https://KEWEENAWBAY-NSN.GOV
https://KNOWLEDGENET.MIL
https://KOREA50.MIL
https://KTIK-NSN.GOV
https://LABOR.GOV
https://LAGUNA-NSN.GOV
https://LAGUNAPUEBLO-NSN.GOV
https://LAJOLLA-NSN.GOV
https://LCO-NSN.GOV
https://LOC.GOV
https://LTBBODAWA-NSN.GOV
https://LUMMI-NSN.GOV
https://MAIL.MIL
https://MARINES.MIL
https://MASHANTUCKET-NSN.GOV
https://MASHANTUCKETPEQUOT-NSN.GOV
https://MASHANTUCKETWESTERNPEQUOT-NSN.GOV
https://MASS.GOV
https://MAX.GOV
https://MC.MIL
https://MCN-NSN.GOV
https://MCRMC.GOV
https://MDA.MIL
https://MECHOOPDA-NSN.GOV
https://MEDICAID.GOV
https://MEDICARE.GOV
https://MEDLINEPLUS.GOV
https://MENOMINEE-NSN.GOV
https://MESAGRANDEBAND-NSN.GOV
https://MESKWAKI-NSN.GOV
https://MICCOSUKEE-NSN.GOV
https://MICMAC-NSN.GOV
https://MIDDLETOWNRANCHERIA-NSN.GOV
https://MILCLOUD.MIL
https://MILITARYONESOURCE.MIL
https://MILLELACSBAND-NSN.GOV
https://MILSUITE.MIL
https://MMS.GOV
https://MO.GOV
https://MOAPABANDOFPAIUTES-NSN.GOV
https://MOHICAN-NSN.GOV
https://MOJAVEDATA.GOV
https://MORONGO-NSN.GOV
https://MPGE-NSN.GOV
https://MPTN-NSN.GOV
https://MSCO.MIL
https://MSHA.GOV
https://MSPB.GOV
https://MT.GOV
https://MTMC.GOV
https://MUSCOGEENATION-NSN.GOV
https://MYPAY.GOV
https://NANO.GOV
https://NARA.GOV
https://NASA.GOV
https://NATIONALGUARD.MIL
https://NAVY.MIL
https://NBC.GOV
https://NCD.GOV
https://NCIHA-NSN.GOV
https://NCIX.GOV
https://NCPC.GOV
https://NCR.GOV
https://NCSC.MIL
https://NCUA.GOV
https://NEA.GOV
https://NEH.GOV
https://NEMI.GOV
https://NFPORS.GOV
https://NFR-NSN.GOV
https://NG.MIL
https://NGA.GOV
https://NGA.MIL
https://NH.GOV
https://NHTSA.GOV
https://NIC.GOV
https://NIC.MIL
https://NIFC.GOV
https://NIGC.GOV
https://NIH.GOV
https://NIMA.MIL
https://NINILCHIKTRIBE-NSN.GOV
https://NIPR.MIL
https://NISQUALLY-NSN.GOV
https://NIST.GOV
https://NLRB.GOV
https://NMB.GOV
https://NMIC.GOV
https://NOAA.GOV
https://NOOKSACK-NSN.GOV
https://NORAD.MIL
https://NORADNORTHCOM.MIL
https://NORTHCOM.MIL
https://NORTHFORKRANCHERIA-NSN.GOV
https://NOSC.MIL
https://NPS.GOV
https://NRC.GOV
https://NRO.GOV
https://NRO.MIL
https://NROJR.GOV
https://NSA.GOV
https://NSEP.GOV
https://NSF.GOV
https://NTIS.GOV
https://NTSB.GOV
https://NVB-NSN.GOV
https://NWBSHOSHONE-NSN.GOV
https://NWS.GOV
https://ODNI.GOV
https://OEA.GOV
https://OHIO.GOV
https://OHKAYOWINGEH-NSN.GOV
https://OMAHA-NSN.GOV
https://OMB.GOV
https://ONEIDA-NSN.GOV
https://ONEIDAINDIANNATION-NSN.GOV
https://ONEIDANATION-NSN.GOV
https://OPIC.GOV
https://OPM.GOV
https://OSAGECONGRESS-NSN.GOV
https://OSAGENATION-NSN.GOV
https://OSC.GOV
https://OSD.MIL
https://OSDBU.GOV
https://OSHA.GOV
https://OSHRC.GOV
https://OSIS.GOV
https://PACOM.MIL
https://PASCUAYAQUI-NSN.GOV
https://PASKENTA-NSN.GOV
https://PAUMA-NSN.GOV
https://PBGC.GOV
https://PCI-NSN.GOV
https://PCSTRAVEL.MIL
https://PDHEALTH.MIL
https://PEACECORPS.GOV
https://PECHANGA-NSN.GOV
https://PENTAGON.GOV
https://PENTAGON.MIL
https://PENTAGONCHANNEL.MIL
https://PEQUOT-NSN.GOV
https://PFPA.MIL
https://PHC-NSN.GOV
https://PICAYUNERANCHERIA-NSN.GOV
https://POARCHCREEKINDIANS-NSN.GOV
https://POKAGONBAND-NSN.GOV
https://POL-NSN.GOV
https://PRC.GOV
https://QVIR-NSN.GOV
https://RAMONA-NSN.GOV
https://RATB.GOV
https://READY.GOV
https://REDCLIFF-NSN.GOV
https://REGULATIONS.GOV
https://ROSEBUDSIOUXTRIBE-NSN.GOV
https://RRB.GOV
https://RST-NSN.GOV
https://RSTWATER-NSN.GOV
https://SACANDFOXNATION-NSN.GOV
https://SAFEXCHANGE.GOV
https://SAMHSA.GOV
https://SANDIA.GOV
https://SANMANUEL-NSN.GOV
https://SANTAANA-NSN.GOV
https://SANTAROSACAHUILLA-NSN.GOV
https://SAPR.MIL
https://SAUK-SUIATTLE-NSN.GOV
https://SBA.GOV
https://SCAT-NSN.GOV
https://SCC-NSN.GOV
https://SCUS.GOV
https://SECRETSERVICE.GOV
https://SEMINOLENATION-NSN.GOV
https://SENATE.GOV
https://SHINNECOCK-NSN.GOV
https://SHOALWATERBAY-NSN.GOV
https://SIGIR.MIL
https://SIR-NSN.GOV
https://SITEIDIQ.GOV
https://SITKATRIBE-NSN.GOV
https://SNO-NSN.GOV
https://SOBOBA-NSN.GOV
https://SOC.MIL
https://SOCDS.MIL
https://SOCOM.MIL
https://SOUTHCOM.MIL
https://SOUTHERNUTE-NSN.GOV
https://SPACECOM.MIL
https://SRMT-NSN.GOV
https://SRPMIC-NSN.GOV
https://SSA.GOV
https://SSS.GOV
https://STATE.GOV
https://STRATCOM.MIL
https://SURGEONGENERAL.GOV
https://SUSANVILLEINDIANRANCHERIA-NSN.GOV
https://SWINOMISH-NSN.GOV
https://SWO-NSN.GOV
https://SYCUAN-NSN.GOV
https://TACHI-YOKUT-NSN.GOV
https://TAMAYA-NSN.GOV
https://TEST.MIL
https://TIME.GOV
https://TMDCI-NSN.GOV
https://TOLC-NSN.GOV
https://TOLOWA-NSN.GOV
https://TONATION-NSN.GOV
https://TRANSCOM.MIL
https://TRANSPORTATION.GOV
https://TREAS.GOV
https://TREASURY.GOV
https://TRICARE.MIL
https://TRS.GOV
https://TSA.GOV
https://TSC.GOV
https://TSP.GOV
https://TSWG.GOV
https://TULALIP-NSN.GOV
https://TULALIPAIR-NSN.GOV
https://TULALIPTRIBES-NSN.GOV
https://TULERIVERTRIBE-NSN.GOV
https://TVA.GOV
https://TWENTYNINEPALMSBOMI-NSN.GOV
https://UGOV.GOV
https://UKB-NSN.GOV
https://UNICOR.GOV
https://UPPERSIOUXCOMMUNITY-NSN.GOV
https://UPPERSKAGIT-NSN.GOV
https://US-CERT.GOV
https://USAF.MIL
https://USAID.GOV
https://USAJOBS.GOV
https://USANDC.GOV
https://USASTAFFING.GOV
https://USBM.GOV
https://USBR.GOV
https://USC.GOV
https://USCAPITAL.GOV
https://USCG.GOV
https://USCG.MIL
https://USCIS.GOV
https://USCP.GOV
https://USDA.GOV
https://USDOJ.GOV
https://USFK.MIL
https://USGCRP.GOV
https://USGS.GOV
https://USHMM.GOV
https://USICH.GOV
https://USITC.GOV
https://USJOBS.GOV
https://USMARSHALS.GOV
https://USMC.MIL
https://USMINT.GOV
https://USMISSION.GOV
https://USOGE.GOV
https://USPHS.GOV
https://USPS.GOV
https://USPSOIG.GOV
https://USPTO.GOV
https://USSS.GOV
https://USTAXCOURT.GOV 
https://USTDA.GOV
https://USTRANSCOM.MIL
https://USTREAS.GOV
https://USUHS.MIL
https://VA.GOV
https://VACCINES.MIL
https://VIEJAS-NSN.GOV
https://VOA.GOV
https://WA.GOV
https://WARRIORCARE.MIL
https://WDOL.GOV
https://WEATHER.GOV
https://WESTERNPEQUOT-NSN.GOV
https://WHITEEARTH-NSN.GOV
https://WHITEHOUSE.GOV
https://WHITEPAGES.MIL
https://WHMO.MIL
https://WHS.MIL
https://WI.GOV
https://WILTONRANCHERIA-NSN.GOV
https://WINNEMUCCAINDIANCOLONYOFNEVADA-NSN.GOV
https://WYANDOTTE-NATION-NSN.GOV
https://YAKAMAFISH-NSN.GOV
https://YAKAMANATION-NSN.GOV
https://YOCHADEHE-NSN.GOV
https://YPT-NSN.GOV"
    Write-Output "JAVA Configs Installed"
}

#GPO Configurations
.\Files\LGPO\LGPO.exe /g .\Files\GPOs\

Add-Type -AssemblyName PresentationFramework
$Answer = [System.Windows.MessageBox]::Show("Reboot to make changes effective?", "Restart Computer", "YesNo", "Question")
Switch ($Answer)
{
    "Yes"   { Write-Warning "Restarting Computer in 15 Seconds"; Start-sleep -seconds 15; Restart-Computer -Force }
    "No"    { Write-Warning "A reboot is required for all changed to take effect" }
    Default { Write-Warning "A reboot is required for all changed to take effect" }
}
