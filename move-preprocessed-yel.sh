
tardir=/groups/YEL/PAIT2_preprocessed
indir=/scratch/csng/YEL/data

mapfile -t sublist < "/home/sgoncal/move-participants.tsv"

for sub in "${!sublist[@]}";
    do
    echo ${sublist[sub]}
    cp -R /scratch/csng/YEL/data/output/fmriprep/sub-${sublist[sub]} /groups/YEL/PAIT2_preprocessed/fmriprep/
    echo "fmriprep"
    cp -R /scratch/csng/YEL/data/output/freesurfer/sub-${sublist[sub]} /groups/YEL/PAIT2_preprocessed/freesurfer/
    echo "freesurfer"
    cp -R /scratch/csng/YEL/data/nifti/sub-${sublist[sub]} /groups/YEL/PAIT2_preprocessed/nifti/
    echo "nifti"
    #cp -R /scratch/csng/YEL/data/output/ciftify/sub-${sublist[sub]} /groups/YEL/PAIT2_preprocessed/ciftify/
	cp -R /scratch/csng/YEL/data/output/stats/sub-${sublist[sub]} /groups/YEL/PAIT2_preprocessed/stats/
	echo "stats"
    cp -R /scratch/csng/YEL/data/TextFiles/${sublist[sub]} /groups/YEL/PAIT2_preprocessed/TextFiles/ 
    echo "TextFiles"
    #cp -rf /scratch/csng/YEL/data/output/fmriprep/sub-${sublist[sub]}/func/*confounds_reduced.tsv /groups/YEL/PAIT2_preprocessed/fmriprep/sub-${sublist[sub]}/func/
    #echo "confounds_reduced"   
    done


