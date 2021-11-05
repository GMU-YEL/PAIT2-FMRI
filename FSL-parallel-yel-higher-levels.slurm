#!/bin/bash
#
#SBATCH --job-name=fsl
#SBATCH -J fsl
#SBATCH --time=2-00:00:00
#SBATCH --array=1-4%2
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2G
#SBATCH -p all-LoPri  # Queue names you can submit to
# Outputs ----------------------------------
#SBATCH --output=/scratch/csng/YEL/%x-%N-%A-%a.out  # Output file
#SBATCH --error=/scratch/csng/YEL/%x-%N-%A-%a.err   # Error file
# ------------------------------------------#


## Load the relevant modules needed for the job
module load fsl

# make a tsv file with subject/task
task=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /home/sgoncal/subject-task-higher-levels.tsv )
export task
echo $task

# add lag between jobs
sleep $[ 10 * ${SLURM_ARRAY_TASK_ID} ]

## Run your program or script
/bin/date
cd /scratch/csng/YEL/
feat data/output/stats/${task}.fsf
/bin/date
