#!/bin/bash

# save the to your desktop to easily run from terminal
# cd into folder to run
# programmed by Lauren Breithaupt 
# modified by JT 03.04.19

set -e 
####Defining pathways
## ajn ## toplvl=/mnt/EE9A47C59A478953/data/fmri/SR08
toplev=$1
## ajn ## dcmdir=/mnt/EE9A47C59A478953/data/fmri/SR08/THOMPSON*/THOMPSON*

###Create dataset_description.json
niidir=${toplev}/YEL/data/nifti
if [[ ! -f ${niidir}/dataset_description.json ]]
    then
    jo -p "Name"="encode" "BIDSVersion"="1.0.2" >> ${niidir}/dataset_description.json
fi

printenv subject
subj=$( echo $subject | cut -d'-' -f 2)
dcmdir=$toplev/YEL/data/raw/sub-$subj/CHAPLIN*

# Location of DICOMs - anatomicals
t1wdcmdir=${dcmdir}/T1_MPRAGE*
t2wdcmdir=${dcmdir}/T2_SPACE*

# Opposite Phase Encode fieldmaps
peepidcmdir01=${dcmdir}/RFMRI_FMAP_SMS-PA_0*
peepirefdcmdir02=${dcmdir}/RFMRI_FMAP_SMS-PA_SBREF_0*

