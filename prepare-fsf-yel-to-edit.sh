#!/bin/bash
module load fsl

indir=/scratch/csng/YEL/data

oldn=2055


for sub in 2148 2150

    do
    
    mkdir ${indir}/output/stats/sub-${sub}
    mapfile -t tasklist < "${indir}/TextFiles/${sub}/tasklist.tsv"
    mapfile -t runlist < "${indir}/TextFiles/${sub}/runlist.tsv"
    
    for i in "${!tasklist[@]}";
        do
        echo ${tasklist[i]}
        echo ${runlist[i]}
        cp /home/sgoncal/Template_fsf/${tasklist[i]}.fsf ${indir}/output/stats/sub-${sub}
        
        
        sed -i "s/$oldn/${sub}/g" ${indir}/output/stats/sub-${sub}/${tasklist[i]}.fsf
        
        
        npts=$(fslnvols ${indir}/output/fmriprep/sub-${sub}/func/sub-${sub}_task-${runlist[i]}_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz)
        echo $npts
        INPUT="$(grep 'set fmri(npts)*' ${indir}/output/stats/sub-${sub}/${tasklist[i]}.fsf)"
        OUTPUT="set fmri(npts) $npts" 
        sed -i "s/${INPUT}/${OUTPUT}/g" ${indir}/output/stats/sub-${sub}/${tasklist[i]}.fsf

        
        # there is something wrong with the sed command here
        INPUT="_task-reward_run-1"
        OUTPUT="_task-${runlist[i]}"
        sed -i "s/_task-reward_run-1/_task-${runlist[i]}/g" ${indir}/output/stats/sub-${sub}/${tasklist[i]}.fsf
       
        
        done
    done


