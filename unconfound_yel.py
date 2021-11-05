#!/usr/bin/env python3
import os
import numpy as np
import pandas as pd
import nibabel as nib
import nilearn.image as nii


subject_list = np.loadtxt('/home/sgoncal/unconfound-participants.tsv', dtype=int)
subject_list.astype(str)


main_dir = '/scratch/csng/YEL/data'

for sid in subject_list:
    
    tasks2deconfound = pd.read_csv(main_dir + '/TextFiles/' + sid.astype(str)  + '/runlist.tsv', sep='\t', header=None, names=['tasks'],)

    
    for tid in tasks2deconfound.tasks:
        
        print(sid.astype(str) + ' ' + tid )

        # read in confounds file
        confounds_fpt = main_dir + '/output/fmriprep/sub-' + sid.astype(str)  + '/func/sub-' + sid.astype(str) + '_task-' + tid + '_desc-confounds_regressors.tsv'
        confounds = pd.read_csv(confounds_fpt, sep='\t')


    
        out_vars = pd.DataFrame()
        fd = pd.DataFrame(confounds, columns = ['framewise_displacement'])
        spikes = np.where(fd > 0.5)
        nspikes = len(spikes[0])
        if nspikes > 0:    
            spiki = spikes[0]
            for sp in range(nspikes):
                spikereg = np.zeros(len(fd))
                spikereg[spiki[sp]]=1
                fd_col_name = 'fd'+str(sp)
                fd_col_data = spikereg
                out_vars.loc[:,fd_col_name] = fd_col_data
                
        # nonsteady state       
        for eqlb in range(4):
            eqlbvals = np.zeros(len(fd))
            eqlbvals[eqlb] = 1
            eq_col_name = 'non_steady_state0'+str(eqlb)
            eq_col_data = eqlbvals
            out_vars.loc[:,eq_col_name] = eq_col_data
        
        # cosines and signals  
        cosinevars = confounds[['cosine00', 'cosine01', 'cosine02', 'cosine02']].copy()

        r = pd.concat([cosinevars, out_vars], axis=1)  
        
        output_fpt = main_dir + '/output/fmriprep/sub-' + sid.astype(str) + '/func/sub-' + sid.astype(str) + '_task-' + tid + '_desc-confounds_reduced.tsv'
        r.to_csv(output_fpt, sep=',', index=False, header=False)


