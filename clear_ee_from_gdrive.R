#This version assumes a nice file structure on gdrive.
library('googledrive')

#Get a list of all the files
drive_folders = drive_ls(path = '~/modis/')

drive_rm(drive_folders)
