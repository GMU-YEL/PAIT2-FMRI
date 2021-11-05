#!/bin/bash
module load fsl

indir=/scratch/csng/YEL/data

oldn=2055

# add all the subjects you want into this for loop
for sub in 2148 2150

    do
    
    for task in Emotion_Avg ParentEmotion_Avg;
        do

        cp /home/sgoncal/Template_fsf/${task}.fsf ${indir}/output/stats/sub-${sub}
        
        
        sed -i "s/$oldn/${sub}/g" ${indir}/output/stats/sub-${sub}/${task}.fsf

       
        
        done
    done


