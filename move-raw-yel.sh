
tardir=/groups/YEL/PAIT2_preprocessed
indir=/groups/MRICORE/Chaplin

mapfile -t sublist < "/scratch/csng/YEL/data/move-participantsSMALL.tsv"

for sub in "${!sublist[@]}";
    do
    echo ${sublist[sub]}
    #cp -R /scratch/csng/YEL/data/output/fmriprep/sub-${sublist[sub]} /groups/YEL/PAIT2_preprocessed/fmriprep/
    #cp -R /scratch/csng/YEL/data/output/freesurfer/sub-${sublist[sub]} /groups/YEL/PAIT2_preprocessed/freesurfer/
    #cp -R /scratch/csng/YEL/data/output/ciftify/sub-${sublist[sub]} /groups/YEL/PAIT2_preprocessed/ciftify/
	#cp -R /scratch/csng/YEL/data/output/stats/sub-${sublist[sub]} /groups/YEL/PAIT2_preprocessed/stats/
    #cp -R /scratch/csng/YEL/data/TextFiles/${sublist[sub]} /groups/YEL/PAIT2_preprocessed/TextFiles/ 
    cp -rf /groups/MRICORE/Chaplin/CHAPLIN-PAIT2_#${sublist[sub]}_* /groups/YEL/PAIT2_preprocessed/raw/sub-${sublist[sub]}/   
    done