# # Location of DICOMS - BOLD: make sure scan numbers match up to correct task!!!
# resting state
bolddcmdir01=${dcmdir}/*BEN_BOLD*_1_0*
# reward task
bolddcmdir02=${dcmdir}/*BEN_BOLD*_2_0*
# IAPS
bolddcmdir03=${dcmdir}/*BEN_BOLD*_3_0*
bolddcmdir04=${dcmdir}/*BEN_BOLD*_4_0*
# Parent Task
bolddcmdir05=${dcmdir}/*BEN_BOLD*_5_0*
bolddcmdir06=${dcmdir}/*BEN_BOLD*_6_0*
# Likeability
bolddcmdir07=${dcmdir}/*BEN_BOLD*_7_0*

# Location of DICOMS - BOLD REF
# resting state
boldrefdcmdir01=${dcmdir}/*BEN_BOLD*_1_SBREF_0*
# reward task
boldrefdcmdir02=${dcmdir}/*BEN_BOLD*_2_SBREF_0*
# IAPS
boldrefdcmdir03=${dcmdir}/*BEN_BOLD*_3_SBREF_0*
boldrefdcmdir04=${dcmdir}/*BEN_BOLD*_4_SBREF_0*
# Parent
boldrefdcmdir05=${dcmdir}/*BEN_BOLD*_5_SBREF_0*
boldrefdcmdir06=${dcmdir}/*BEN_BOLD*_6_SBREF_0*
# Likeability
boldrefdcmdir07=${dcmdir}/*BEN_BOLD*_7_SBREF_0*



############################################## Anatomical Organization #####################################################

	echo "Processing subject $subj"

###Create structure
mkdir -p ${niidir}/sub-${subj}/anat

if [ -d ${t1wdcmdir} ]; then
    ###Convert dcm to nii
    #Only convert the Dicom folder anat
    for direcs in ${t1wdcmdir}; do
    dcm2niix  -o ${niidir}/sub-${subj} -f ${subj}_%f_%p ${direcs}
    done

    #Changing directory into the subject folder
    cd ${niidir}/sub-${subj}

    ###Change filenames
    ##Rename anat files
    #Example filename: 01_anat_MPRAGE; BIDS filename: sub-01_ses-1_T1w
    #Capture the number of anat files to change
    #T1
    anatfiles=$(ls -1 *MPRAGE* | wc -l)
    for ((i=1;i<=${anatfiles};i++)); do
    Anat=$(ls *MPRAGE*) #This is to refresh the Anat variable, if this is not in the loop, each iteration a new "No such file or directory error", this is because the filename was changed. 
    tempanat=$(ls -1 $Anat | sed '1q;d') #Capture new file to change
    tempanatext="${tempanat##*.}"
    tempanatfile="${tempanat%.*}"
    mv ${tempanatfile}.${tempanatext} sub-${subj}_T1w.${tempanatext}
    echo "${tempanat} changed to sub-${subj}_T1w.${tempanatext}"
    done
fi


if [ -d ${t2wdcmdir} ]; then
    ###Convert dcm to nii
    #Only convert the Dicom folder anat
    for direcs in ${t2wdcmdir}; do
    dcm2niix  -o ${niidir}/sub-${subj} -f ${subj}_%f_%p ${direcs}
    done
    #T2
    anatfiles=$(ls -1 *SPACE* | wc -l)
    for ((i=1;i<=${anatfiles};i++)); do
    Anat=$(ls *SPACE*) #This is to refresh the Anat variable, if this is not in the loop, each iteration a new "No such file or directory error", this is because the filename was changed. 
    tempanat=$(ls -1 $Anat | sed '1q;d') #Capture new file to change
    tempanatext="${tempanat##*.}"
    tempanatfile="${tempanat%.*}"
    mv ${tempanatfile}.${tempanatext} sub-${subj}_T2w.${tempanatext}
    echo "${tempanat} changed to sub-${subj}_T2w.${tempanatext}"
    done

fi

###Organize files into folders
for files in $(ls sub*); do 
Orgfile="${files%.*}"
Orgext="${files##*.}"
Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
if [ $Modality == "T1w" ]; then
	mv ${Orgfile}.${Orgext} anat
elif [ $Modality == "T2w" ]; then
	mv ${Orgfile}.${Orgext} anat
else
:
fi 
done


######################################################### Functional Organization ##########################################

	echo "Processing subject $subj"
#Create subject folder
mkdir -p ${niidir}/sub-${subj}/func


########### Resting State #####################
if [ -d ${bolddcmdir01} ]; then
 
        echo "Processing resting state subject $subj"
    ###Convert dcm to nii - Resting State
    for direcs in ${bolddcmdir01} ${boldrefdcmdir01}; do 
    dcm2niix  -o ${niidir}/sub-${subj} -f %f ${direcs}
    done

    #Changing directory into the subject folder
    cd ${niidir}/sub-${subj}

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_1_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.nii) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-resting_run-${i}_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-resting_run-${i}_bold.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_1_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-resting_run-${i}_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-resting_run-${i}_bold.${tempBOLDext}"
    done

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_1_SBREF_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.nii) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-resting_run-${i}_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-resting_run-${i}_sbref.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_1_SBREF_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-resting_run-${i}_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-resting_run-${i}_sbref.${tempBOLDext}"
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "bold" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "sbref" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done
fi


################### Reward Task #####################
if [ -d ${bolddcmdir02} ]; then
        echo "Processing reward task subject $subj"

    ##Convert dcm to nii - Reward Task
    for direcs in ${bolddcmdir02} ${boldrefdcmdir02}; do 
    dcm2niix  -o ${niidir}/sub-${subj} -f %f ${direcs}
    done

    #Changing directory into the subject folder
    cd ${niidir}/sub-${subj}

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_2_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.nii) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-reward_run-${i}_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-reward_run-${i}_bold.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_2_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-reward_run-${i}_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-reward_run-${i}_bold.${tempBOLDext}"
    done 

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_2_SBREF_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.nii) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-reward_run-${i}_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-reward_run-${i}_sbref.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_2_SBREF_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-reward_run-${i}_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-reward_run-${i}_sbref.${tempBOLDext}"
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "bold" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "sbref" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done
fi

################## Emotion Task, Run 1 #####################
if [ -d ${bolddcmdir03} ]; then
	echo "Processing subject emotion task run 1 $subj"

    ###Convert dcm to nii - Emotion Task

    for direcs in ${bolddcmdir03} ${boldrefdcmdir03}; do 
    dcm2niix  -o ${niidir}/sub-${subj} -f %f ${direcs}
    done

    #Changing directory into the subject folder
    cd ${niidir}/sub-${subj}

    ls

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_3_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.nii) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-emotion_run-${i}_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-emotion_run-${i}_bold.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_3_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-emotion_run-${i}_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-emotion_run-${i}_bold.${tempBOLDext}"
    done

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_3_SBREF_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.nii) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-emotion_run-${i}_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-emotion_run-${i}_sbref.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_3_SBREF_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-emotion_run-${i}_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-emotion_run-${i}_sbref.${tempBOLDext}"
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "bold" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "sbref" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done
fi

################### Emotion Task, Run 2 #####################

if [ -d ${bolddcmdir04} ]; then
        echo "Processing emotion task run 2 subject $subj"
        
    ###Convert dcm to nii - Emotion Task
    for direcs in ${bolddcmdir04} ${boldrefdcmdir04}; do 
    dcm2niix  -o ${niidir}/sub-${subj} -f %f ${direcs}
    done

    #Changing directory into the subject folder
    cd ${niidir}/sub-${subj}


    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_4_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.nii) #This is to refresh the Checker variable, same as the Anat case
    echo "1"
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-emotion_run-2_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-emotion_run-2_bold.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_4_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-emotion_run-2_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-emotion_run-2_bold.${tempBOLDext}"
    done

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_4_SBREF_0*.nii| wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.nii) #This is to refresh the Checker variable, same as the Anat case
    echo "1"
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-emotion_run-2_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-emotion_run-2_sbref.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_4_SBREF_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-emotion_run-2_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-emotion_run-2_sbref.${tempBOLDext}"
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "bold" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "sbref" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done
fi

################## Parent Emotion Task, Run 1 #####################
if [ -d ${bolddcmdir05} ]; then

        echo "Processing subject parent emotion task run 1 $subj"

    ##Convert dcm to nii - Parent Emotion Task

    for direcs in ${bolddcmdir05} ${boldrefdcmdir05}; do 
    dcm2niix  -o ${niidir}/sub-${subj} -f %f ${direcs}
    done

    #Changing directory into the subject folder
    cd ${niidir}/sub-${subj}

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_5_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.nii) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-parentemotion_run-${i}_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-parentemotion_run-${i}_bold.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_5_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-parentemotion_run-${i}_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-parentemotion_run-${i}_bold.${tempBOLDext}"
    done

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_5_SBREF_0*.nii| wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.nii) #This is to refresh the Checker variable, same as the Anat case
    echo "1"
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-parentemotion_run-${i}_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-parentemotion_run-${i}_sbref.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_5_SBREF_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-parentemotion_run-${i}_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-parentemotion_run-${i}_sbref.${tempBOLDext}"
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "bold" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "sbref" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done
fi

################## Parent Emotion Task, Run 2 #####################
if [ -d ${bolddcmdir06} ]; then
        echo "Processing parent emotion run 2 subject $subj"

    #Convert dcm to nii - Parent Emotion Task
    for direcs in ${bolddcmdir06} ${boldrefdcmdir06}; do 
    dcm2niix  -o ${niidir}/sub-${subj} -f %f ${direcs}
    done

    #Changing directory into the subject folder
    cd ${niidir}/sub-${subj}

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_6_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.nii) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-parentemotion_run-2_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-parentemotion_run-2_bold.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_6_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-parentemotion_run-2_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-parentemotion_run-2_bold.${tempBOLDext}"
    done

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_6_SBREF_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.nii) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-parentemotion_run-2_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-parentemotion_run-2_sbref.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_6_SBREF_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-parentemotion_run-2_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-parentemotion_run-2_sbref.${tempBOLDext}"
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "bold" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "sbref" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done
fi


################## Likeability Task #####################
if [ -d ${bolddcmdir07} ]; then
        echo "Processing likeability task subject $subj"

    ###Convert dcm to nii - Likeability Task
    for direcs in ${bolddcmdir07} ${boldrefdcmdir07}; do 
    dcm2niix  -o ${niidir}/sub-${subj} -f %f ${direcs}
    done

    #Changing directory into the subject folder
    cd ${niidir}/sub-${subj}

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_7_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.nii) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-likeability_run-${i}_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-likeability_run-${i}_bold.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_7_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-likeability_run-${i}_bold.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-likeability_run-${i}_bold.${tempBOLDext}"
    done

    ##Rename func files
    #Break the func down into each task
    #Capture the number of dissonance files to change
    BOLDfiles=$(ls -1 *BOLD-AP_7_SBREF_0*.nii | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.nii) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.nii}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-likeability_run-${i}_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-likeability_run-${i}_sbref.${tempBOLDext}"
    done

    BOLDfiles=$(ls -1 *BOLD-AP_7_SBREF_0*.json | wc -l)
    for ((i=1;i<=BOLDfiles;i++)); do
    BOLD=$(ls *BOLD*SBREF*.json) #This is to refresh the Checker variable, same as the Anat case
    tempBOLD=$(ls -1 $BOLD | sed '1q;d') #Capture new file to change
    tempBOLDext="${tempBOLD##*.}"
    tempBOLDfile="${tempBOLD%.json}"
    #tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
    mv ${tempBOLDfile}.${tempBOLDext} sub-${subj}_task-likeability_run-${i}_sbref.${tempBOLDext}
    echo "${tempBOLDfile}.${tempBOLDext} changed to sub-${subj}_task-likeability_run-${i}_sbref.${tempBOLDext}"
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "bold" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done

    ###Organize files into folders
    for files in $(ls sub*); do 
    Orgfile="${files%.*}"
    Orgext="${files##*.}"
    Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
    if [ $Modality == "sbref" ]; then
        mv ${Orgfile}.${Orgext} func
    else
    :
    fi 
    done
fi



##################################################################### PEPOLAR Fieldmaps ###################################

	echo "Processing subject $subj"

#Create subject folder
mkdir -p ${niidir}/sub-${subj}/fmap

###Convert dcm to nii
for direcs in ${peepidcmdir01} ${peepirefdcmdir02}; do 
dcm2niix  -o ${niidir}/sub-${subj} -f %f ${direcs}
done

#Changing directory into the subject folder
cd ${niidir}/sub-${subj}

##Rename func files
#Break the func down into each task
#Capture the number of dissonance files to change
PEEPIfiles=$(ls -1 *SMS-PA_0*.nii | wc -l)
for ((i=1;i<=PEEPIfiles;i++)); do
PEEPI=$(ls *-PA_*.nii) #This is to refresh the Checker variable, same as the Anat case
tempPEEPI=$(ls -1 $PEEPI | sed '1q;d') #Capture new file to change
tempPEEPIext="${tempPEEPI##*.}"
tempPEEPIfile="${tempPEEPI%.nii}"
#tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
mv ${tempPEEPIfile}.${tempPEEPIext} sub-${subj}_dir-PA_run-${i}_epi.${tempPEEPIext}
echo "${tempPEEPIfile}.${tempPEEPIext} changed to sub-${subj}_dir-PA_run-${i}_epi.${tempPEEPIext}"
done

PEEPIfiles=$(ls -1 *SMS-PA_0*.json | wc -l)
for ((i=1;i<=PEEPIfiles;i++)); do
PEEPI=$(ls *-PA_*.json) #This is to refresh the Checker variable, same as the Anat case
tempPEEPI=$(ls -1 $PEEPI | sed '1q;d') #Capture new file to change
tempPEEPIext="${tempPEEPI##*.}"
tempPEEPIfile="${tempPEEPI%.json}"
#tr=$(echo $tempcheck | cut -d '_' -f3) #f3 is the third field delineated by _ to capture the acquisition TR from the filename
mv ${tempPEEPIfile}.${tempPEEPIext} sub-${subj}_dir-PA_run-${i}_epi.${tempPEEPIext}
echo "${tempPEEPIfile}.${tempPEEPIext} changed to sub-${subj}_dir-PA_run-${i}_epi.${tempPEEPIext}"
done


##Organize files into folders
for files in $(ls sub*); do 
Orgfile="${files%.*}"
Orgext="${files##*.}"
Modality=$(echo $Orgfile | rev | cut -d '_' -f1 | rev)
if [ $Modality == "epi" ]; then
	mv ${Orgfile}.${Orgext} fmap
else
:
fi 
done

#gzip *.nii files
gzip ${niidir}/sub-$subj/anat/*.nii
gzip ${niidir}/sub-$subj/fmap/*.nii
gzip ${niidir}/sub-$subj/func/*.nii
rm -f ${niidir}/sub-$subj/RFMRI*
	
# ###Add IntendedFor to FMAP files to run w fMRIPREP
wDir=$(pwd)
cd ${niidir}/sub-$subj/
line=$(grep -n '"EchoTime": 0.033,' fmap/sub-${subj}_dir-PA_run-1_epi.json | cut -d : -f 1)
next=1
lineout=$(($line + $next))

array=()
array=(`find func/*bold.nii.gz -type f`)
var=$( IFS=$'\n'; printf "\"${array[*]}"\" )
filenames=$(echo $var | sed 's/ /", "/g')
textin=$(echo -e '"IntendedFor": ['$filenames'],')
sed -i "${lineout}i $textin " fmap/sub-${subj}_dir-PA_run-1_epi.json

cd $wDir



